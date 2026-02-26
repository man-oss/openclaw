import XCTest
import AVFoundation
import Commander
@testable import swabble
@testable import Swabble

@MainActor
final class MicCommandTests: XCTestCase {
    func testMicCommandDescription() {
        let description = MicCommand.commandDescription
        XCTAssertEqual(description.commandName, "mic")
        XCTAssertEqual(description.abstract, "Microphone management")
        XCTAssertEqual(description.subcommands.count, 2)
    }
}

@MainActor
final class MicListTests: XCTestCase {
    var sut: MicList!

    override func setUp() {
        super.setUp()
        sut = MicList()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        let command = MicList()
        XCTAssertNotNil(command)
    }

    func testInitWithParsedValues() {
        let parsedValues = ParsedValues()
        let command = MicList(parsed: parsedValues)
        XCTAssertNotNil(command)
    }

    func testCommandDescription() {
        let description = MicList.commandDescription
        XCTAssertEqual(description.commandName, "list")
        XCTAssertEqual(description.abstract, "List input devices")
    }

    func testRunWithDevices() async throws {
        // This test will depend on system audio devices
        // We test that run() completes without throwing
        try await sut.run()
    }

    func testRunDoesNotThrow() async throws {
        try await sut.run()
    }

    // MARK: - Helper Methods
    
    private func captureStdout(closure: () -> Void) -> String {
        let pipe = Pipe()
        let originalStdout = FileHandle.standardOutput
        
        dup2(pipe.fileHandleForWriting.fileDescriptor, FileHandle.standardOutput.fileDescriptor)
        
        closure()
        
        pipe.fileHandleForWriting.closeFile()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        dup2(originalStdout.fileDescriptor, FileHandle.standardOutput.fileDescriptor)
        
        return String(data: data, encoding: .utf8) ?? ""
    }
}

@MainActor
final class MicSetTests: XCTestCase {
    var sut: MicSet!
    var tempConfigURL: URL!

    override func setUp() {
        super.setUp()
        sut = MicSet()
        
        // Create temporary config file for testing
        let tempDir = FileManager.default.temporaryDirectory
        tempConfigURL = tempDir.appendingPathComponent("test_config_\(UUID().uuidString).json")
        
        // Create a default config for testing
        let defaultConfig = SwabbleConfig()
        try? ConfigLoader.save(defaultConfig, at: tempConfigURL)
    }

    override func tearDown() {
        sut = nil
        try? FileManager.default.removeItem(at: tempConfigURL)
        tempConfigURL = nil
        super.tearDown()
    }

    func testInitWithDefaults() {
        let command = MicSet()
        XCTAssertEqual(command.index, 0)
        XCTAssertNil(command.configPath)
    }

    func testInitWithParsedValuesNoValues() {
        let parsedValues = ParsedValues()
        let command = MicSet(parsed: parsedValues)
        XCTAssertEqual(command.index, 0)
        XCTAssertNil(command.configPath)
    }

    func testInitWithParsedValuesWithIndex() {
        let parsedValues = ParsedValues()
        parsedValues.positional = ["5"]
        let command = MicSet(parsed: parsedValues)
        XCTAssertEqual(command.index, 5)
    }

    func testInitWithParsedValuesWithInvalidIndex() {
        let parsedValues = ParsedValues()
        parsedValues.positional = ["invalid"]
        let command = MicSet(parsed: parsedValues)
        XCTAssertEqual(command.index, 0)
    }

    func testInitWithParsedValuesWithConfig() {
        let parsedValues = ParsedValues()
        parsedValues.options["config"] = ["/path/to/config.json"]
        let command = MicSet(parsed: parsedValues)
        XCTAssertEqual(command.configPath, "/path/to/config.json")
    }

    func testInitWithParsedValuesWithIndexAndConfig() {
        let parsedValues = ParsedValues()
        parsedValues.positional = ["3"]
        parsedValues.options["config"] = ["/path/to/config.json"]
        let command = MicSet(parsed: parsedValues)
        XCTAssertEqual(command.index, 3)
        XCTAssertEqual(command.configPath, "/path/to/config.json")
    }

    func testCommandDescription() {
        let description = MicSet.commandDescription
        XCTAssertEqual(description.commandName, "set")
        XCTAssertEqual(description.abstract, "Set default input device index")
    }

    func testRunWithValidIndex() async throws {
        sut.index = 2
        sut.configPath = tempConfigURL.path
        try await sut.run()
        
        // Verify config was saved
        let loadedConfig = try ConfigLoader.load(at: tempConfigURL)
        XCTAssertEqual(loadedConfig.audio.deviceIndex, 2)
    }

    func testRunWithZeroIndex() async throws {
        sut.index = 0
        sut.configPath = tempConfigURL.path
        try await sut.run()
        
        let loadedConfig = try ConfigLoader.load(at: tempConfigURL)
        XCTAssertEqual(loadedConfig.audio.deviceIndex, 0)
    }

    func testRunWithLargeIndex() async throws {
        sut.index = 999
        sut.configPath = tempConfigURL.path
        try await sut.run()
        
        let loadedConfig = try ConfigLoader.load(at: tempConfigURL)
        XCTAssertEqual(loadedConfig.audio.deviceIndex, 999)
    }

    func testRunWithoutConfigPath() async throws {
        // When configPath is nil, it will try to load from default location
        // This may throw an error if no default config exists
        sut.index = 1
        sut.configPath = nil
        
        // We expect this might throw since default path likely doesn't exist
        do {
            try await sut.run()
        } catch {
            // Expected - default config path may not exist
            XCTAssertNotNil(error)
        }
    }

    func testConfigURLMapping() {
        sut.configPath = "/custom/path/config.json"
        let url = sut.configURL
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.path, "/custom/path/config.json")
    }

    func testConfigURLMappingNil() {
        sut.configPath = nil
        let url = sut.configURL
        XCTAssertNil(url)
    }
}

extension ParsedValues {
    var positional: [String] {
        get { objc_getAssociatedObject(self, "positional") as? [String] ?? [] }
        set { objc_setAssociatedObject(self, "positional", newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var options: [String: [String]] {
        get { objc_getAssociatedObject(self, "options") as? [String: [String]] ?? [:] }
        set { objc_setAssociatedObject(self, "options", newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
}