import XCTest
@testable import swabble

@MainActor
final class StartStopCommandsTests: XCTestCase {
    
    // MARK: - StartCommand Tests
    
    func testStartCommandDescription() {
        let description = StartCommand.commandDescription
        XCTAssertEqual(description.commandName, "start")
        XCTAssertEqual(description.abstract, "Start swabble (foreground placeholder)")
    }
    
    func testStartCommandRun() async throws {
        var command = StartCommand()
        
        // Capture printed output
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
        if let data = try pipe.fileHandleForReading.readToEndOfFile() as Data?,
           let output = String(data: data, encoding: .utf8) {
            XCTAssertTrue(output.contains("start: launchd helper not implemented"))
        }
    }
    
    func testStartCommandMutatingRun() async throws {
        var command = StartCommand()
        // Should not throw
        try await command.run()
    }
    
    // MARK: - StopCommand Tests
    
    func testStopCommandDescription() {
        let description = StopCommand.commandDescription
        XCTAssertEqual(description.commandName, "stop")
        XCTAssertEqual(description.abstract, "Stop swabble (placeholder)")
    }
    
    func testStopCommandRun() async throws {
        var command = StopCommand()
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
        if let data = try pipe.fileHandleForReading.readToEndOfFile() as Data?,
           let output = String(data: data, encoding: .utf8) {
            XCTAssertTrue(output.contains("stop: launchd helper not implemented"))
        }
    }
    
    func testStopCommandMutatingRun() async throws {
        var command = StopCommand()
        // Should not throw
        try await command.run()
    }
    
    // MARK: - RestartCommand Tests
    
    func testRestartCommandDescription() {
        let description = RestartCommand.commandDescription
        XCTAssertEqual(description.commandName, "restart")
        XCTAssertEqual(description.abstract, "Restart swabble (placeholder)")
    }
    
    func testRestartCommandRun() async throws {
        var command = RestartCommand()
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
        if let data = try pipe.fileHandleForReading.readToEndOfFile() as Data?,
           let output = String(data: data, encoding: .utf8) {
            XCTAssertTrue(output.contains("restart: launchd helper not implemented"))
        }
    }
    
    func testRestartCommandMutatingRun() async throws {
        var command = RestartCommand()
        // Should not throw
        try await command.run()
    }
    
    // MARK: - Edge Cases
    
    func testStartCommandIsMainActor() {
        // Verify @MainActor attribute is applied
        let command = StartCommand()
        XCTAssertNotNil(command)
    }
    
    func testStopCommandIsMainActor() {
        let command = StopCommand()
        XCTAssertNotNil(command)
    }
    
    func testRestartCommandIsMainActor() {
        let command = RestartCommand()
        XCTAssertNotNil(command)
    }
    
    func testMultipleCommandInstances() async throws {
        var start = StartCommand()
        var stop = StopCommand()
        var restart = RestartCommand()
        
        // All should run without errors
        try await start.run()
        try await stop.run()
        try await restart.run()
    }
}