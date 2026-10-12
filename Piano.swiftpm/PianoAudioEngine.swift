import AVFoundation
import Foundation

final class PianoAudioEngine: NSObject, AVAudioPlayerDelegate {
    private let sampleRate = 44_100
    private let duration = 1.0
    private var players: [AVAudioPlayer] = []
    private var audioSessionIsConfigured = false

    func play(frequency: Double) {
        configureAudioSession()

        do {
            let data = makeWAVData(frequency: frequency)
            let player = try AVAudioPlayer(data: data)

            player.delegate = self
            player.volume = 1
            player.prepareToPlay()
            players.append(player)

            if !player.play() {
                players.removeAll { $0 === player }
                print("Unable to start note playback.")
            }
        } catch {
            print("Unable to play note: \(error)")
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        players.removeAll { $0 === player }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        players.removeAll { $0 === player }
        print("Unable to decode note audio: \(error?.localizedDescription ?? "Unknown error")")
    }

    private func configureAudioSession() {
        guard !audioSessionIsConfigured else { return }

        #if os(iOS)
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            audioSessionIsConfigured = true
        } catch {
            print("Unable to configure audio session: \(error)")
        }
        #else
        audioSessionIsConfigured = true
        #endif
    }

    private func makeWAVData(frequency: Double) -> Data {
        let frameCount = Int(Double(sampleRate) * duration)
        var samples = Data(capacity: frameCount * 2)

        for frame in 0..<frameCount {
            let time = Double(frame) / Double(sampleRate)
            let envelope = amplitudeEnvelope(at: time)
            let tone = pianoTone(frequency: frequency, time: time)
            let sample = Int16(max(-1, min(1, tone * envelope * 0.45)) * Double(Int16.max))

            appendLittleEndian(sample, to: &samples)
        }

        var wavData = wavHeader(dataByteCount: samples.count)
        wavData.append(samples)

        return wavData
    }

    private func wavHeader(dataByteCount: Int) -> Data {
        var data = Data()
        let byteRate = sampleRate * 2
        let riffSize = UInt32(36 + dataByteCount)

        data.append(contentsOf: "RIFF".utf8)
        appendLittleEndian(riffSize, to: &data)
        data.append(contentsOf: "WAVE".utf8)
        data.append(contentsOf: "fmt ".utf8)
        appendLittleEndian(UInt32(16), to: &data)
        appendLittleEndian(UInt16(1), to: &data)
        appendLittleEndian(UInt16(1), to: &data)
        appendLittleEndian(UInt32(sampleRate), to: &data)
        appendLittleEndian(UInt32(byteRate), to: &data)
        appendLittleEndian(UInt16(2), to: &data)
        appendLittleEndian(UInt16(16), to: &data)
        data.append(contentsOf: "data".utf8)
        appendLittleEndian(UInt32(dataByteCount), to: &data)

        return data
    }

    private func pianoTone(frequency: Double, time: Double) -> Double {
        let fundamental = sin(2 * .pi * frequency * time)
        let second = 0.32 * sin(2 * .pi * frequency * 2.01 * time)
        let third = 0.14 * sin(2 * .pi * frequency * 3.02 * time)
        let fourth = 0.07 * sin(2 * .pi * frequency * 4.04 * time)

        return fundamental + second + third + fourth
    }

    private func amplitudeEnvelope(at time: Double) -> Double {
        let attack = 0.012

        if time < attack {
            return time / attack
        }

        return exp(-4.2 * (time - attack))
    }

    private func appendLittleEndian(_ value: UInt16, to data: inout Data) {
        data.append(UInt8(value & 0xff))
        data.append(UInt8((value >> 8) & 0xff))
    }

    private func appendLittleEndian(_ value: Int16, to data: inout Data) {
        appendLittleEndian(UInt16(bitPattern: value), to: &data)
    }

    private func appendLittleEndian(_ value: UInt32, to data: inout Data) {
        data.append(UInt8(value & 0xff))
        data.append(UInt8((value >> 8) & 0xff))
        data.append(UInt8((value >> 16) & 0xff))
        data.append(UInt8((value >> 24) & 0xff))
    }
}
