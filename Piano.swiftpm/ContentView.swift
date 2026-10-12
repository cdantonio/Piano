import SwiftUI

struct PianoNote: Identifiable {
    var id: String { "\(name)-\(frequency)" }
    let name: String
    let frequency: Double
    let isBlack: Bool
    let leadingWhiteKey: Int
}

struct ContentView: View {
    @State private var audio = PianoAudioEngine()

    private let whiteNotes: [PianoNote] = [
        PianoNote(name: "C", frequency: 261.63, isBlack: false, leadingWhiteKey: 0),
        PianoNote(name: "D", frequency: 293.66, isBlack: false, leadingWhiteKey: 1),
        PianoNote(name: "E", frequency: 329.63, isBlack: false, leadingWhiteKey: 2),
        PianoNote(name: "F", frequency: 349.23, isBlack: false, leadingWhiteKey: 3),
        PianoNote(name: "G", frequency: 392.00, isBlack: false, leadingWhiteKey: 4),
        PianoNote(name: "A", frequency: 440.00, isBlack: false, leadingWhiteKey: 5),
        PianoNote(name: "B", frequency: 493.88, isBlack: false, leadingWhiteKey: 6),
        PianoNote(name: "C", frequency: 523.25, isBlack: false, leadingWhiteKey: 7)
    ]

    private let blackNotes: [PianoNote] = [
        PianoNote(name: "C#", frequency: 277.18, isBlack: true, leadingWhiteKey: 0),
        PianoNote(name: "D#", frequency: 311.13, isBlack: true, leadingWhiteKey: 1),
        PianoNote(name: "F#", frequency: 369.99, isBlack: true, leadingWhiteKey: 3),
        PianoNote(name: "G#", frequency: 415.30, isBlack: true, leadingWhiteKey: 4),
        PianoNote(name: "A#", frequency: 466.16, isBlack: true, leadingWhiteKey: 5)
    ]

    var body: some View {
        VStack(spacing: 18) {
            Text("Piano")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            GeometryReader { proxy in
                let spacing: CGFloat = 3
                let keyWidth = (proxy.size.width - spacing * CGFloat(whiteNotes.count - 1)) / CGFloat(whiteNotes.count)
                let blackWidth = keyWidth * 0.62
                let blackHeight = proxy.size.height * 0.62

                ZStack(alignment: .topLeading) {
                    HStack(spacing: spacing) {
                        ForEach(whiteNotes) { note in
                            PianoKey(note: note, audio: audio)
                                .frame(width: keyWidth)
                        }
                    }

                    ForEach(blackNotes) { note in
                        PianoKey(note: note, audio: audio)
                            .frame(width: blackWidth, height: blackHeight)
                            .offset(x: CGFloat(note.leadingWhiteKey + 1) * (keyWidth + spacing) - blackWidth / 2 - spacing / 2)
                            .zIndex(1)
                    }
                }
            }
            .frame(maxWidth: 760)
            .frame(height: 310)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.96, blue: 0.94))
    }
}

private struct PianoKey: View {
    let note: PianoNote
    let audio: PianoAudioEngine

    @State private var isPressed = false

    var body: some View {
        RoundedRectangle(cornerRadius: note.isBlack ? 5 : 7, style: .continuous)
            .fill(fill)
            .overlay(alignment: .bottom) {
                Text(note.name)
                    .font(.system(size: note.isBlack ? 13 : 15, weight: .medium, design: .rounded))
                    .foregroundStyle(note.isBlack ? .white.opacity(0.78) : .black.opacity(0.58))
                    .padding(.bottom, note.isBlack ? 10 : 14)
            }
            .overlay(
                RoundedRectangle(cornerRadius: note.isBlack ? 5 : 7, style: .continuous)
                    .stroke(note.isBlack ? Color.black.opacity(0.45) : Color.black.opacity(0.13), lineWidth: 1)
            )
            .shadow(color: .black.opacity(note.isBlack ? 0.28 : 0.08), radius: note.isBlack ? 8 : 3, x: 0, y: note.isBlack ? 5 : 2)
            .scaleEffect(y: isPressed ? 0.985 : 1, anchor: .top)
            .animation(.easeOut(duration: 0.08), value: isPressed)
            .contentShape(Rectangle())
            .accessibilityLabel(note.name)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        audio.play(frequency: note.frequency)
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }

    private var fill: some ShapeStyle {
        if note.isBlack {
            return LinearGradient(
                colors: isPressed
                    ? [Color(red: 0.04, green: 0.05, blue: 0.05), Color(red: 0.16, green: 0.17, blue: 0.17)]
                    : [Color(red: 0.01, green: 0.015, blue: 0.015), Color(red: 0.09, green: 0.10, blue: 0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
        }

        return LinearGradient(
            colors: isPressed
                ? [Color(red: 0.86, green: 0.90, blue: 0.88), Color(red: 0.98, green: 0.99, blue: 0.97)]
                : [.white, Color(red: 0.91, green: 0.93, blue: 0.91)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
