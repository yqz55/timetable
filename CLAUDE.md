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

## File Structure

```
timetable/
├── project.yml                    # XcodeGen config — generates .xcodeproj
├── timetable.xcodeproj/           # Generated Xcode project (git-tracked for convenience)
├── .gitignore
├── CLAUDE.md
├── App/
│   ├── TimetableApp.swift         # @main entry point, creates ModelContainer
│   └── ContentView.swift          # Root view — 3-tab TabView (课表/导入/课程)
├── Models/
│   └── Course.swift               # SwiftData @Model + Color(hex:) + DesignTokens enum
├── Views/
│   ├── TimetableView.swift        # 12-period × 7-day grid (vertical scroll, 7 days fit screen)
│   ├── CourseListView.swift       # Courses grouped by weekday, swipe-to-delete
│   ├── CourseDetailView.swift     # View details, delete, or open edit sheet
│   ├── CourseEditView.swift       # Add/edit course form (supports pre-fill via editingCourse param)
│   └── ImageImportView.swift      # PhotosPicker → Vision OCR → confirm → save
├── ViewModels/
│   └── TimetableViewModel.swift   # @Observable — grid cell logic, courseSpan, coursesFor()
├── Services/
│   └── ImageParserService.swift   # Vision VNRecognizeTextRequest for OCR (placeholder heuristics)
└── designs/
    ├── timetable-zigzag.pen        # Pencil design file (encrypted, use pencil MCP tools)
    ├── SDUk9.png                   # Exported TimetableView mockup
    ├── eO5mt.png                   # Exported ImportView mockup
    └── x0C0R.png                   # Exported AddCourseView mockup
```

## Architecture

**Data layer:** Single SwiftData `@Model` — `Course` in `Models/Course.swift`. The app creates one `ModelContainer` in `TimetableApp.swift`. `Color(hex:)` extension on `Color` is defined here and used project-wide. Query via `@Query` in views, mutate via `modelContext.insert/delete`.

**App shell:** `ContentView` is the root — a `TabView` with three tabs (课表 / 导入 / 课程). The + button on the 课表 tab presents `CourseEditView` as a sheet. TabView uses `DesignTokens.primary` (#2D5E3A) as its tint.

**ViewModels:** `TimetableViewModel` (@Observable) handles grid logic — `coursesFor(day:period:in:)` filters which courses occupy a cell, `courseSpan` determines if a multi-period course renders in a given cell vs being skipped.

**Services:**
- `ImageParserService` — singleton wrapping Vision `VNRecognizeTextRequest`. The `parseTimetable`/`tryParseLine` methods are placeholder heuristics; real OCR would need spatial layout analysis of the recognized text bounding boxes.

**Design system:** `DesignTokens` enum in `Models/Course.swift` provides the Forest Sage palette — `background` (#F5F3EE), `primary` (#2D5E3A), `secondary` (#4A8C5E), `textPrimary` (#1B3A28), `textSecondary` (#4A6B52), `textTertiary` (#9AB0A0), `border` (#D5D9D3). All views reference these tokens. Course colors use 10 Forest Sage-derived hex values.

**Key types:**
- `Course` — SwiftData model. Stores `dayOfWeek` (1-7), `startPeriod` (1-12), `duration`, `colorHex`.
- `RecognizedCourse` — plain struct (not a model) used as intermediate representation between OCR output and `Course` creation. Lives in `ImageImportView.swift`.

## UI Design

Pencil `.pen` design mockups live in `designs/` (encrypted, access via the `pencil` MCP tools only). The active design file uses the Zigzag Bold Split style with Forest Sage palette (headings: Funnel Sans, body: Inter, captions: Geist).

## Known gaps

- OCR parsing is basic line-matching; doesn't use Vision's spatial text layout info.
- No test target configured.
