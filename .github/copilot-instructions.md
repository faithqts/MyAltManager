# Copilot Instructions

## Build, test, and lint commands

No repository-local build, test, lint, or single-test commands are currently defined. The executable behavior in this repository is the GitHub Actions automation in `.github/workflows/`.

## High-level architecture

This repo is a two-stage release pipeline driven by metadata in a root-level TOC file:

1. `.github/workflows/auto-tag.yml` runs on pushes to `main` and `master`, extracts `## Version:` from the first root `*.toc`, and creates/pushes `v<version>` only if that tag does not already exist.
2. `.github/workflows/release.yml` runs on `push` for tags matching `v*`, reads `## Version:` and `## Title:` from the same TOC, creates a zip artifact, publishes a GitHub Release, then sends a Discord webhook announcement.

The workflows are tightly coupled through shared TOC parsing rules and tag format. Changes to metadata extraction, tag naming, or TOC location must be mirrored in both workflows.

## Key conventions

- Release metadata contract comes from root `*.toc` headings:
  - `## Version: x.y.z`
  - `## Title: Some Title`
- Both workflows resolve TOC with `ls *.toc | head -n1`; if multiple TOC files exist, only the first match is used.
- Release packaging root folder is derived from the selected TOC filename (`basename <file>.toc`), so zip contents are emitted as `<project-name>/*` (for example, `MyAltManager/*` or `Nexus/*`).
- TOC version values exclude the `v` prefix; workflow tags and release triggers use `v<version>`.
- Artifact naming is `"<title-without-spaces>-<version>.zip"` via `SAFE_NAME=$(echo "$TITLE" | tr -d ' ')`.
- `release.yml` prepares package contents with `rsync` and excludes `.git/`, `.github/`, `.vscode/`, `references/`, `node_modules/`, `.gitignore`, `.editorconfig`, and `README.md`.
- Secrets contract:
  - `GITHUB_TOKEN` for release publishing
  - `DISCORD_WEBHOOK_URL` for release notifications
- Workflow shell logic assumes `ubuntu-latest` with standard GNU utilities (`ls`, `grep`, `awk`, `tr`, `date`, `curl`).

## Committing and branching

- The main branch is `main` (or `master` if `main` does not exist).
- Whenever pushing code up make sure the version is incremented in the root TOC file, otherwise the release workflow will not trigger. The version should be in the format `x.y.z` (e.g., `1.0.0`).
- Treat TOC version updates as mandatory for any non-TOC code change.
- Before commit: if non-TOC files are staged, stage the root TOC file with an updated `## Version:` value.
- Before push: verify outgoing commits include that TOC version bump.
- When generating a commit/push on request, include a `Release Notes:` section in the commit message body with plain bullet lines only (no `Item 1:` labels), for example:
  - `- Updated TOC`
  - `- Updated Workflow`
  - `- Added New Module "Auto Withdraw Treatise"`
- Use real newline characters in commit bodies; do not use literal `\n` or PowerShell escape text like `` `n``.
- In PowerShell, prefer creating a temporary commit message file and using `git commit -F <file>` to preserve multi-line formatting reliably.
