# Mistake Log

When adding an entry, include the date, what went wrong, how it was corrected, and the prevention rule to follow in future work.

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
