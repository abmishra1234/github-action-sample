# GitHub Actions Sample

A learning repository for GitHub Actions, with examples of jobs, contexts, conditions, environment variables, matrices, and local composite actions. Three independent sample applications provide JavaScript/TypeScript, Java, and Python projects for experimenting with automation.

## Contents

- [Repository structure](#repository-structure)
- [Sample applications](#sample-applications)
- [Local setup and commands](#local-setup-and-commands)
- [GitHub Actions workflows](#github-actions-workflows)
- [Composite actions](#composite-actions)
- [Tests and generated output](#tests-and-generated-output)
- [Current implementation notes](#current-implementation-notes)

## Repository structure

The tree below includes the repository's source, configuration, assets, and documentation. Git internals and generated dependencies, builds, caches, and reports are excluded.

```text
github-action-sample/
|-- README.md
|-- .gitignore
|-- .github/
|   |-- workflows/
|   |   |-- 01-building-blocks.yaml
|   |   |-- 02-workflow.yaml
|   |   |-- 03-conditions.yaml
|   |   |-- 04-secrets-env.yaml
|   |   |-- 05-matrix.yaml
|   |   |-- 06-composite-actions.yaml
|   |   `-- 07-python-composite-actions.yaml
|   `-- actions/
|       |-- reaction-action-setup/
|       |   `-- action.yaml
|       |-- springboot-action-setup/
|       |   `-- action.yaml
|       `-- python-action-setup/
|           `-- action.yaml
|-- react-app/
|   |-- README.md
|   |-- .gitignore
|   |-- .oxlintrc.json
|   |-- index.html
|   |-- package.json
|   |-- package-lock.json
|   |-- tsconfig.json
|   |-- tsconfig.app.json
|   |-- tsconfig.node.json
|   |-- vite.config.ts
|   |-- public/
|   |   |-- favicon.ico
|   |   `-- robots.txt
|   `-- src/
|       |-- App.tsx
|       |-- App.css
|       |-- App.test.tsx
|       |-- index.css
|       |-- logo.svg
|       |-- main.tsx
|       |-- setupTests.ts
|       `-- vite-env.d.ts
|-- springboot-app/
|   |-- .gitattributes
|   |-- .gitignore
|   |-- pom.xml
|   |-- mvnw
|   |-- mvnw.cmd
|   |-- .mvn/
|   |   `-- wrapper/
|   |       `-- maven-wrapper.properties
|   `-- src/
|       |-- main/
|       |   |-- java/com/example/demo/
|       |   |   |-- SpringbootAppApplication.java
|       |   |   `-- greeting/
|       |   |       |-- GreetingController.java
|       |   |       `-- GreetingService.java
|       |   `-- resources/
|       |       `-- application.properties
|       `-- test/
|           `-- java/com/example/demo/
|               |-- SpringbootAppApplicationTests.java
|               `-- greeting/
|                   |-- GreetingControllerTest.java
|                   `-- GreetingServiceTest.java
`-- fastapi-app/
    |-- README.md
    |-- .gitignore
    |-- pyproject.toml
    |-- requirements.txt
    |-- requirements-dev.txt
    |-- app/
    |   |-- __init__.py
    |   |-- main.py
    |   `-- greeting.py
    `-- tests/
        |-- __init__.py
        |-- test_main.py
        `-- test_greeting.py
```

| Location | Purpose |
| --- | --- |
| `.github/workflows/` | Manually triggered GitHub Actions teaching examples. |
| `.github/actions/` | Local composite action definitions and placeholders. |
| `react-app/` | React UI, Vite configuration, component test, and npm scripts. |
| `springboot-app/` | Spring Boot greeting API, Maven wrapper, tests, and coverage configuration. |
| `fastapi-app/` | FastAPI greeting/health API, Python dependencies, tests, and coverage configuration. |
| `.gitignore` | Root exclusions for `.idea` and `trial/*`; each app also has its own ignore rules. |

## Sample applications

Versions below reflect the checked-in manifests, rather than a claim about the latest available releases.

| Application | Declared stack | Behavior |
| --- | --- | --- |
| React | React `^19.3.0`, Vite `^8.3.1`, TypeScript `~7.0.2`, Vitest `^5.0.2`, oxlint `^1.81.0` | Renders a React logo, an editing hint, and a Learn React link. |
| Spring Boot | Spring Boot `4.1.1`, Java target `17`, Maven wrapper `3.9.16`, JaCoCo `0.8.15` | Returns a greeting from `GET /api/greeting`. Includes Actuator. |
| FastAPI | Python `>=3.12`, FastAPI `0.142.2`, Uvicorn `0.54.0`, pytest `9.1.1`, pytest-cov `7.1.0` | Returns greetings and a health response. |

The apps run independently. The React UI currently does not call either backend.

### API endpoints

| Application | Request | Response |
| --- | --- | --- |
| Spring Boot | `GET http://localhost:8080/api/greeting?name=Arun` | `{"message":"Hello, Arun!"}` |
| Spring Boot | `GET http://localhost:8080/api/greeting` | `{"message":"Hello, World!"}` |
| FastAPI | `GET http://localhost:8000/api/greeting?name=Arun` | `{"message":"Hello, Arun!"}` |
| FastAPI | `GET http://localhost:8000/api/greeting` | `{"message":"Hello, World!"}` |
| FastAPI | `GET http://localhost:8000/health` | `{"status":"UP"}` |

Both greeting services trim surrounding whitespace and use `World` when a name is missing or blank. FastAPI also exposes its generated API documentation at `http://localhost:8000/docs` when running.

## Local setup and commands

Start from the repository root. Install the runtime for whichever app you want to use; there is no shared root build command. Dependency installation requires access to the relevant package registries.

### React

Use Node.js `24.x` to match the React setup workflow, with npm available.

```powershell
cd react-app
npm ci
npm run dev
```

Open the URL printed by Vite (normally `http://localhost:5173`). Additional commands, run inside `react-app/`:

```powershell
npm run test
npm run lint
npm run build
npm run preview
```

- `test`: runs Vitest once, using jsdom and the matchers registered in `src/setupTests.ts`.
- `lint`: runs oxlint with `.oxlintrc.json`.
- `build`: runs `tsc -b`, then creates a Vite production bundle in `dist/`.
- `preview`: serves the previously built bundle locally.

For test watch mode, use `npx vitest`. See [the React README](react-app/README.md) for additional toolchain and migration details.

### Spring Boot

The POM declares Java `17` as its target. Install a JDK compatible with the declared Spring Boot release and set `JAVA_HOME` for the Maven wrapper. Maven does not need to be installed separately; the wrapper downloads its configured distribution on first use.

Windows PowerShell:

```powershell
cd springboot-app
.\mvnw.cmd spring-boot:run
```

Run these checks inside `springboot-app/`:

```powershell
.\mvnw.cmd test
.\mvnw.cmd verify
```

On macOS/Linux, use `./mvnw` in place of `.\mvnw.cmd`.

`verify` runs tests, packages the application, generates the JaCoCo report, and checks the configured minimum of 80% bundle line coverage. To override the threshold for a run:

```powershell
.\mvnw.cmd verify -Djacoco.minimum.coverage=0.90
```

The generated executable JAR is `target/springboot-app-0.0.1-SNAPSHOT.jar`:

```powershell
java -jar target/springboot-app-0.0.1-SNAPSHOT.jar
```

### FastAPI

Use Python `3.12` or newer. Windows PowerShell:

```powershell
cd fastapi-app
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python -m uvicorn app.main:app --reload
```

On macOS/Linux, activate the environment with `source .venv/bin/activate` instead.

Run tests inside `fastapi-app/` with the environment active:

```powershell
python -m pytest
python -m pytest --cov=app --cov-report=term-missing --cov-report=html --cov-report=xml --cov-fail-under=80
```

`requirements-dev.txt` includes runtime dependencies plus testing dependencies. For a runtime-only environment, install `requirements.txt`. Coverage configuration in `pyproject.toml` targets `app`, enables branch measurement, and sets a report threshold of 80%. See [the FastAPI README](fastapi-app/README.md) for its short quick start.

## GitHub Actions workflows

All seven workflows currently use `workflow_dispatch`; none runs automatically on push or pull request. To run an example in GitHub, open the repository's **Actions** tab, select its workflow, choose **Run workflow**, and select the branch and any inputs.

| File | Workflow name | Demonstration |
| --- | --- | --- |
| [01-building-blocks.yaml](.github/workflows/01-building-blocks.yaml) | CI Workflow | One Ubuntu job checks out the repository and prints Hello World. |
| [02-workflow.yaml](.github/workflows/02-workflow.yaml) | 02-workflow | Sets up Node `24.x`, prints its version, dumps GitHub/runner/job/steps contexts, and summarizes run metadata. |
| [03-conditions.yaml](.github/workflows/03-conditions.yaml) | Condition Workflow | Accepts a `dev`, `staging`, or `production` choice (default `dev`); conditionally runs a staging step and demonstrates `continue-on-error` with step outcome/conclusion. |
| [04-secrets-env.yaml](.github/workflows/04-secrets-env.yaml) | Secrets And Environment | Demonstrates workflow/job/step variable scopes, shell exports, `$GITHUB_ENV`, `$GITHUB_OUTPUT`, and a job dependency. |
| [05-matrix.yaml](.github/workflows/05-matrix.yaml) | Matrix Workflow | Creates six combinations of Ubuntu/Windows and Node `18`, `20`, `22`; each sets up Node and prints a message. |
| [06-composite-actions.yaml](.github/workflows/06-composite-actions.yaml) | Composite Actions | Checks out code and invokes the local React action with Node `24.x`, directory `react-app`, and dependency-install flag `'false'`. |
| [07-python-composite-actions.yaml](.github/workflows/07-python-composite-actions.yaml) | Python Composite Actions | Checks out code and invokes the local Python action with Python `3.12` and directory `fastapi-app`; installs dependencies and runs tests with an 80% coverage threshold. |

The checkout and Node setup references in the files are `actions/checkout@v7` and `actions/setup-node@v7`. The matrix workflow demonstrates runtime combinations; it does not build or test the React app on those Node versions.

## Composite actions

### React setup action

The directory is spelled **`reaction-action-setup`** in the repository, and callers must use that exact path.

Definition: [.github/actions/reaction-action-setup/action.yaml](.github/actions/reaction-action-setup/action.yaml).

| Input | Required | Default | Purpose |
| --- | --- | --- | --- |
| `node-version` | Yes | `'24.x'` | Node version passed to `actions/setup-node`. |
| `working-directory` | No | `'./'` | App directory and location used to find `package-lock.json`. |
| `doWeWantToInstallDependencies` | No | `'true'` | Enables the conditional `npm install` step only when equal to the string `'true'`. |

The action exposes `node-version` from the Node setup step and configures npm caching against the app's lockfile. Its current shell steps run conditional `npm install`, followed by unconditional `npm ci`. See the implementation notes below before treating it as a complete test/build action.

### Python setup action

Definition: [.github/actions/python-action-setup/action.yaml](.github/actions/python-action-setup/action.yaml).

| Input | Required | Default | Purpose |
| --- | --- | --- | --- |
| `python-version` | Yes | `'3.12'` | Python version passed to `actions/setup-python@v7`. |
| `working-directory` | No | `'./'` | Project directory containing the requirements files and tests. |
| `doWeWantToInstallDependencies` | No | `'true'` | Controls installation from `requirements-dev.txt`; use `'false'` only if dependencies are already installed. |

The action exposes the installed `python-version`, caches pip downloads using both requirements files, and runs `python -m pytest --cov=app --cov-report=term-missing --cov-fail-under=80`. Pip caching does not replace dependency installation. Each composite shell step explicitly uses Bash.

### Spring Boot placeholder

The following file is empty and does not yet define a usable action:

- [.github/actions/springboot-action-setup/action.yaml](.github/actions/springboot-action-setup/action.yaml)

## Tests and generated output

| App | Existing test coverage | Generated output |
| --- | --- | --- |
| React | `App.test.tsx` checks that the Learn React link renders. | `dist/` from the build; no coverage script is currently configured. |
| Spring Boot | Application context load, greeting service behavior, and greeting controller responses. | `target/`, test reports under `target/surefire-reports/`, and JaCoCo HTML at `target/site/jacoco/index.html` after `verify`. |
| FastAPI | Greeting function cases plus greeting and health endpoint responses. | `.coverage`, `htmlcov/index.html`, and `coverage.xml` when running the coverage command above. |

## Current implementation notes

These observations describe the checked-in examples and are useful when extending them:

- The React composite action has empty `shell:` values on its `run` steps. Composite shell steps need an explicit shell before the action can execute successfully.
- Its description promises a build and unit tests, but the step named `Execute the Unit Test` runs `npm ci`; there are no `npm run test` or `npm run build` commands in the action. Setting the install flag to `'false'` skips only `npm install`, because `npm ci` remains unconditional.
- In `04-secrets-env.yaml`, `VAR1` is declared as a producing job's output, but the consuming job does not map `needs.propagating-values.outputs.VAR1` into its environment. The final `echo` therefore does not receive that output. A shell `export` also does not persist into a later step; the `$GITHUB_ENV` example demonstrates the mechanism for that.
- Despite its name, `04-secrets-env.yaml` does not reference repository secrets or configure GitHub deployment environments.
- In `02-workflow.yaml`, the summary references `$REF_NAME` without defining it in that step's environment.
- The app-specific READMEs contain references to workflow/action examples that are not fully implemented in the current files. This root README describes the present repository contents.
- Dependency versions and the declared Java target are recorded as found. Application builds, dependency availability, runtime compatibility, and hosted workflow execution have not been validated as part of this documentation scan.

To extend the examples, edit workflows in `.github/workflows/`, implement the placeholder composite actions in `.github/actions/`, and run the relevant app commands from that app's directory.
