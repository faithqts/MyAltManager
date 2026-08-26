# Mistake Log

When adding an entry, include the date, what went wrong, how it was corrected, and the prevention rule to follow in future work.

## 2026-08-26 — Repeated the documented PowerShell foreach pipeline error

- **What went wrong:** A read-only line-ending check piped directly from a `foreach` statement, causing PowerShell's "empty pipe element" parser error even though the mistake log already prohibited that exact construction.
- **Correction:** Assigned the loop output to `$endingRows` and piped that variable to `Format-Table`; the failed command made no repository or live-addon changes.
- **Prevention:** Before running any PowerShell loop that needs formatting, create a named result variable as part of drafting the command and place the formatting pipeline on its own subsequent statement.

## 2026-08-24 — Used the wrong Git option for CRLF whitespace validation

- **What went wrong:** I ran `git diff --check --ignore-space-at-eol` expecting it to ignore CRLF line terminators, but `diff --check` still treated every added carriage return as trailing whitespace and stopped the commit sequence with hundreds of false positives.
- **Correction:** Reran the check with Git's `core.whitespace=cr-at-eol` rule, which explicitly treats carriage returns at line endings as valid while continuing to detect real whitespace errors.
- **Prevention:** For this CRLF repository, invoke whitespace validation as `git -c core.whitespace=cr-at-eol diff --check`; do not assume diff comparison options change `--check` whitespace classification.

## 2026-08-24 — Twice piped directly from a PowerShell foreach statement

- **What went wrong:** A read-only validation command attempted to pipe directly from a `foreach` statement, which PowerShell rejected with an "empty pipe element" parser error before any checks ran. I then repeated the same syntax error in the live-deployment preflight despite having just recorded it.
- **Correction:** Collected each loop's output into a named variable before sending it to `Format-Table`, then reran both checks successfully; neither failed command affected repository or live-addon files.
- **Prevention:** Never place a pipeline operator immediately after a closing `foreach` brace in PowerShell; always assign the complete loop output to a named variable first, then pipe that variable in a separate statement.

## 2026-08-24 — Used an unsafe patch string, stale CSS context, and a visual-text test expectation

- **What went wrong:** A large CharacterRow patch was embedded in a JavaScript string that failed to parse, a subsequent CSS patch used pre-Prettier multiline context and was rejected, and the new drawer test expected CSS-transformed uppercase text instead of the lowercase DOM text returned by Vue Test Utils.
- **Correction:** Reissued the component patch with `String.raw`, inspected the formatted CSS before applying smaller exact-context hunks, and asserted the actual DOM string while leaving uppercase presentation to CSS; all seven unit tests then passed.
- **Prevention:** Use raw template literals for patch bodies containing complex Vue markup, re-read formatter-controlled context before large CSS edits, and keep unit assertions based on semantic DOM content rather than visual text transformations.

## 2026-08-24 — Used stale patch context and an incorrect first-row selector

- **What went wrong:** The first website simplification patch assumed pre-formatting App markup and was rejected, and the first divider-geometry check used `.character-row:first-of-type`, which selected no row sections because of the surrounding article structure.
- **Correction:** Read the exact current component source before applying smaller file-scoped patches, then queried the first four `.character-row > section` elements and confirmed every internal column boundary matched the corresponding header boundary after horizontal scrolling.
- **Prevention:** Inspect formatted template context immediately before UI patches, and validate DOM selector assumptions against the actual rendered nesting before treating an empty measurement as test evidence.

## 2026-08-24 — Passed a leading-dash search pattern as an rg option

- **What went wrong:** A final CSS line-reference search began its alternation with the token `--page:`, so `rg` parsed the pattern as an unsupported command-line flag and rejected the read-only command.
- **Correction:** Re-ran the same search with the explicit `--` end-of-options marker before the pattern and obtained the intended line references; no files were affected.
- **Prevention:** Whenever an `rg` pattern can begin with `-`, always place `--` before the pattern even when the pattern is quoted.

## 2026-08-24 — Repeated an invalid multi-file patch boundary

- **What went wrong:** While redesigning the website, I twice placed a new `Update File` marker immediately after a hunk without giving the patch parser a valid file boundary; both combined patches were rejected before modifying files.
- **Correction:** Re-read the formatted component context, applied the large App update separately, and then used a clean multi-file patch with independently valid hunks for the smaller component changes.
- **Prevention:** Default to one file per patch during iterative UI work; when combining files, validate that every hunk is syntactically complete before the next file marker instead of appending operations mechanically.

## 2026-08-24 — Assumed local tooling and scaffold names without preflight checks

- **What went wrong:** I invoked Docker before confirming it was installed, then passed the mixed-case destination basename to `create-vue`; npm rejected that package name and opened an interactive prompt instead of scaffolding the requested site.
- **Correction:** Confirmed Docker is unavailable and documented that container validation could not run locally; scaffolded through a valid lowercase temporary directory, validated both paths, and moved it to the exact requested `C:\git\MyAltManagerWebsite` destination.
- **Prevention:** Preflight required executables with `Get-Command` and validate npm package naming constraints before invoking a scaffold generator; separate the package name from the final display-cased folder name when necessary.

## 2026-08-24 — Accepted incompatible and deprecated generated dependencies

- **What went wrong:** The generated `oxlint` and `eslint-plugin-oxlint` ranges did not resolve to compatible versions, and I initially installed the deprecated `lucide-vue-next` package instead of the maintained Vue package.
- **Correction:** Aligned both oxlint packages to `~1.79.0`, removed the deprecated icon dependency, installed `@lucide/vue`, and reran installation, audit, type checking, linting, tests, and the production build successfully.
- **Prevention:** Inspect peer-dependency resolution after scaffolding and verify a package's current maintained name before adding it; treat deprecation and resolver warnings as required corrections, not ignorable output.

## 2026-08-24 — Sent unsafe-looking cleanup/process commands that the runner rejected

- **What went wrong:** I combined production-server startup and forced termination in one PowerShell command, then later combined guarded screenshot cleanup with `Remove-Item -Force`; the command safety layer rejected both before execution.
- **Correction:** Tested the server in a managed terminal session and stopped it gracefully with Ctrl+C; ignored the disposable preview images instead of forcing their deletion and ran Git initialization separately.
- **Prevention:** Keep process lifecycle and cleanup operations in small, independently verifiable calls, prefer graceful session control, and avoid forced deletion when an ignored disposable artifact is harmless.

## 2026-08-24 — Repeated a wrong-receiver structural assertion

- **What went wrong:** A final structural test looked for `editBox:HighlightText()` even though `ShowExport` correctly aliases the field as `copyBox` before selecting it, repeating the same receiver-reconstruction mistake already documented below.
- **Correction:** Inspected the exact implementation, changed the assertion to `copyBox:HighlightText()`, and reran the complete validation sequence.
- **Prevention:** Build fixed-string assertions by copying the exact production line after the implementation is final; never infer or rename the receiver in the test, especially when the mistake log already identifies that failure mode.

## 2026-08-24 — Invoked the Lua test runner incorrectly and concatenated a malformed harness

- **What went wrong:** The first `npx` invocation did not identify the package executable, and the first generated Lua harness omitted newlines between source blocks, producing an `endlocal` syntax error followed by avoidable PowerShell errors.
- **Correction:** Queried the package's executable metadata, invoked it explicitly through `npm exec`, joined every source block with a newline, and checked the process exit code before decoding its output.
- **Prevention:** Confirm an unfamiliar package's executable name before invoking it, delimit generated code blocks explicitly, and stop immediately when an external test process returns a nonzero exit code.

## 2026-08-24 — Unrelated clean documentation files disappeared during patching

- **What went wrong:** After a multi-file patch and line-ending normalization, `MyAltManagerWebsite.md` and `events.md` were unexpectedly absent even though neither was targeted and both were clean at the start of the task.
- **Correction:** Detected both deletions in the immediate status check and restored the exact files from `HEAD`, which was safe because the initial status proved they had no user changes.
- **Prevention:** Run `git status --short` immediately after every multi-file patch, compare it with the recorded initial status, and restore only files proven clean and unintentionally removed before doing further work.

## 2026-08-24 — Built two invalid multi-file patches

- **What went wrong:** The first patch declared two separate update operations for `MyAltManager.lua`, and the retry assumed the wrong README wording; the patch tool rejected both before changing any files.
- **Correction:** Inspected the exact README context, combined every Lua hunk under one file update, and reapplied the corrected patch.
- **Prevention:** Use one update block per file and inspect exact surrounding text before constructing a multi-file patch instead of relying on recalled wording.

## 2026-08-18 — Rewrote MyAltManager.toc with the wrong line endings

- **What went wrong:** Bumping `## Version:` with a Python whole-file rewrite converted the TOC's CRLF line endings to LF, turning a one-line version bump into a nine-line diff.
- **Correction:** Restored the original endings (line 1 LF, remaining lines CRLF) so the diff is only the version line.
- **Prevention:** Before rewriting a whole file, check its line endings (`cat -A`, `git diff | cat -A`) and preserve them; for one-line edits like the TOC version, use a targeted edit instead of a full rewrite.

## 2026-08-21 — Introduced mixed line endings while patching CRLF files

- **What went wrong:** `apply_patch` inserted LF endings on edited lines in files that were consistently CRLF at the start of the task.
- **Correction:** Normalized the affected files back to CRLF and re-ran line-ending and diff checks before deployment.
- **Prevention:** After every patch to a CRLF file, immediately count LF and CRLF endings; normalize the complete affected file back to its original convention before further verification.

## 2026-08-21 — Used an incorrectly quoted final search pattern

- **What went wrong:** A final read-only `rg` command used a double-quoted PowerShell regex containing embedded quotes, so the pattern reached `rg` truncated and failed to parse.
- **Correction:** Re-ran the line-reference check with separate fixed-string searches; no repository or deployed files were affected by the failed command.
- **Prevention:** For PowerShell searches containing quoted Lua strings, use single-quoted patterns or separate `rg -F` invocations instead of one alternation-heavy double-quoted regex.

## 2026-08-21 — Asserted the wrong receiver in a structural test

- **What went wrong:** A validation assertion expected `self:ScheduleCollect(...)` inside a button callback even though the callback correctly addresses the addon singleton as `AltManager:ScheduleCollect(...)`.
- **Correction:** Confirmed the production callback was correct and changed the test assertion to match its actual receiver before rerunning the full suite.
- **Prevention:** Copy the exact implementation fragment into fixed-string structural assertions, and separately test behavioral intent instead of reconstructing callback syntax from memory.

## 2026-08-21 — Used season-cap fields for a weekly-capped currency

- **What went wrong:** Coffer Key Shards were collected from `totalEarned` and `maxQuantity`, which describe season or holding limits, instead of `quantityEarnedThisWeek` and `maxWeeklyQuantity`; Endemics therefore stored and displayed `25/25` rather than the real weekly progress of `225/600`.
- **Correction:** Stored the spendable balance separately from Blizzard's weekly-earned and weekly-maximum values, displayed the weekly pair, and retained the spendable balance solely for Coffer Key Glue eligibility.
- **Prevention:** Before implementing currency cap logic, verify whether the cap is weekly, seasonal, or a holding limit and use the matching `CurrencyInfo` fields; test with a case where spendable quantity differs from weekly earned quantity.

## 2026-08-21 — Allowed deployment to continue after a missing source directory

- **What went wrong:** The live-addon deployment script tried to enumerate a repository `libs` directory that does not exist, but PowerShell treated that as a non-terminating error and the script still printed a success message for the files it did copy.
- **Correction:** Inspected the repository layout, confirmed that only `media` exists among the runtime directories, and reran deployment with terminating error handling and explicit source-path validation while leaving any unrelated live files untouched.
- **Prevention:** Set `$ErrorActionPreference = 'Stop'` in deployment scripts and validate every source path before copying so a missing path can never coexist with a success result.

## 2026-08-21 — Suppressed Coffer Key Glue at the weekly cap

- **What went wrong:** While adding the green numeric capped state, conversion was incorrectly disabled whenever weekly progress was capped, despite the established rule that more than 100 spendable shards should show `Convert Keys` when the glue is usable.
- **Correction:** Restored conversion as the highest-priority Coffer Key Shards state regardless of weekly progress; the numeric green cap remains visible whenever conversion is unavailable.
- **Prevention:** When multiple UI states overlap, preserve the previously specified priority order explicitly and include an overlap test covering every eligibility condition plus the capped state.

## 2026-08-21 — Evaluated a current-character action from stale saved data

- **What went wrong:** The Coffer Key Glue action relied on the row's saved currency payload and only used toy/item ownership checks, so a legacy Endemics payload or a glue exposed through its known spell could keep `Convert Keys` hidden despite current eligibility.
- **Correction:** Current-character eligibility now reads live Coffer Key Shards currency fields during rendering and recognizes the supplied Coffer Key Glue spell ID in addition to the toy and item.
- **Prevention:** For an immediately usable current-character action, use live API state for eligibility and treat persisted cross-character data as display fallback only; validate every supplied ownership identifier.

## 2026-08-21 — Applied a follow-up patch before restoring line endings

- **What went wrong:** After patching several CRLF files, a small Lua robustness follow-up was applied before the required immediate CRLF normalization step.
- **Correction:** Normalized every affected file immediately after the follow-up and repeated the line-ending checks before validation and deployment.
- **Prevention:** Treat normalization and line-ending verification as part of each `apply_patch` operation; do not begin even a related follow-up edit until that check has completed.

## 2026-08-21 — Used a non-functional item-ID macro for a toy

- **What went wrong:** The secure Coffer Key Glue button used `/use item:267291`; the button received clicks, but the client's secure item handling does not activate this toy through that macro form.
- **Correction:** Replaced the macro with the native secure `toy` action and supplied item ID 267291 through the `toy` attribute.
- **Prevention:** Use the secure action type matching the cursor/action-bar type (`toy`, `item`, or `spell`) and verify the actual activation path, not only button eligibility and click dispatch.

## 2026-08-21 — Chose the wrong protected action type for the glue toy

- **What went wrong:** The follow-up used secure action type `toy`, but Coffer Key Glue still did not activate when clicked; the installed client addons that actually expose learned toys through secure buttons use action type `item` with an `item:ID` attribute.
- **Correction:** Matched that working pattern with a left-click secure `item` action, item attribute `item:267291`, both click transitions registered, and key-down use disabled.
- **Prevention:** When a protected action can be represented several ways, copy the complete action attributes and click registration from a proven in-client implementation and distinguish macro syntax support from secure attribute support.

## 2026-08-21 — Rebuilt the dashboard after failed secure casts

- **What went wrong:** The glue overlay scheduled a currency collection from `PostClick` even when its cast failed because the character was moving, and the independent UIParent overlay also carried a redundant border that could remain visible after the dashboard closed.
- **Correction:** Removed the unconditional post-click rebuild and overlay border, retained refreshes on successful spell/currency events, and added explicit pre-close cleanup that unregisters visibility control, hides the overlay, and clears its anchors.
- **Prevention:** Refresh cast-driven state from success/result events rather than raw clicks, and give every independently parented overlay a dedicated teardown path tested after both successful and failed actions.

## 2026-08-21 — Overwrote the dashboard's secure-overlay cleanup handler

- **What went wrong:** The first cleanup implementation installed an `OnHide` handler for the secure overlay, but a later existing `SetScript("OnHide", ...)` for the footer ticker replaced it during frame initialization.
- **Correction:** Converted the later footer teardown registration to `HookScript`, preserving both the overlay cleanup and footer ticker shutdown for every dashboard hide path.
- **Prevention:** Search the full frame initialization for duplicate script registrations before adding lifecycle cleanup; use one combined handler or `HookScript` when multiple independent teardown actions share an event.

## 2026-08-21 — Derived the glue hit area from the logical currency cell

- **What went wrong:** The secure Coffer Key Glue overlay used the currency cell's logical bounds, which did not reliably make the separately rendered bar text clickable in the live UI.
- **Correction:** Derived the overlay from the rendered child bounds, spanning the shard icon's left edge through the progress bar's right edge and covering their full combined height.
- **Prevention:** For a protected hit target spanning multiple child frames, calculate the union of the rendered child bounds and verify clicks at both endpoints rather than assuming the parent cell's dimensions match its visible content.

## 2026-08-21 — Moved the currency label for the glue cast state

- **What went wrong:** The first cast-progress implementation re-anchored `Converting` from the currency bar's normal center position to its top edge, making the label visibly jump when the cast began.
- **Correction:** Kept the label permanently centered at its original size and position and allowed only the independent progress strip beneath it to change during the cast.
- **Prevention:** Transient progress states should preserve the baseline label anchors unless a position change is explicitly requested; add animation as an independent child region and verify the label geometry before and during the state change.
