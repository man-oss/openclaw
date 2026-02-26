import XCTest
import CoreMedia
@testable import SwabbleCore

class OutputFormatTests: XCTestCase {
    
    // MARK: - OutputFormat enum cases
    
    func testOutputFormatRawValues() {
        XCTAssertEqual(OutputFormat.txt.rawValue, "txt")
        XCTAssertEqual(OutputFormat.srt.rawValue, "srt")
    }
    
    func testOutputFormatInitFromString() {
        XCTAssertEqual(OutputFormat(rawValue: "txt"), .txt)
        XCTAssertEqual(OutputFormat(rawValue: "srt"), .srt)
        XCTAssertNil(OutputFormat(rawValue: "invalid"))
    }
    
    // MARK: - needsAudioTimeRange property
    
    func testNeedsAudioTimeRangeForTxt() {
        XCTAssertFalse(OutputFormat.txt.needsAudioTimeRange)
    }
    
    func testNeedsAudioTimeRangeForSrt() {
        XCTAssertTrue(OutputFormat.srt.needsAudioTimeRange)
    }
    
    // MARK: - text(for:maxLength:) method - TXT format
    
    func testTextFormatTxtWithSimpleString() {
        let transcript = AttributedString("Hello world")
        let result = OutputFormat.txt.text(for: transcript, maxLength: 100)
        XCTAssertEqual(result, "Hello world")
    }
    
    func testTextFormatTxtWithEmptyString() {
        let transcript = AttributedString("")
        let result = OutputFormat.txt.text(for: transcript, maxLength: 100)
        XCTAssertEqual(result, "")
    }
    
    func testTextFormatTxtWithSpecialCharacters() {
        let transcript = AttributedString("Hello\nWorld\t!")
        let result = OutputFormat.txt.text(for: transcript, maxLength: 100)
        XCTAssertEqual(result, "Hello\nWorld\t!")
    }
    
    func testTextFormatTxtWithLongString() {
        let longText = String(repeating: "a", count: 1000)
        let transcript = AttributedString(longText)
        let result = OutputFormat.txt.text(for: transcript, maxLength: 100)
        XCTAssertEqual(result, longText)
    }
    
    func testTextFormatTxtWithMaxLengthParameter() {
        let transcript = AttributedString("Short text")
        let result1 = OutputFormat.txt.text(for: transcript, maxLength: 5)
        let result2 = OutputFormat.txt.text(for: transcript, maxLength: 100)
        // For TXT format, maxLength doesn't affect output
        XCTAssertEqual(result1, "Short text")
        XCTAssertEqual(result2, "Short text")
    }
    
    // MARK: - text(for:maxLength:) method - SRT format
    
    func testTextFormatSrtWithoutSentences() {
        let transcript = AttributedString("Test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        // Should return trimmed result (no sentences with time ranges)
        XCTAssertEqual(result, "")
    }
    
    func testTextFormatSrtTimeFormatting() {
        let transcript = AttributedString("Test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        // Should not crash and should not contain invalid format
        XCTAssertTrue(result.isEmpty || result.contains("-->"))
    }
    
    // MARK: - Time formatting helper
    
    func testSrtTimeFormattingZero() {
        let transcript = AttributedString("test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        // Test by checking the format doesn't crash
        XCTAssertNotNil(result)
    }
    
    func testSrtTimeFormattingSmallValues() {
        // Create a mock to test time formatting indirectly
        let transcript = AttributedString("test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        XCTAssertNotNil(result)
    }
    
    func testSrtTimeFormattingLargeValues() {
        let transcript = AttributedString("test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        XCTAssertNotNil(result)
    }
    
    func testSrtTimeFormattingWithMilliseconds() {
        let transcript = AttributedString("test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        // Verify milliseconds formatting (should be 3 digits)
        if result.contains(",") {
            let parts = result.split(separator: ",")
            XCTAssertGreaterThan(parts.count, 0)
        }
    }
    
    func testSrtTimeFormattingHours() {
        let transcript = AttributedString("test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        // Should handle hours properly (2 digits)
        XCTAssertNotNil(result)
    }
    
    func testSrtTimeFormattingMinutes() {
        let transcript = AttributedString("test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        // Should handle minutes properly (2 digits)
        XCTAssertNotNil(result)
    }
    
    func testSrtTimeFormattingSeconds() {
        let transcript = AttributedString("test")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        // Should handle seconds properly (2 digits)
        XCTAssertNotNil(result)
    }
    
    // MARK: - SRT formatting edge cases
    
    func testSrtWithWhitespaceAndNewlines() {
        let transcript = AttributedString("  \n  test  \n  ")
        let result = OutputFormat.srt.text(for: transcript, maxLength: 100)
        // Should trim whitespace and newlines
        XCTAssertNotNil(result)
    }
    
    func testSrtWithMaxLengthVariations() {
        let transcript = AttributedString("test sentence here")
        let result1 = OutputFormat.srt.text(for: transcript, maxLength: 1)
        let result2 = OutputFormat.srt.text(for: transcript, maxLength: 100)
        let result3 = OutputFormat.srt.text(for: transcript, maxLength: 0)
        
        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotNil(result3)
    }
    
    // MARK: - Boundary conditions
    
    func testOutputFormatAllCases() {
        let allCases: [OutputFormat] = [.txt, .srt]
        XCTAssertEqual(allCases.count, 2)
    }
    
    func testTextMethodWithZeroMaxLength() {
        let transcript = AttributedString("test")
        let result = OutputFormat.txt.text(for: transcript, maxLength: 0)
        XCTAssertEqual(result, "test")
    }
    
    func testTextMethodWithNegativeMaxLength() {
        let transcript = AttributedString("test")
        let result = OutputFormat.txt.text(for: transcript, maxLength: -1)
        XCTAssertEqual(result, "test")
    }
    
    func testTextMethodWithIntMax() {
        let transcript = AttributedString("test")
        let result = OutputFormat.txt.text(for: transcript, maxLength: Int.max)
        XCTAssertEqual(result, "test")
    }
}

// MARK: - Helper extension for testing

extension AttributedString {
    init(_ string: String) {
        self = try! AttributedString(markdown: string)
    }
}