import SwiftUI
import SwiftData

struct TimetableView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @State private var viewModel = TimetableViewModel()

    private let periods = Array(1...12)
    private let days = Array(1...7)

    private var currentDayOfWeek: Int {
        let weekday = Calendar.current.component(.weekday, from: Date()) // 1=Sun..7=Sat
        return weekday == 1 ? 7 : weekday - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            headerRow
            Divider().background(DesignTokens.border)
            periodScroll
        }
        .background(DesignTokens.background)
    }

    // MARK: - Navigation Bar

    private var navBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(weekLabel)
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textTertiary)
                Text(dateRange)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.textPrimary)
            }
            Spacer()
            Image(systemName: "gearshape")
                .font(.system(size: 18))
                .foregroundStyle(DesignTokens.textSecondary)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }

    private var weekLabel: String {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        return "第\(weekOfYear - calendar.component(.weekOfYear, from: semesterStart()))周"
    }

    private var dateRange: String {
        let today = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        guard let monday = calendar.date(byAdding: .day, value: mondayOffset, to: today),
              let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "M.d"
        return "\(formatter.string(from: monday)) - \(formatter.string(from: sunday))"
    }

    private func semesterStart() -> Date {
        let components = Calendar.current.dateComponents([.year], from: Date())
        return Calendar.current.date(from: DateComponents(year: components.year, month: 2, day: 17)) ?? Date()
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 32, height: 40)

            ForEach(days, id: \.self) { day in
                VStack(spacing: 1) {
                    Text(Course.weekdays[day - 1])
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DesignTokens.textSecondary)
                    Text("\(dayDate(for: day))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(day == currentDayOfWeek
                            ? DesignTokens.primary
                            : DesignTokens.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(day == currentDayOfWeek
                    ? DesignTokens.primary.opacity(0.08)
                    : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusTag))
            }
        }
        .padding(.horizontal, 16)
    }

    private func dayDate(for day: Int) -> Int {
        let today = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = weekday == 1 ? -6 : 2 - weekday
        guard let monday = calendar.date(byAdding: .day, value: mondayOffset, to: today) else {
            return day
        }
        guard let date = calendar.date(byAdding: .day, value: day - 1, to: monday) else {
            return day
        }
        return calendar.component(.day, from: date)
    }

    // MARK: - Period Grid

    private var periodScroll: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(periods, id: \.self) { period in
                    periodRow(period: period)
                    if period % 2 == 0 && period < 12 {
                        Divider().background(DesignTokens.border)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func periodRow(period: Int) -> some View {
        HStack(spacing: 0) {
            // Time label
            Text("\(period)")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(DesignTokens.textTertiary)
                .frame(width: 32, height: 44)

            // Day cells
            ForEach(days, id: \.self) { day in
                PeriodCell(
                    period: period,
                    day: day,
                    courses: viewModel.coursesFor(day: day, period: period, in: courses),
                    allDayCourses: courses.filter { $0.dayOfWeek == day },
                    viewModel: viewModel,
                    isCurrentDay: day == currentDayOfWeek
                )
            }
        }
        .background(period % 2 == 1 ? DesignTokens.background : DesignTokens.surface.opacity(0.5))
    }
}

// MARK: - Period Cell

struct PeriodCell: View {
    let period: Int
    let day: Int
    let courses: [Course]
    let allDayCourses: [Course]
    let viewModel: TimetableViewModel
    let isCurrentDay: Bool

    var body: some View {
        ZStack {
            if isCurrentDay {
                DesignTokens.primary.opacity(0.04)
            } else {
                Color.clear
            }

            if let course = courses.first,
               viewModel.courseSpan(course: course, at: period, in: allDayCourses) {
                VStack(alignment: .center, spacing: 1) {
                    Text(course.name)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(.white)
                    if period == course.startPeriod && !course.location.isEmpty {
                        Text(course.location)
                            .font(.system(size: 7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: course.colorHex))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusTag))
                .padding(1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
    }
}
