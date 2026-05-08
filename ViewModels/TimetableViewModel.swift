import SwiftUI
import SwiftData
import Vision
import UniformTypeIdentifiers

@Observable
final class TimetableViewModel {
    var currentWeekStart: Date? = nil
    var weeklyCourses: [Int: [Course]] = [:]
    var isParsing = false
    var parseError: String? = nil

    private let maxPeriod = 12

    func coursesFor(day: Int, period: Int, in courses: [Course]) -> [Course] {
        courses.filter { course in
            course.dayOfWeek == day &&
            period >= course.startPeriod &&
            period < course.startPeriod + course.duration
        }
    }

    func courseSpan(course: Course, at period: Int, in dayCourses: [Course]) -> Bool {
        guard course.dayOfWeek > 0 else { return false }
        let sameDayCourses = dayCourses.filter { $0.dayOfWeek == course.dayOfWeek }
            .sorted { $0.startPeriod < $1.startPeriod }

        if period == course.startPeriod { return true }
        if period > course.startPeriod && period < course.startPeriod + course.duration {
            return !sameDayCourses.contains { other in
                other.id != course.id &&
                other.startPeriod == period
            }
        }
        return false
    }
}
