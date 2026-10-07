# fastapi-app

A minimal FastAPI app used to demo the `python-action-setup` composite action.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt

uvicorn app.main:app --reload          # http://localhost:8000/api/greeting?name=Arun
pytest --cov                            # unit tests + coverage
```

## Test reports

From `fastapi-app/`, run `python -m pytest`. The defaults in `pyproject.toml`
generate these reports automatically and enforce an 80% coverage threshold:

- `report/test-results.xml`: JUnit results with test names, durations, and failures.
- `report/coverage.xml`: machine-readable coverage results.
- `report/coverage/index.html`: browsable coverage report with source details.

The generated `report/` folder is ignored by Git. The Python Composite Actions
workflow uploads it as the `python-test-report` artifact even when tests fail.
Download and extract the artifact from the workflow run to open the HTML report.

## Build and verify the wheel

With Python 3.12 or newer and `requirements-dev.txt` installed, run from this directory:

```bash
python -m pytest
python -m build --wheel
python -m twine check --strict dist/*.whl
python scripts/verify_wheel.py
```

The wheel is generated at `dist/fastapi_app-0.1.0-py3-none-any.whl`. Setuptools
packages only `app` and reads runtime dependencies from `requirements.txt`.
Twine checks the distribution metadata and README without publishing anything.

The verification script creates a fresh temporary virtual environment, installs
the wheel and its declared dependencies, runs `pip check`, and confirms that
imports come from that environment. It starts Uvicorn outside the source checkout
and tests health, default/named/trimmed/blank greetings, and the OpenAPI schema
over HTTP. It stops the server and removes the temporary environment afterward.
Dependency installation needs package registry access.

Results are saved in `report/wheel-verification.json`, with installation output
in `report/wheel-install.log` and server output in `report/wheel-server.log`.
Verification exits with a nonzero status on failure. If `dist/` contains multiple
wheels, select one explicitly with `--wheel dist/FILE.whl`.

The Python workflow runs these stages after unit tests and uploads the wheel as
`python-wheel`, plus the reports as `python-test-report`. Report and wheel uploads
are attempted even when an earlier step fails.
