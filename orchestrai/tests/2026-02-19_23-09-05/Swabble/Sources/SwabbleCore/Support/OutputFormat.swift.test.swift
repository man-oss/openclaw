import XCTest
import CoreMedia
import Foundation

@testable import SwabbleCore

final class OutputFormatTests: XCTestCase {
    
    // MARK: - needsAudioTimeRange Tests
    
    func test_needsAudioTimeRange_withSRT_returnsTrue() {
        XCTAssertTrue(OutputFormat.srt.needsAudioTimeRange)
    }
    
    func test_needsAudioTimeRange_withTXT_returnsFalse() {
        XCTAssertFalse(OutputFormat.txt.needsAudioTimeRange)
    }
    
    // MARK: - text(for:maxLength:) with TXT format
    
    func test_text_withTXT_returnsPlainText() {
        let transcript = AttributedString("Hello world")
        let result = OutputFormat.txt.text(for: transcript, maxLength: 100)
        XCTAssertEqual(result, "Hello world")
    }
    
    func test_text_withTXT_emptyTranscript_returnsEmptyString() {
        let transcript = AttributedString("")
        let result = OutputFormat.txt.text(for: transcript, maxLength: 100)
        XCTAssertEqual(result, "")
    }
    
    func test_text_withTXT_multilineTranscript_returnsAllCharacters() {
        let transcript = AttributedString("Line 1\nLine 2\nLine 3")
        let result = OutputFormat.txt.text(for: transcript, maxLength: 100)
        XCTAssertEqual(result, "Line 1\nLine 2\nLine 3")
    }
    
    // MARK: - text(for:maxLength:) with SRT format
    
    func test_text_withSRT_singleSentenceWithRange_returnsFormattedSRT() {
        let transcript = AttributedString("Hello world")
        let mockSegment = createMockAttributedStringWithTimeRange(
            text: "Hello world",
            startSeconds: 5.5,
            endSeconds: 7.75
        )
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 100)
        
        XCTAssertTrue(result.contains("1"))
        XCTAssertTrue(result.contains("00:00:05,500 --> 00:00:07,750"))
        XCTAssertTrue(result.contains("Hello world"))
    }
    
    func test_text_withSRT_multipleSentences_returnsFormattedSRTWithIndices() {
        let mockSegment = createMockAttributedStringWithMultipleSentences(
            sentences: [
                ("First", startSeconds: 0.0, endSeconds: 1.0),
                ("Second", startSeconds: 2.0, endSeconds: 3.0),
                ("Third", startSeconds: 4.0, endSeconds: 5.0)
            ]
        )
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 100)
        
        XCTAssertTrue(result.contains("1"))
        XCTAssertTrue(result.contains("2"))
        XCTAssertTrue(result.contains("3"))
        XCTAssertTrue(result.contains("00:00:00,000 --> 00:00:01,000"))
        XCTAssertTrue(result.contains("00:00:02,000 --> 00:00:03,000"))
        XCTAssertTrue(result.contains("00:00:04,000 --> 00:00:05,000"))
    }
    
    func test_text_withSRT_emptyTimeRange_isSkipped() {
        let mockSegment = createMockAttributedStringWithMixedTimeRanges(
            sentences: [
                (text: "First", hasTimeRange: true, startSeconds: 0.0, endSeconds: 1.0),
                (text: "NoTime", hasTimeRange: false, startSeconds: 0, endSeconds: 0),
                (text: "Third", hasTimeRange: true, startSeconds: 2.0, endSeconds: 3.0)
            ]
        )
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 100)
        
        XCTAssertTrue(result.contains("1"))
        XCTAssertTrue(result.contains("2"))
        XCTAssertFalse(result.contains("NoTime"))
    }
    
    func test_text_withSRT_timeFormattingWithMilliseconds() {
        let mockSegment = createMockAttributedStringWithTimeRange(
            text: "Test",
            startSeconds: 123.456,
            endSeconds: 125.789
        )
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 100)
        
        XCTAssertTrue(result.contains("00:02:03,456"))
        XCTAssertTrue(result.contains("00:02:05,789"))
    }
    
    func test_text_withSRT_timeFormattingWithHours() {
        let mockSegment = createMockAttributedStringWithTimeRange(
            text: "Long video",
            startSeconds: 3661.5,
            endSeconds: 3665.75
        )
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 100)
        
        XCTAssertTrue(result.contains("01:01:01,500"))
        XCTAssertTrue(result.contains("01:01:05,750"))
    }
    
    func test_text_withSRT_textWithWhitespaceIsTrimmed() {
        let mockSegment = createMockAttributedStringWithTimeRange(
            text: "   Trimmed   ",
            startSeconds: 0.0,
            endSeconds: 1.0
        )
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 100)
        
        XCTAssertTrue(result.contains("Trimmed"))
        XCTAssertFalse(result.contains("   Trimmed   "))
    }
    
    func test_text_withSRT_resultIsTrimmed() {
        let mockSegment = createMockAttributedStringWithTimeRange(
            text: "Content",
            startSeconds: 0.0,
            endSeconds: 1.0
        )
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 100)
        
        XCTAssertEqual(result.first?.isWhitespace, false)
        XCTAssertEqual(result.last?.isWhitespace, false)
    }
    
    func test_text_withSRT_noValidSentences_returnsEmptyAfterTrim() {
        let mockSegment = createMockAttributedStringWithEmptySentences()
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 100)
        
        XCTAssertEqual(result, "")
    }
    
    func test_text_withSRT_maxLengthIsRespected() {
        let mockSegment = createMockAttributedStringWithMaxLengthSentences(
            longText: "This is a very long sentence",
            maxLength: 15
        )
        
        let result = OutputFormat.srt.text(for: mockSegment, maxLength: 15)
        
        XCTAssertFalse(result.isEmpty)
    }
    
    func test_rawValue_srt() {
        XCTAssertEqual(OutputFormat.srt.rawValue, "srt")
    }
    
    func test_rawValue_txt() {
        XCTAssertEqual(OutputFormat.txt.rawValue, "txt")
    }
    
    func test_init_fromRawValue_srt() {
        let format = OutputFormat(rawValue: "srt")
        XCTAssertEqual(format, .srt)
    }
    
    func test_init_fromRawValue_txt() {
        let format = OutputFormat(rawValue: "txt")
        XCTAssertEqual(format, .txt)
    }
    
    func test_init_fromRawValue_invalid() {
        let format = OutputFormat(rawValue: "invalid")
        XCTAssertNil(format)
    }
    
    // MARK: - Helper Methods
    
    private func createMockAttributedStringWithTimeRange(
        text: String,
        startSeconds: TimeInterval,
        endSeconds: TimeInterval
    ) -> AttributedString {
        var result = AttributedString(text)
        
        let timeRange = CMTimeRange(
            start: CMTime(seconds: startSeconds, preferredTimescale: 1000),
            end: CMTime(seconds: endSeconds, preferredTimescale: 1000)
        )
        
        return result
    }
    
    private func createMockAttributedStringWithMultipleSentences(
        sentences: [(String, TimeInterval, TimeInterval)]
    ) -> AttributedString {
        var result = AttributedString("")
        for (text, start, end) in sentences {
            if !result.characters.isEmpty {
                result.append(AttributedString(" "))
            }
            result.append(AttributedString(text))
        }
        return result
    }
    
    private func createMockAttributedStringWithMixedTimeRanges(
        sentences: [(text: String, hasTimeRange: Bool, startSeconds: TimeInterval, endSeconds: TimeInterval)]
    ) -> AttributedString {
        var result = AttributedString("")
        for (text, _, _, _) in sentences {
            if !result.characters.isEmpty {
                result.append(AttributedString(" "))
            }
            result.append(AttributedString(text))
        }
        return result
    }
    
    private func createMockAttributedStringWithEmptySentences() -> AttributedString {
        return AttributedString("")
    }
    
    private func createMockAttributedStringWithMaxLengthSentences(
        longText: String,
        maxLength: Int
    ) -> AttributedString {
        return AttributedString(longText)
    }
}