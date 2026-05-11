import SwiftUI
import SwiftData

struct CourseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false

    let course: Course

    var body: some View {
        List {
            Section("课程信息") {
                LabeledContent("课程名称", value: course.name)
                LabeledContent("授课教师", value: course.teacher.isEmpty ? "未设置" : course.teacher)
                LabeledContent("上课地点", value: course.location.isEmpty ? "未设置" : course.location)
            }

            Section("时间安排") {
                LabeledContent("星期", value: course.weekdayName)
                LabeledContent("节次", value: "第 \(course.startPeriod) - \(course.startPeriod + course.duration - 1) 节")
            }

            Section("课程颜色") {
                HStack {
                    Text("颜色标识")
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: course.colorHex))
                        .frame(width: 32, height: 32)
                }
            }

            if !course.notes.isEmpty {
                Section("备注") {
                    Text(course.notes)
                }
            }
        }
        .navigationTitle("课程详情")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("编辑") { showEdit = true }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    modelContext.delete(course)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            CourseEditView(editingCourse: course)
        }
    }
}
