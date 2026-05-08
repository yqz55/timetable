import SwiftUI
import SwiftData

struct TimetableView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @State private var viewModel = TimetableViewModel()

    private let periods = Array(1...12)
    private let days = Array(1...7)
    private let periodTimes = [
        "08:00", "08:55", "09:50", "10:45",
        "11:40", "13:30", "14:25", "15:20",
        "16:15", "17:10", "19:00", "19:55"
    ]

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 0) {
                // Header row: weekday names
                HStack(spacing: 0) {
                    Text("时间")
                        .frame(width: 48, height: 36)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    ForEach(Course.weekdays, id: \.self) { day in
                        Text(day)
                            .frame(width: 80, height: 36)
                            .font(.caption)
                            .fontWeight(.medium)
                            .background(Color(.systemGray6))
                            .border(Color(.separator), width: 0.5)
                    }
                }

                // Period rows
                ForEach(periods, id: \.self) { period in
                    HStack(spacing: 0) {
                        // Time label
                        VStack(spacing: 0) {
                            Text("\(period)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(periodTimes[safe: period - 1] ?? "")
                                .font(.system(size: 8))
                                .foregroundStyle(.tertiary)
                        }
                        .frame(width: 48, height: 52)
                        .background(Color(.systemGray6))
                        .border(Color(.separator), width: 0.5)

                        // Day cells
                        ForEach(days, id: \.self) { day in
                            PeriodCell(
                                period: period,
                                day: day,
                                courses: viewModel.coursesFor(
                                    day: day,
                                    period: period,
                                    in: courses
                                ),
                                allDayCourses: courses.filter { $0.dayOfWeek == day },
                                viewModel: viewModel
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("课表")
        .onAppear {
            viewModel.weeklyCourses = Dictionary(
                grouping: courses,
                by: { $0.dayOfWeek }
            )
        }
    }
}

struct PeriodCell: View {
    let period: Int
    let day: Int
    let courses: [Course]
    let allDayCourses: [Course]
    let viewModel: TimetableViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemBackground))
                .border(Color(.separator), width: 0.5)

            if let course = courses.first,
               viewModel.courseSpan(course: course, at: period, in: allDayCourses) {
                if period == course.startPeriod {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(course.name)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(2)
                        Text(course.location)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color(course.color).opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(1)
                }
            }
        }
        .frame(width: 80, height: 52)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
