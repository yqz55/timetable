import SwiftUI
import PhotosUI
import Vision

struct ImageImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var importedImage: UIImage?
    @State private var isProcessing = false
    @State private var recognizedCourses: [RecognizedCourse] = []
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = importedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 1)
                        )

                    if isProcessing {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("正在识别课表...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else if !recognizedCourses.isEmpty {
                        List {
                            Section("识别结果 (\(recognizedCourses.count) 门课程)") {
                                ForEach(recognizedCourses.indices, id: \.self) { index in
                                    RecognizedCourseRow(course: $recognizedCourses[index])
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                } else {
                    VStack(spacing: 24) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("选择一张课表图片")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("支持识别课程名称、时间、地点和教师信息")
                            .font(.caption)
                            .foregroundStyle(.tertiary)

                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images
                        ) {
                            Label("选择图片", systemImage: "photo.badge.plus")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 60)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("图片导入")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if !recognizedCourses.isEmpty {
                        Button("导入 \(recognizedCourses.count) 门课") {
                            importCourses()
                        }
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }
                loadAndRecognizeImage(from: newItem)
            }
            .alert("识别失败", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "未知错误")
            }
        }
    }

    private func loadAndRecognizeImage(from item: PhotosPickerItem) {
        Task {
            isProcessing = true
            recognizedCourses = []
            errorMessage = nil

            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                errorMessage = "无法加载图片"
                showError = true
                isProcessing = false
                return
            }

            await MainActor.run { importedImage = image }

            do {
                let courses = try await ImageParserService.shared.recognizeCourses(from: image)
                await MainActor.run {
                    recognizedCourses = courses
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isProcessing = false
                }
            }
        }
    }

    private func importCourses() {
        for recognized in recognizedCourses {
            let course = Course(
                name: recognized.name,
                teacher: recognized.teacher,
                location: recognized.location,
                dayOfWeek: recognized.dayOfWeek,
                startPeriod: recognized.startPeriod,
                duration: recognized.duration,
                colorHex: Course.defaultColors.randomElement() ?? "#4A90D9"
            )
            modelContext.insert(course)
        }
        dismiss()
    }
}

struct RecognizedCourse {
    var name: String
    var teacher: String
    var location: String
    var dayOfWeek: Int
    var startPeriod: Int
    var duration: Int
}

struct RecognizedCourseRow: View {
    @Binding var course: RecognizedCourse

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField("课程名称", text: $course.name)
                    .font(.body)
                    .fontWeight(.medium)

                Picker("", selection: $course.dayOfWeek) {
                    ForEach(1...7, id: \.self) { day in
                        Text(Course.weekdays[day - 1]).tag(day)
                    }
                }
                .labelsHidden()
            }

            HStack {
                TextField("教师", text: $course.teacher)
                TextField("地点", text: $course.location)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack {
                Picker("开始节次", selection: $course.startPeriod) {
                    ForEach(1...12, id: \.self) { Text("\($0)").tag($0) }
                }
                Stepper("持续 \(course.duration) 节", value: $course.duration, in: 1...6)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
