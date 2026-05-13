# Agent Directives

- **Test Scripts**: Do not write temporary test scripts to the `/tmp` directory. Instead, write them locally within the repository (e.g., in the `scripts/` or `tests/` directories) and ensure they are added to `.gitignore` so they are not tracked by version control. This avoids permission issues when the user executes them.
