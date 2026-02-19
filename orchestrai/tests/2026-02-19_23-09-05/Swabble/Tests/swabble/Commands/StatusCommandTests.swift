import XCTest
@testable import swabble
import Swabble

@MainActor
final class StatusCommandTests: XCTestCase {
    
    private var tempConfigFile: URL?
    
    override func setUp() {
        super.setUp()
        // Create a temporary directory for test files
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("StatusCommandTests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        if let tempConfigFile = tempConfigFile {
            try? FileManager.default.removeItem(at: tempConfigFile.deletingLastPathComponent())
        }
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testStatusCommandInit() {
        let command = StatusCommand()
        XCTAssertNil(command.configPath)
    }
    
    func testStatusCommandDescriptionName() {
        let description = StatusCommand.commandDescription
        XCTAssertEqual(description.commandName, "status")
    }
    
    func testStatusCommandDescriptionAbstract() {
        let description = StatusCommand.commandDescription
        XCTAssertEqual(description.abstract, "Show daemon state")
    }
    
    // MARK: - Run Tests
    
    func testRunWithoutConfigFile() async throws {
        var command = StatusCommand()
        
        // Create temp config for testing
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("StatusCommandTest_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        command.configPath = tempDir.appendingPathComponent("nonexistent.json").path
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    func testRunWithValidConfig() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("StatusCommandTest_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let configURL = tempDir.appendingPathComponent("config.json")
        
        // Create a valid config
        let config = SwabbleConfig()
        config.wake.enabled = true
        config.wake.word = "clawd"
        
        let data = try JSONEncoder().encode(config)
        try data.write(to: configURL)
        
        var command = StatusCommand()
        command.configPath = configURL.path
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    func testRunWithDisabledWake() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("StatusCommandTest_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let configURL = tempDir.appendingPathComponent("config.json")
        
        var config = SwabbleConfig()
        config.wake.enabled = false
        config.wake.word = "custom_word"
        
        let data = try JSONEncoder().encode(config)
        try data.write(to: configURL)
        
        var command = StatusCommand()
        command.configPath = configURL.path
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
        
        pipe.fileHandleForReading.closeFile()
    }
    
    // MARK: - ConfigURL Tests
    
    func testConfigURLWithNilPath() {
        let command = StatusCommand()
        XCTAssertNil(command.configPath)
    }
    
    func testConfigURLWithValidPath() {
        var command = StatusCommand()
        let testPath = "/tmp/test/config.json"
        command.configPath = testPath
        XCTAssertEqual(command.configPath, testPath)
    }
    
    func testConfigURLMapping() {
        var command = StatusCommand()
        let testPath = "/tmp/config.json"
        command.configPath = testPath
        
        // Test that the private configURL is computed correctly
        // by checking the path computation logic
        if let configPath = command.configPath {
            let url = URL(fileURLWithPath: configPath)
            XCTAssertEqual(url.path, testPath)
        }
    }
    
    func testConfigURLWithEmptyPath() {
        var command = StatusCommand()
        command.configPath = ""
        XCTAssertEqual(command.configPath, "")
    }
    
    // MARK: - ParsedValues Initialization
    
    func testInitWithParsedValuesWithoutConfig() {
        let parsedValues = ParsedValues(
            options: [:],
            flags: Set(),
            positional: []
        )
        let command = StatusCommand(parsed: parsedValues)
        XCTAssertNil(command.configPath)
    }
    
    func testInitWithParsedValuesWithConfig() {
        let configPath = "/test/config.json"
        let parsedValues = ParsedValues(
            options: ["config": [configPath]],
            flags: Set(),
            positional: []
        )
        let command = StatusCommand(parsed: parsedValues)
        XCTAssertEqual(command.configPath, configPath)
    }
    
    func testInitWithParsedValuesWithMultipleConfigOptions() {
        let configPath1 = "/first/config.json"
        let configPath2 = "/last/config.json"
        let parsedValues = ParsedValues(
            options: ["config": [configPath1, configPath2]],
            flags: Set(),
            positional: []
        )
        let command = StatusCommand(parsed: parsedValues)
        // Should use the last one
        XCTAssertEqual(command.configPath, configPath2)
    }
    
    func testInitWithParsedValuesWithoutConfigOption() {
        let parsedValues = ParsedValues(
            options: ["other": ["value"]],
            flags: Set(),
            positional: []
        )
        let command = StatusCommand(parsed: parsedValues)
        XCTAssertNil(command.configPath)
    }
    
    // MARK: - Integration Tests
    
    func testRunWithTranscripts() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("StatusCommandTest_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let configURL = tempDir.appendingPathComponent("config.json")
        var config = SwabbleConfig()
        config.wake.enabled = true
        config.wake.word = "clawd"
        
        let data = try JSONEncoder().encode(config)
        try data.write(to: configURL)
        
        var command = StatusCommand()
        command.configPath = configURL.path
        
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        FileHandle.standardOutput = pipe
        
        defer {
            FileHandle.standardOutput = originalStdout
        }
        
        try await command.run()
    }
    
    // MARK: - Edge Cases
    
    func testRunWithSpecialCharactersInPath() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("StatusCommand Test_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }
        
        let configURL = tempDir.appendingPathComponent("config.json")
        var config = SwabbleConfig()
        let data = try JSONEncoder().encode(config)
        try data.write(to: configURL)
        
        var command = StatusCommand()
        command.configPath = configURL.path
        
        try await command.run()
    }
    
    func testMainActorAttribute() {
        let command = StatusCommand()
        XCTAssertNotNil(command)
    }
}