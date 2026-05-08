import SwiftUI
import SwiftData

@main
struct TimetableApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Course.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
