# Repository Instructions

## Live Addon Deployment

- After making any repository change, update the live addon at `D:\World of Warcraft\_retail_\Interface\AddOns\MyAltManager` before handing the task back to the user.
- Copy the addon runtime files and directories (`MyAltManager.lua`, `MyAltManager.toc`, `libs`, and `media`) plus changed release documentation such as `README.md` and `CHANGELOG.md`.
- Preserve the live addon's `.git` directory and unrelated files; do not mirror-delete the destination.
- Verify copied files are identical to the repository versions after deployment.

## Git Commits

- Do not add `Co-Authored-By` trailers, "Generated with Claude Code" footers, or any other AI attribution to commit messages or pull request bodies.

## Mistake Log

- Read `MISTAKES.md` before starting project work and use its lessons while planning and implementing changes.
- Whenever you make a mistake or perform an action incorrectly, document it in `MISTAKES.md` before handing the task back to the user.
- Record the date, what went wrong, the correction, and the concrete prevention rule for future work.
- Do not remove prior entries; they are persistent project guidance.
