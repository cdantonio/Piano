import AVFoundation

final class PianoAudioEngine {
    private let engine = AVAudioEngine()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private var players: [AVAudioPlayerNode] = []
    private var audioSessionIsConfigured = false

    func play(frequency: Double) {
        configureAudioSession()
        startEngine()

        let player = AVAudioPlayerNode()
        let buffer = makeBuffer(frequency: frequency)

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        players.append(player)

        player.scheduleBuffer(buffer, at: nil, options: []) { [weak self, weak player] in
            guard let self, let player else { return }

            DispatchQueue.main.async {
                player.stop()
                self.engine.detach(player)
                self.players.removeAll { $0 === player }
            }
        }

        player.play()
    }

    private func configureAudioSession() {
        guard !audioSessionIsConfigured else { return }

        #if os(iOS)
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Unable to configure audio session: \(error)")
        }
        #endif

        audioSessionIsConfigured = true
    }

    private func startEngine() {
        guard !engine.isRunning else { return }

        do {
            try engine.start()
        } catch {
            print("Unable to start audio engine: \(error)")
        }
    }

    private func makeBuffer(frequency: Double) -> AVAudioPCMBuffer {
        let sampleRate = format.sampleRate
        let duration = 1.35
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!

        buffer.frameLength = frameCount

        guard let samples = buffer.floatChannelData?[0] else {
            return buffer
        }

        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let envelope = amplitudeEnvelope(at: time, duration: duration)
            let tone = pianoTone(frequency: frequency, time: time)
            samples[frame] = Float(tone * envelope * 0.55)
        }

        return buffer
    }

    private func pianoTone(frequency: Double, time: Double) -> Double {
        let fundamental = sin(2 * .pi * frequency * time)
        let second = 0.34 * sin(2 * .pi * frequency * 2.01 * time)
        let third = 0.16 * sin(2 * .pi * frequency * 3.02 * time)
        let fourth = 0.08 * sin(2 * .pi * frequency * 4.04 * time)

        return fundamental + second + third + fourth
    }

    private func amplitudeEnvelope(at time: Double, duration: Double) -> Double {
        let attack = 0.012

        if time < attack {
            return time / attack
        }

        let decay = exp(-3.8 * (time - attack))
        let releaseStart = duration * 0.78

        if time > releaseStart {
            let releaseProgress = min((time - releaseStart) / (duration - releaseStart), 1)
            return decay * (1 - releaseProgress)
        }

        return decay
    }
}
