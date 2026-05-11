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
        colorHex: String = "#2D5E3A",
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
        "#2D5E3A", "#4A8C5E", "#7AB890", "#9BC4A3",
        "#5B8C5A", "#3D6B4F", "#8B7E74", "#C4A882",
        "#6B8F71", "#A3B5A6"
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

enum DesignTokens {
    static let background = Color(hex: "#F5F3EE")
    static let surface = Color(hex: "#FFFFFF")
    static let primary = Color(hex: "#2D5E3A")
    static let secondary = Color(hex: "#4A8C5E")
    static let textPrimary = Color(hex: "#1B3A28")
    static let textSecondary = Color(hex: "#4A6B52")
    static let textTertiary = Color(hex: "#9AB0A0")
    static let border = Color(hex: "#D5D9D3")
    static let success = Color(hex: "#34C759")
    static let warning = Color(hex: "#FF9500")

    static let radiusCard: CGFloat = 6
    static let radiusTag: CGFloat = 4
    static let shadowSm: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (.black.opacity(0.04), 3, 0, 1)
}
