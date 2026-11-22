# Episode Release Gap Audit

Find long breaks and same-day releases in an episode calendar.

![Sample run from Episode Release Gap Audit](docs/demo.webp)

## Run

Install PowerShell 7 or newer. Run these commands from the repository root.

```sh
pwsh -NoProfile -File app.ps1 sample.json
```

Replace `sample.json` with a JSON file following the same structure. The app prints a JSON report to standard output.

Use ISO dates and an integer gap threshold. A gap is flagged only when it strictly exceeds the threshold.

## Verify

Run `python check.py` with Python 3.11 or newer after the build step when applicable. The check verifies the bundled scenario and confirms that an invalid input returns an error.
