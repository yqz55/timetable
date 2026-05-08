# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

iOS 课表 (timetable) app — university course schedule manager. SwiftUI + SwiftData targeting iOS 17+, built with Xcode 16.

## Build & Run

```bash
# Generate Xcode project from project.yml
xcodegen generate

# Build for simulator
xcodebuild -project timetable.xcodeproj -scheme timetable \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Launch in booted simulator
xcrun simctl boot "iPhone 17 Pro"
xcrun simctl install booted \
  $BUILD_DIR/Debug-iphonesimulator/timetable.app
xcrun simctl launch booted com.yqz55.timetable
```

Use `open -a Simulator` if the simulator window isn't visible.

## Architecture

**Data layer:** Single SwiftData `@Model` — `Course` in `Models/Course.swift`. The app creates one `ModelContainer` in `TimetableApp.swift`. `Color(hex:)` extension on `Color` is defined here and used project-wide. Query via `@Query` in views, mutate via `modelContext.insert/delete`.

**App shell:** `ContentView` is the root — a `TabView` with two tabs. The 课表 tab shows a 12-period × 7-day grid. The 课程 tab shows a list grouped by weekday. Sheets present `CourseEditView` (manual entry) and `ImageImportView` (photo OCR).

**ViewModels:** `TimetableViewModel` (@Observable) handles grid logic — `coursesFor(day:period:in:)` filters which courses occupy a cell, `courseSpan` determines if a multi-period course renders in a given cell vs being skipped.

**Services:**
- `ImageParserService` — singleton wrapping Vision `VNRecognizeTextRequest`. The `parseTimetable`/`tryParseLine` methods are placeholder heuristics; real OCR would need spatial layout analysis of the recognized text bounding boxes.
- `StorageService` — generic UserDefaults wrapper with JSON encode/decode. Currently unused (SwiftData handles persistence).

**Key types:**
- `Course` — SwiftData model. Stores `dayOfWeek` (1-7), `startPeriod` (1-12), `duration`, `colorHex`.
- `RecognizedCourse` — plain struct (not a model) used as intermediate representation between OCR output and `Course` creation. Lives in `ImageImportView.swift`.

## UI Design

Pencil `.pen` design mockups live in `designs/` (encrypted, access via the `pencil` MCP tools only). The active design file uses the Zigzag Bold Split style with Forest Sage palette (headings: Funnel Sans, body: Inter, captions: Geist).

## Known gaps

- `CourseEditView` opens blank — no pre-fill when editing an existing course (edit mode is wired but not implemented).
- OCR parsing is basic line-matching; doesn't use Vision's spatial text layout info.
- `StorageService` is redundant while SwiftData is active.
- No test target configured.
