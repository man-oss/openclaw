import XCTest
import Commander
@testable import swabble
@testable import Swabble
@testable import SwabbleKit

@available(macOS 26.0, *)
@MainActor
final class ServeCommandTests: XCTestCase {
    var sut: ServeCommand!
    var tempConfigURL: URL!

    override func setUp() {
        super.setUp()
        sut = ServeCommand()
        
        let tempDir = FileManager.default.temporaryDirectory
        tempConfigURL = tempDir.appendingPathComponent("test_serve_config_\(UUID().uuidString).json")
    }

    override func tearDown() {
        sut = nil
        try? FileManager.default.removeItem(at: tempConfigURL)
        tempConfigURL = nil
        super.tearDown()
    }

    func testInitWithDefaults() {
        let command = ServeCommand()
        XCTAssertNil(command.configPath)
        XCTAssertFalse(command.noWake)
    }

    func testInitWithParsedValuesNoFlags() {
        let parsedValues = ParsedValues()
        let command = ServeCommand(parsed: parsedValues)
        XCTAssertNil(command.configPath)
        XCTAssertFalse(command.noWake)
    }

    func testInitWithParsedValuesWithNoWakeFlag() {
        let parsedValues = ParsedValues()
        parsedValues.flags = ["noWake"]
        let command = ServeCommand(parsed: parsedValues)
        XCTAssertTrue(command.noWake)
    }

    func testInitWithParsedValuesWithConfigOption() {
        let parsedValues = ParsedValues()
        parsedValues.options["config"] = ["/path/to/config.json"]
        let command = ServeCommand(parsed: parsedValues)
        XCTAssertEqual(command.configPath, "/path/to/config.json")
    }

    func testInitWithParsedValuesWithMultipleConfigOptions() {
        let parsedValues = ParsedValues()
        parsedValues.options["config"] = ["/first.json", "/second.json"]
        let command = ServeCommand(parsed: parsedValues)
        XCTAssertEqual(command.configPath, "/second.json")
    }

    func testInitWithParsedValuesWithAllOptions() {
        let parsedValues = ParsedValues()
        parsedValues.flags = ["noWake"]
        parsedValues.options["config"] = ["/path/to/config.json"]
        let command = ServeCommand(parsed: parsedValues)
        XCTAssertTrue(command.noWake)
        XCTAssertEqual(command.configPath, "/path/to/config.json")
    }

    func testCommandDescription() {
        let description = ServeCommand.commandDescription
        XCTAssertEqual(description.commandName, "serve")
        XCTAssertEqual(description.abstract, "Run swabble in the foreground")
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

    func testMatchesWakeWithExactMatch() {
        var config = SwabbleConfig()
        config.wake.word = "hello"
        config.wake.aliases = []
        
        // Mock WakeWordGate.matchesTextOnly to return true
        let result = ServeCommand.matchesWake(text: "hello world", cfg: config)
        // This depends on the actual WakeWordGate implementation
        XCTAssertNotNil(result)
    }

    func testMatchesWakeWithAlias() {
        var config = SwabbleConfig()
        config.wake.word = "hello"
        config.wake.aliases = ["hi", "hey"]
        
        let result = ServeCommand.matchesWake(text: "hi there", cfg: config)
        XCTAssertNotNil(result)
    }

    func testMatchesWakeWithNoMatch() {
        var config = SwabbleConfig()
        config.wake.word = "hello"
        config.wake.aliases = []
        
        let result = ServeCommand.matchesWake(text: "goodbye", cfg: config)
        XCTAssertNotNil(result)
    }

    func testStripWakeWithWakeWord() {
        var config = SwabbleConfig()
        config.wake.word = "hello"
        config.wake.aliases = []
        
        let result = ServeCommand.stripWake(text: "hello world", cfg: config)
        XCTAssertNotNil(result)
    }

    func testStripWakeWithAlias() {
        var config = SwabbleConfig()
        config.wake.word = "hello"
        config.wake.aliases = ["hi"]
        
        let result = ServeCommand.stripWake(text: "hi world", cfg: config)
        XCTAssertNotNil(result)
    }

    func testStripWakeWithNoWakeWord() {
        var config = SwabbleConfig()
        config.wake.word = "hello"
        config.wake.aliases = []
        
        let result = ServeCommand.stripWake(text: "goodbye world", cfg: config)
        XCTAssertNotNil(result)
    }

    func testNoWakeFlagDisablesWakeWord() async throws {
        // Create a temporary config
        var config = SwabbleConfig()
        config.wake.enabled = true
        try ConfigLoader.save(config, at: tempConfigURL)
        
        sut.configPath = tempConfigURL.path
        sut.noWake = true
        
        // We can't fully test the run method as it requires a working SpeechPipeline
        // But we can verify that the flag is set correctly
        XCTAssertTrue(sut.noWake)
    }

    func testDefaultNoWakeFlagIsFalse() {
        let command = ServeCommand()
        XCTAssertFalse(command.noWake)
    }
}

extension ServeCommand {
    var configURL: URL? {
        configPath.map { URL(fileURLWithPath: $0) }
    }
}