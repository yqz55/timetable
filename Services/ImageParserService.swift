import UIKit
import Vision

final class ImageParserService {
    static let shared = ImageParserService()

    private init() {}

    func recognizeCourses(from image: UIImage) async throws -> [RecognizedCourse] {
        guard let cgImage = image.cgImage else {
            throw ParserError.invalidImage
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let observations = request.results else {
            throw ParserError.noTextFound
        }

        let recognizedTexts = observations
            .compactMap { $0.topCandidates(1).first?.string }

        return parseTimetable(from: recognizedTexts, imageSize: image.size)
    }

    private func parseTimetable(from lines: [String], imageSize: CGSize) -> [RecognizedCourse] {
        var courses: [RecognizedCourse] = []

        // Simple heuristic parsing: look for patterns like course name, location, time
        // In a real app, this would use more sophisticated layout analysis
        for line in lines {
            let components = line
                .components(separatedBy: CharacterSet.whitespacesAndNewlines)
                .filter { !$0.isEmpty }

            guard components.count >= 2 else { continue }

            // Try to extract course info based on patterns
            // This is a simplified placeholder - real OCR would need spatial analysis
            if let course = tryParseLine(components) {
                courses.append(course)
            }
        }

        return courses
    }

    private func tryParseLine(_ components: [String]) -> RecognizedCourse? {
        // Basic heuristic: look for recognizable patterns
        let text = components.joined(separator: " ")

        // Check if the text looks like a course entry
        // (contains Chinese characters suggesting course content)
        let chineseRange = text.range(of: "[\\u4e00-\\u9fff]{2,}", options: .regularExpression)
        guard chineseRange != nil else { return nil }

        return RecognizedCourse(
            name: text,
            teacher: "",
            location: "",
            dayOfWeek: 1,
            startPeriod: 1,
            duration: 2
        )
    }
}

enum ParserError: LocalizedError {
    case invalidImage
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "图片无效，请重试"
        case .noTextFound:
            return "未能识别到文字，请确保图片清晰"
        }
    }
}
