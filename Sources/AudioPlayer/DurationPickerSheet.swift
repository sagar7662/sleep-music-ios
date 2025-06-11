import SwiftUI

struct DurationPickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedDuration: TimeInterval
    @State private var selectedIndex: Int = 0

    let durations: [TimeInterval]

    var body: some View {
        VStack(spacing: 0) {

            // Toolbar
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)

                Spacer()

                Button("Done") {
                    selectedDuration = durations[selectedIndex]
                    isPresented = false
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            VStack(spacing: 20) {
                Text("Duration: \(formatDuration(durations[selectedIndex]))")
                    .font(.title3)
                    .bold()

                Slider(
                    value: Binding(
                        get: { Double(selectedIndex) },
                        set: { newValue in
                            selectedIndex = Int(round(newValue))
                        }
                    ),
                    in: 0...Double(durations.count - 1),
                    step: 1
                )
                .accentColor(.blue)
                .padding(.horizontal)

                HStack {
                    ForEach(0..<durations.count, id: \.self) { index in
                        Text("\(Int(durations[index] / 60))m")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 20)
        }
        .padding(.bottom, 10)
        .onAppear {
            // Initialize index based on current selected duration
            if let currentIndex = durations.firstIndex(of: selectedDuration) {
                selectedIndex = currentIndex
            } else {
                selectedIndex = 0
            }
        }
    }

    private func formatDuration(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        return "\(minutes) minutes"
    }
}
