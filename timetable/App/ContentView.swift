import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @State private var selectedTab = 0
    @State private var showAddCourse = false
    @State private var showImageImport = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TimetableView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button(action: { showAddCourse = true }) {
                                    Label("手动添加课程", systemImage: "square.and.pencil")
                                }
                                Button(action: { showImageImport = true }) {
                                    Label("从图片导入", systemImage: "photo.on.rectangle")
                                }
                            } label: {
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
                CourseListView()
            }
            .tabItem {
                Label("课程", systemImage: "list.bullet")
            }
            .tag(1)
        }
        .sheet(isPresented: $showAddCourse) {
            CourseEditView()
        }
        .sheet(isPresented: $showImageImport) {
            ImageImportView()
        }
    }
}
