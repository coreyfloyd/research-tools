import Foundation
import TranscribeKit

let usage = """
Usage: transcribe INPUT --output PATH [--format markdown|json] [--language BCP-47]
"""

@main
struct TranscribeCommand {
    static func main() async {
        do {
            let options = try CommandLineOptions.parse(Array(CommandLine.arguments.dropFirst()))
            let document = try await AppleSpeechTranscriber.transcribe(
                input: options.input, localeIdentifier: options.localeIdentifier
            )
            let data: Data
            switch options.format {
            case .markdown: data = Data(document.markdown().utf8)
            case .json: data = try document.jsonData()
            }
            try data.write(to: options.output, options: .atomic)
        } catch {
            FileHandle.standardError.write(Data("transcribe: \(error)\n\(usage)".utf8))
            Foundation.exit(2)
        }
    }
}
