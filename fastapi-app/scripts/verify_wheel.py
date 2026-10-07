"""Install a built wheel in isolation and smoke-test its HTTP endpoints."""

import argparse
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import time
from urllib.error import URLError
from urllib.request import ProxyHandler, build_opener
import venv


def verify(wheel: Path, report_dir: Path) -> dict:
    result = {"wheel": wheel.name, "python": sys.version, "status": "failed", "checks": []}
    report_dir.mkdir(parents=True, exist_ok=True)
    # Prevent PYTHONPATH from making the source checkout importable in the child.
    environment = os.environ.copy()
    environment.pop("PYTHONPATH", None)
    environment.pop("PYTHONHOME", None)
    try:
        with tempfile.TemporaryDirectory(prefix="wheel-smoke-") as temporary:
            root = Path(temporary)
            venv.EnvBuilder(with_pip=True).create(root / "venv")
            python = root / "venv" / ("Scripts/python.exe" if os.name == "nt" else "bin/python")
            with (report_dir / "wheel-install.log").open("w", encoding="utf-8") as log:
                subprocess.run(
                    [str(python), "-I", "-m", "pip", "install", str(wheel)],
                    cwd=root, env=environment, stdout=log, stderr=subprocess.STDOUT,
                    check=True, timeout=300,
                )
                subprocess.run(
                    [str(python), "-I", "-m", "pip", "check"],
                    cwd=root, env=environment, stdout=log, stderr=subprocess.STDOUT,
                    check=True, timeout=60,
                )
            result["checks"].append({"check": "wheel installation and pip check", "status": "passed"})
            installed_file = subprocess.check_output(
                [str(python), "-I", "-c", "import app.main; print(app.main.__file__)"],
                cwd=root, env=environment, text=True, timeout=30,
            ).strip()
            if not Path(installed_file).resolve().is_relative_to((root / "venv").resolve()):
                raise RuntimeError(f"Application was imported outside the virtual environment: {installed_file}")
            result["checks"].append({"check": "import from installed wheel", "status": "passed", "path": installed_file})

            with socket.socket() as listener:
                listener.bind(("127.0.0.1", 0))
                port = listener.getsockname()[1]
            opener = build_opener(ProxyHandler({}))
            base_url = f"http://127.0.0.1:{port}"
            with (report_dir / "wheel-server.log").open("w", encoding="utf-8") as log:
                server = subprocess.Popen(
                    [str(python), "-I", "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", str(port)],
                    cwd=root, env=environment, stdout=log, stderr=subprocess.STDOUT,
                )
                try:
                    deadline = time.monotonic() + 30
                    while True:
                        if server.poll() is not None:
                            raise RuntimeError("Uvicorn exited before becoming ready; see wheel-server.log")
                        try:
                            with opener.open(base_url + "/health", timeout=1) as response:
                                if response.status == 200:
                                    break
                        except URLError:
                            pass
                        if time.monotonic() >= deadline:
                            raise TimeoutError("Uvicorn did not become ready within 30 seconds")
                        time.sleep(0.1)

                    cases = [
                        ("/health", {"status": "UP"}),
                        ("/api/greeting", {"message": "Hello, World!"}),
                        ("/api/greeting?name=Arun", {"message": "Hello, Arun!"}),
                        ("/api/greeting?name=%20Arun%20", {"message": "Hello, Arun!"}),
                        ("/api/greeting?name=%20%20", {"message": "Hello, World!"}),
                    ]
                    for path, expected in cases:
                        with opener.open(base_url + path, timeout=5) as response:
                            actual = json.load(response)
                            if response.status != 200 or actual != expected:
                                raise RuntimeError(f"Unexpected response for {path}: {actual}")
                        result["checks"].append({"check": path, "status": "passed", "response": actual})
                    with opener.open(base_url + "/openapi.json", timeout=5) as response:
                        schema = json.load(response)
                        if not {"/health", "/api/greeting"} <= schema.get("paths", {}).keys():
                            raise RuntimeError("OpenAPI schema is missing application endpoints")
                    result["checks"].append({"check": "OpenAPI schema", "status": "passed"})
                finally:
                    server.terminate()
                    try:
                        server.wait(timeout=10)
                    except subprocess.TimeoutExpired:
                        server.kill()
                        server.wait(timeout=10)
        result["status"] = "passed"
    except Exception as error:
        result["error"] = str(error)
    finally:
        (report_dir / "wheel-verification.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    project = Path(__file__).resolve().parents[1]
    parser.add_argument("--wheel", type=Path, help="Wheel to verify; defaults to the single wheel in dist/")
    parser.add_argument("--report-dir", type=Path, default=project / "report")
    args = parser.parse_args()
    wheels = [args.wheel] if args.wheel else list((project / "dist").glob("*.whl"))
    if len(wheels) != 1 or not wheels[0].is_file():
        parser.error("Build exactly one wheel in dist/ or specify --wheel PATH")
    result = verify(wheels[0].resolve(), args.report_dir.resolve())
    print(json.dumps(result, indent=2))
    return 0 if result["status"] == "passed" else 1


if __name__ == "__main__":
    sys.exit(main())
