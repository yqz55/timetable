import SwiftUI
import SwiftData

struct CourseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Course.dayOfWeek) private var courses: [Course]

    var body: some View {
        List {
            ForEach(groupedByDay, id: \.key) { day, dayCourses in
                Section(day) {
                    ForEach(dayCourses) { course in
                        NavigationLink {
                            CourseDetailView(course: course)
                        } label: {
                            CourseRow(course: course)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            modelContext.delete(dayCourses[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("全部课程")
        .overlay {
            if courses.isEmpty {
                ContentUnavailableView(
                    "还没有课程",
                    systemImage: "calendar.badge.plus",
                    description: Text("点击右上角 + 添加课程或导入课表图片")
                )
            }
        }
    }

    private var groupedByDay: [(key: String, value: [Course])] {
        let grouped = Dictionary(grouping: courses) { $0.weekdayName }
        let dayOrder = Dictionary(uniqueKeysWithValues: Course.weekdays.enumerated().map { ($1, $0) })
        return grouped.sorted { dayOrder[$0.key, default: 99] < dayOrder[$1.key, default: 99] }
    }
}

struct CourseRow: View {
    let course: Course

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: DesignTokens.radiusTag)
                .fill(course.color.opacity(0.25))
                .frame(width: 4, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text("\(course.teacher) · \(course.location)")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
            }

            Spacer()

            Text("第 \(course.startPeriod)-\(course.startPeriod + course.duration - 1) 节")
                .font(.caption2)
                .foregroundStyle(DesignTokens.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(DesignTokens.secondary.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.vertical, 2)
    }
}
