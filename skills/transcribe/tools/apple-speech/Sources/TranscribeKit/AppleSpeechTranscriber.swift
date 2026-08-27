import AVFoundation
import CoreMedia
import Foundation
import Speech

@available(macOS 26.0, *)
public struct AppleSpeechTranscriber {
    public static let engine = "apple-speechanalyzer/macOS26"

    public enum TranscriptionError: Error, CustomStringConvertible {
        case unsupportedLocale(String)
        case noAudioTrack(URL)
        case exportFailed(String)

        public var description: String {
            switch self {
            case let .unsupportedLocale(locale): return "SpeechTranscriber does not support locale \(locale)"
            case let .noAudioTrack(url): return "no readable audio track in \(url.path)"
            case let .exportFailed(detail): return "could not extract audio: \(detail)"
            }
        }
    }

    public static func transcribe(input: URL, localeIdentifier: String) async throws -> TranscriptDocument {
        let locale = Locale(identifier: localeIdentifier)
        let transcriber = SpeechTranscriber(
            locale: locale,
            transcriptionOptions: [],
            reportingOptions: [.alternativeTranscriptions],
            attributeOptions: [.audioTimeRange, .transcriptionConfidence]
        )
        let supported = await SpeechTranscriber.supportedLocales
        guard supported.contains(where: { $0.identifier(.bcp47) == locale.identifier(.bcp47) }) else {
            throw TranscriptionError.unsupportedLocale(localeIdentifier)
        }
        if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await request.downloadAndInstall()
        }

        let prepared = try await PreparedAudio(input: input)
        defer { prepared.cleanup() }
        let audioFile = try AVAudioFile(forReading: prepared.url)
        let collector = Task { () throws -> [SpeechTranscriber.Result] in
            var results: [SpeechTranscriber.Result] = []
            for try await result in transcriber.results { results.append(result) }
            return results
        }
        let analyzer = SpeechAnalyzer(modules: [transcriber])
        _ = try await analyzer.analyzeSequence(from: audioFile)
        try await analyzer.finalizeAndFinishThroughEndOfInput()
        let segments = try await collector.value.enumerated().map { _, result in
            let confidences = result.text.runs.compactMap {
                $0[AttributeScopes.SpeechAttributes.ConfidenceAttribute.self]
            }
            return TranscriptSegment(
                startSeconds: CMTimeGetSeconds(result.range.start),
                endSeconds: CMTimeGetSeconds(result.range.end),
                text: String(result.text.characters).trimmingCharacters(in: .whitespacesAndNewlines),
                meanConfidence: confidences.isEmpty ? nil : confidences.reduce(0, +) / Double(confidences.count)
            )
        }.filter { !$0.text.isEmpty }
        return TranscriptDocument(source: input.path, locale: locale.identifier(.bcp47), engine: engine, segments: segments)
    }
}

@available(macOS 26.0, *)
private struct PreparedAudio {
    let url: URL
    let temporary: Bool

    init(input: URL) async throws {
        if (try? AVAudioFile(forReading: input)) != nil {
            url = input
            temporary = false
            return
        }
        let asset = AVURLAsset(url: input)
        guard try await !asset.loadTracks(withMediaType: .audio).isEmpty else {
            throw AppleSpeechTranscriber.TranscriptionError.noAudioTrack(input)
        }
        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent("transcribe-\(UUID().uuidString).m4a")
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw AppleSpeechTranscriber.TranscriptionError.exportFailed("could not create exporter")
        }
        do {
            try await exporter.export(to: output, as: .m4a)
        } catch {
            throw AppleSpeechTranscriber.TranscriptionError.exportFailed(error.localizedDescription)
        }
        url = output
        temporary = true
    }

    func cleanup() {
        if temporary { try? FileManager.default.removeItem(at: url) }
    }
}
