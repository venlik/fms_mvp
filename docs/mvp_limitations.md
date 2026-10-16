# Known Limitations (MVP)

This document lists the deliberate trade-offs and unfinished edges of
the v0.1.0 MVP. Each entry describes what the code does today, why it
was left this way, and what the fix would look like.

## Bulk item import does not report skipped duplicates

`ItemRepository.commitAll` commits each draft in sequence. Drafts whose
content signature matches an existing item (name + description, case-
insensitive) are skipped silently. The caller is not told which drafts
were skipped or how many.

**Impact:** importing N drafts may commit fewer than N items.
**Mitigation:** re-running the import is safe — duplicates are skipped,
not errored.
**Planned:** return a `{committed, skipped}` result in a future release.

## Reset data requires an app restart

Settings → Reset all data deletes every JSON data file, the counters
file, and every app-produced PDF (`INV_*.pdf`, `REC_*.pdf`). After
deleting, the app calls `SystemNavigator.pop()` to close cleanly — the
user is expected to relaunch.

The repositories keep their entries in memory after the initial load.
Clearing files on disk does not clear them, so navigating back to any
screen after a reset would still show pre-reset data.

**Impact:** after a reset, the user must close and reopen the app. The
data on disk is correct; only the in-memory view is stale until the
next launch.
**Fix path:** add a `reload()` method to each repository that clears
`_entries` and re-runs `_load()`, then call it on all repositories
after the reset instead of closing the app.

## PDF preview does not support zoom on desktop

The in-app preview uses `printing`'s `PdfPreview` widget. Zoom
gestures (pinch, double-tap) activate when the rendered page exceeds
the viewport. On desktop — Linux in particular — the A4 page often
fits at 100% width, so there is nothing to zoom into. On some Linux
builds, `printing`'s native rendering is unreliable and the preview
may show a blank page.

**Impact:** users on desktop cannot magnify small text in a preview.
Mobile users are unaffected — the page renders larger than the screen
and zoom works normally.
**Planned:** evaluate `pdfrx` or Syncfusion as a replacement viewer,
or wrap the preview in a manual `InteractiveViewer` for desktop.

## Receipt numbers are allocated on first request, not on save

`ReceiptRepository.forPayment` looks up the receipt for a payment and
creates one only if none exists. The number is allocated once, on
first request, and persisted to `receipts.json`. Repeated calls for
the same payment return the same receipt.

**Impact:** none. This replaced the earlier behavior where every
preview or print call burned a number.
**Historical note:** the v0.1.0 initial design allocated on every
`generate` call. The current model is idempotent by payment id.

## Print and preview adapters are implemented for Flutter only

`DocumentPreviewer` and `DocumentPrinter` are consumed by
`InvoiceService` and `ReceiptService` via per-call injection. The
Flutter implementation is shipped:
- `FlutterPreviewer` uses `printing`'s `PdfPreview` widget
- `FlutterPrinter` uses `printing`'s `Printing.layoutPdf`

**Impact:** no limitation on the Flutter side. The CLI has no
adapters yet; a CLI-based preview or print path would need its own
implementations (shelling out to `xdg-open` / `lp` / `lpr`).
**Planned:** CLI adapters when the CLI grows beyond data manipulation.