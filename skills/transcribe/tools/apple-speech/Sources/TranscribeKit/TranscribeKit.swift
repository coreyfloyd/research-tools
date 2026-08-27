import Foundation

public struct TranscriptSegment: Codable, Equatable, Sendable {
    public let startSeconds: Double
    public let endSeconds: Double
    public let text: String
    public let meanConfidence: Double?

    public init(startSeconds: Double, endSeconds: Double, text: String, meanConfidence: Double?) {
        self.startSeconds = startSeconds
        self.endSeconds = endSeconds
        self.text = text
        self.meanConfidence = meanConfidence
    }
}

public struct TranscriptDocument: Codable, Equatable, Sendable {
    public let source: String
    public let locale: String
    public let engine: String
    public let segments: [TranscriptSegment]

    public init(source: String, locale: String, engine: String, segments: [TranscriptSegment]) {
        self.source = source
        self.locale = locale
        self.engine = engine
        self.segments = segments
    }

    public func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    public func markdown() -> String {
        let frontmatter = [
            "---",
            "source: \"\(yamlQuoted(source))\"",
            "locale: \"\(yamlQuoted(locale))\"",
            "engine: \"\(yamlQuoted(engine))\"",
            "transcript_format: timestamped",
            "---",
            "",
            "## Transcript",
            "",
        ]
        let lines = segments.map { "[\(timestamp($0.startSeconds))] \($0.text)" }
        return (frontmatter + lines + [""]).joined(separator: "\n")
    }

    private func yamlQuoted(_ value: String) -> String {
        value.unicodeScalars.map { scalar in
            switch scalar.value {
            case 92: return "\\\\"
            case 34: return "\\\""
            case 13: return "\\r"
            case 10: return "\\n"
            default: return String(scalar)
            }
        }.joined()
    }

    private func timestamp(_ seconds: Double) -> String {
        let total = max(0, Int(seconds.rounded(.down)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

public enum TranscriptFormat: String, Sendable {
    case markdown
    case json
}

public struct CommandLineOptions: Sendable {
    public enum ParseError: Error, Equatable, CustomStringConvertible {
        case usage(String)

        public var description: String {
            switch self {
            case let .usage(message): return message
            }
        }
    }

    public let input: URL
    public let output: URL
    public let format: TranscriptFormat
    public let localeIdentifier: String

    public static func parse(_ arguments: [String]) throws -> Self {
        guard let first = arguments.first, !first.hasPrefix("-") else {
            throw ParseError.usage("missing input file")
        }
        var output: String?
        var format: TranscriptFormat = .markdown
        var localeIdentifier = "en-US"
        var index = 1
        while index < arguments.count {
            let option = arguments[index]
            guard index + 1 < arguments.count else {
                throw ParseError.usage("missing value for \(option)")
            }
            let value = arguments[index + 1]
            switch option {
            case "--output": output = value
            case "--format":
                guard let parsed = TranscriptFormat(rawValue: value) else {
                    throw ParseError.usage("unsupported format: \(value)")
                }
                format = parsed
            case "--language": localeIdentifier = value
            default: throw ParseError.usage("unknown option: \(option)")
            }
            index += 2
        }
        guard let output else { throw ParseError.usage("missing --output PATH") }
        return Self(
            input: URL(fileURLWithPath: first),
            output: URL(fileURLWithPath: output),
            format: format,
            localeIdentifier: localeIdentifier
        )
    }
}
