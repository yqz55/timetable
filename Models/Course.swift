import Foundation
import SwiftData
import SwiftUI

@Model
final class Course {
    var id: UUID
    var name: String
    var teacher: String
    var location: String
    var dayOfWeek: Int          // 1=Monday ... 7=Sunday
    var startPeriod: Int        // 第几节课开始
    var duration: Int           // 持续几节课
    var colorHex: String        // 课程颜色
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        teacher: String = "",
        location: String = "",
        dayOfWeek: Int = 1,
        startPeriod: Int = 1,
        duration: Int = 2,
        colorHex: String = "#4A90D9",
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.teacher = teacher
        self.location = location
        self.dayOfWeek = dayOfWeek
        self.startPeriod = startPeriod
        self.duration = duration
        self.colorHex = colorHex
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var color: Color {
        Color(hex: colorHex)
    }

    static let defaultColors = [
        "#4A90D9", "#E74C3C", "#2ECC71", "#F39C12",
        "#9B59B6", "#1ABC9C", "#E67E22", "#3498DB",
        "#E91E63", "#00BCD4"
    ]

    static let weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]

    var weekdayName: String {
        guard (1...7).contains(dayOfWeek) else { return "" }
        return Self.weekdays[dayOfWeek - 1]
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        let rgb: UInt64 = UInt64(hex, radix: 16) ?? 0
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
