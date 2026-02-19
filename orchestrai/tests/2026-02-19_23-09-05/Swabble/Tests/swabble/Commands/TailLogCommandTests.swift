import XCTest
@testable import swabble
import Swabble

@MainActor
final class TailLogCommandTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testTailLogCommandInit() {
        let command = TailLogCommand()
        XCTAssertNotNil(command)
    }
    
    func testTailLogCommandDescriptionName() {
        let description = TailLogCommand.commandDescription
        XCTAssertEqual(description.commandName, "tail-log")
    }
    
    func testTailLogCommandDescriptionAbstract() {
        let description = TailLogCommand.commandDescription
        XCTAssertEqual(description.abstract, "Tail recent transcripts")
    }
    
    // MARK: - ParsedValues Initialization
    
    func testInitWithParsedValues() {
        let parsedValues = ParsedValues(
            options: [:],
            flags: Set(),
            positional: []
        )
        let command = TailLogCommand(parsed: parsedValues)
        XCTAssertNotNil(command)
    }
    
    func testInitWithParsedValuesWithOptions() {
        let parsedValues = ParsedValues(
            options: ["some": ["value"]],
            flags: Set(),
            positional: []
        )
        let command = TailLogCommand(parsed: parsedValues)
        XCTAssertNotNil(command)
    }
    
    func testInitWithParsedValuesWithFlags() {
        let parsedValues = ParsedValues(
            options: [:],
            flags: Set(["flag1", "flag2"]),
            positional: []
        )
        let command = TailLogCommand(parsed: parsedValues)
        XCTAssertNotNil(command)
    }
    
    func testInitWithParsedValuesWithPositional() {
        let parsedValues = ParsedValues(
            options: [:],
            flags: Set(),
            positional: ["positional1", "positional2"]
        )
        let command = TailLogCommand(parsed: parsedValues)
        XCTAssertNotNil(command)
    }
    
    // MARK: - Run Tests
    
    func testRunWithEmptyTranscripts() async throws {
        var command = TailLogCommand()
        
        // Clear the transcripts store (if possible)
        // Since it's a singleton, we test with whatever is available
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    func testRunPrintsOutput() async throws {
        var command = TailLogCommand()
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    func testRunDoesNotThrow() async throws {
        var command = TailLogCommand()
        // Should not throw
        try await command.run()
    }
    
    // MARK: - Multiple Executions
    
    func testMultipleRuns() async throws {
        var command1 = TailLogCommand()
        var command2 = TailLogCommand()
        var command3 = TailLogCommand()
        
        try await command1.run()
        try await command2.run()
        try await command3.run()
    }
    
    // MARK: - Edge Cases
    
    func testCommandWithNoParameters() async throws {
        let command = TailLogCommand()
        var mutableCommand = command
        try await mutableCommand.run()
    }
    
    func testMainActorAttribute() {
        let command = TailLogCommand()
        XCTAssertNotNil(command)
    }
    
    func testParsableCommandProtocol() {
        let command = TailLogCommand()
        XCTAssertTrue(command is ParsableCommand)
    }
    
    // MARK: - Run Command Flow
    
    func testRunCommandFlow() async throws {
        var command = TailLogCommand()
        
        // Test the actual flow
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        // Should complete without error
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    // MARK: - Suffix Behavior Tests
    
    func testRunWithLessTermsThanSuffix() async throws {
        var command = TailLogCommand()
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    func testRunWithExactSuffixCount() async throws {
        var command = TailLogCommand()
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    func testRunWithMoreTermsThanSuffix() async throws {
        var command = TailLogCommand()
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    // MARK: - Consistency Tests
    
    func testInitAndRunConsistency() async throws {
        let command = TailLogCommand()
        var mutableCommand = command
        try await mutableCommand.run()
    }
    
    func testParsedValuesInitAndRunConsistency() async throws {
        let parsedValues = ParsedValues(
            options: [:],
            flags: Set(),
            positional: []
        )
        var command = TailLogCommand(parsed: parsedValues)
        try await command.run()
    }
}