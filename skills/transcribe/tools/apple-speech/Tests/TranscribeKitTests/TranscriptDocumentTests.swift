import Foundation
import Testing
@testable import TranscribeKit

struct TranscriptDocumentTests {
    private let document = TranscriptDocument(
        source: "/tmp/example.m4a",
        locale: "en-US",
        engine: "apple-speechanalyzer/macOS26",
        segments: [
            TranscriptSegment(
                startSeconds: 1.25,
                endSeconds: 3.5,
                text: "Hello world.",
                meanConfidence: 0.93
            )
        ]
    )

    @Test func markdownIncludesProvenanceAndTimestampedSegments() {
        let markdown = document.markdown()

        #expect(markdown.contains("source: \"/tmp/example.m4a\""))
        #expect(markdown.contains("locale: \"en-US\""))
        #expect(markdown.contains("engine: \"apple-speechanalyzer/macOS26\""))
        #expect(markdown.contains("[00:01] Hello world."))
    }

    @Test func jsonRoundTripsTheTranscriptContract() throws {
        let data = try document.jsonData()
        let decoded = try JSONDecoder().decode(TranscriptDocument.self, from: data)

        #expect(decoded == document)
    }

    @Test func markdownEscapesFrontmatterControlCharacters() {
        let hostile = TranscriptDocument(
            source: "clip\"\nattacker: true",
            locale: "en-US\r\nother: value",
            engine: "engine",
            segments: []
        )

        let markdown = hostile.markdown()
        #expect(markdown.contains("source: \"clip\\\"\\nattacker: true\""))
        #expect(markdown.contains("locale: \"en-US\\r\\nother: value\""))
    }
}
