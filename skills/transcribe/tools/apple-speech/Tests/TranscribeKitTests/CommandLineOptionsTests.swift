import Foundation
import Testing
@testable import TranscribeKit

struct CommandLineOptionsTests {
    @Test func parsesAnExplicitMarkdownInvocation() throws {
        let options = try CommandLineOptions.parse([
            "/tmp/interview.mp4", "--output", "/tmp/interview.md", "--format", "markdown", "--language", "en-GB"
        ])

        #expect(options.input.path == "/tmp/interview.mp4")
        #expect(options.output.path == "/tmp/interview.md")
        #expect(options.format == .markdown)
        #expect(options.localeIdentifier == "en-GB")
    }

    @Test func rejectsAnUnknownFormat() {
        #expect(throws: CommandLineOptions.ParseError.self) {
            try CommandLineOptions.parse(["input.mp3", "--output", "out.txt", "--format", "text"])
        }
    }
}
