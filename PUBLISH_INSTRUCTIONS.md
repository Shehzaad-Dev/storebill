To publish the release to GitHub (requires `git remote add origin <url>` and `gh` CLI authenticated):

# Create remote (if not set)

```
git remote add origin https://github.com/OWNER/REPO.git
git push -u origin main
```

# Create GitHub release with GH CLI

```
gh release create v1.0.0 release_artifacts/app-release.apk --title "StoreBill v1.0.0 Stable" --notes-file RELEASE_NOTES.md --draft=false --prerelease=false
```

# Alternatively use the GitHub UI to create a release, upload `app-release.apk`, and paste `RELEASE_NOTES.md` as release notes.

# PowerShell script (API) alternative

If you have a GitHub Personal Access Token with `repo` scope saved to the environment variable `GITHUB_TOKEN`, run:

```
# from repository root
powershell -ExecutionPolicy Bypass -File .\create_github_release.ps1 -Owner Shehzaad-Dev -Repo storebill
```

This script will create the release and upload `release_artifacts/app-release.apk` and `release_artifacts/app-release.aab`.

# Manual gh CLI install

If you prefer the `gh` CLI, install it and authenticate with `gh auth login`, then run the `gh release create` command above.

