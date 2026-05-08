import SwiftUI
import SwiftData

struct CourseEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var teacher = ""
    @State private var location = ""
    @State private var dayOfWeek = 1
    @State private var startPeriod = 1
    @State private var duration = 2
    @State private var colorHex = Course.defaultColors[0]
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("课程信息") {
                    TextField("课程名称", text: $name)
                    TextField("教师", text: $teacher)
                    TextField("上课地点", text: $location)
                }

                Section("时间安排") {
                    Picker("星期", selection: $dayOfWeek) {
                        ForEach(1...7, id: \.self) { day in
                            Text(Course.weekdays[day - 1]).tag(day)
                        }
                    }
                    Picker("开始节次", selection: $startPeriod) {
                        ForEach(1...12, id: \.self) { period in
                            Text("第 \(period) 节").tag(period)
                        }
                    }
                    Stepper("持续 \(duration) 节课", value: $duration, in: 1...6)
                }

                Section("课程颜色") {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5)) {
                        ForEach(Course.defaultColors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(colorHex == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    colorHex = color
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("添加课程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveCourse() }
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveCourse() {
        let course = Course(
            name: name,
            teacher: teacher,
            location: location,
            dayOfWeek: dayOfWeek,
            startPeriod: startPeriod,
            duration: duration,
            colorHex: colorHex,
            notes: notes
        )
        modelContext.insert(course)
        dismiss()
    }
}
