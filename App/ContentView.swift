import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @State private var selectedTab = 0
    @State private var showAddCourse = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TimetableView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showAddCourse = true }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
            }
            .tabItem {
                Label("课表", systemImage: "calendar")
            }
            .tag(0)

            NavigationStack {
                ImageImportView()
            }
            .tabItem {
                Label("导入", systemImage: "photo.on.rectangle")
            }
            .tag(1)

            NavigationStack {
                CourseListView()
            }
            .tabItem {
                Label("课程", systemImage: "list.bullet")
            }
            .tag(2)
        }
        .tint(DesignTokens.primary)
        .sheet(isPresented: $showAddCourse) {
            CourseEditView()
        }
    }
}
