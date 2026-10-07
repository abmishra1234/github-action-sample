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
