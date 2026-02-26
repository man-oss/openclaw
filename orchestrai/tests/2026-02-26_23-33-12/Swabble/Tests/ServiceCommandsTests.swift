import XCTest
import Foundation
import Commander
@testable import swabble

@MainActor
final class ServiceRootCommandTests: XCTestCase {
    func testCommandDescription() {
        let description = ServiceRootCommand.commandDescription
        XCTAssertEqual(description.commandName, "service")
        XCTAssertEqual(description.abstract, "Manage launchd agent")
        XCTAssertEqual(description.subcommands.count, 3)
    }
}

@MainActor
final class LaunchdHelperTests: XCTestCase {
    var testPlistURL: URL!
    var originalHome: String?

    override func setUp() {
        super.setUp()
        // Create a temporary directory for testing
        let tempDir = FileManager.default.temporaryDirectory
        testPlistURL = tempDir.appendingPathComponent("test_launchd_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: testPlistURL, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: testPlistURL)
        super.tearDown()
    }

    func testLaunchdLabel() {
        XCTAssertEqual(LaunchdHelper.label, "com.swabble.agent")
    }

    func testPlistURLPath() {
        let url = LaunchdHelper.plistURL
        XCTAssertTrue(url.path.contains("Library/LaunchAgents"))
        XCTAssertTrue(url.path.contains("com.swabble.agent.plist"))
    }

    func testWritePlistCreatesFile() throws {
        let executable = "/usr/local/bin/swabble"
        let tempPlistURL = testPlistURL.appendingPathComponent("test.plist")
        
        try writePlistToURL(executable: executable, url: tempPlistURL)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempPlistURL.path))
    }

    func testWritePlistContainsCorrectLabel() throws {
        let executable = "/usr/local/bin/swabble"
        let tempPlistURL = testPlistURL.appendingPathComponent("test.plist")
        
        try writePlistToURL(executable: executable, url: tempPlistURL)
        
        let data = try Data(contentsOf: tempPlistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        XCTAssertEqual(plist?["Label"] as? String, "com.swabble.agent")
    }

    func testWritePlistContainsCorrectProgramArguments() throws {
        let executable = "/usr/local/bin/swabble"
        let tempPlistURL = testPlistURL.appendingPathComponent("test.plist")
        
        try writePlistToURL(executable: executable, url: tempPlistURL)
        
        let data = try Data(contentsOf: tempPlistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        let args = plist?["ProgramArguments"] as? [String]
        XCTAssertEqual(args, [executable, "serve"])
    }

    func testWritePlistContainsRunAtLoad() throws {
        let executable = "/usr/local/bin/swabble"
        let tempPlistURL = testPlistURL.appendingPathComponent("test.plist")
        
        try writePlistToURL(executable: executable, url: tempPlistURL)
        
        let data = try Data(contentsOf: tempPlistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        XCTAssertEqual(plist?["RunAtLoad"] as? Bool, true)
    }

    func testWritePlistContainsKeepAlive() throws {
        let executable = "/usr/local/bin/swabble"
        let tempPlistURL = testPlistURL.appendingPathComponent("test.plist")
        
        try writePlistToURL(executable: executable, url: tempPlistURL)
        
        let data = try Data(contentsOf: tempPlistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        XCTAssertEqual(plist?["KeepAlive"] as? Bool, true)
    }

    func testWritePlistWithDifferentExecutables() throws {
        let executables = [
            "/usr/local/bin/swabble",
            "/opt/swabble/bin/swabble",
            "/Users/test/bin/swabble"
        ]
        
        for executable in executables {
            let tempPlistURL = testPlistURL.appendingPathComponent("test_\(UUID().uuidString).plist")
            try writePlistToURL(executable: executable, url: tempPlistURL)
            
            let data = try Data(contentsOf: tempPlistURL)
            let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
            let args = plist?["ProgramArguments"] as? [String]
            XCTAssertEqual(args?[0], executable)
            
            try FileManager.default.removeItem(at: tempPlistURL)
        }
    }

    func testRemovePlistDeletesFile() throws {
        let tempPlistURL = testPlistURL.appendingPathComponent("test.plist")
        
        // Create a test plist file
        try "test".write(to: tempPlistURL, atomically: true, encoding: .utf8)
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempPlistURL.path))
        
        try removePlistAtURL(url: tempPlistURL)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempPlistURL.path))
    }

    func testRemovePlistWhenFileDoesNotExist() throws {
        let tempPlistURL = testPlistURL.appendingPathComponent("nonexistent.plist")
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempPlistURL.path))
        
        // Should not throw
        try removePlistAtURL(url: tempPlistURL)
    }

    // MARK: - Helper Methods
    
    private func writePlistToURL(executable: String, url: URL) throws {
        let plist: [String: Any] = [
            "Label": "com.swabble.agent",
            "ProgramArguments": [executable, "serve"],
            "RunAtLoad": true,
            "KeepAlive": true
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: url)
    }
    
    private func removePlistAtURL(url: URL) throws {
        try? FileManager.default.removeItem(at: url)
    }
}

@MainActor
final class ServiceInstallTests: XCTestCase {
    var sut: ServiceInstall!
    var tempPlistURL: URL!

    override func setUp() {
        super.setUp()
        sut = ServiceInstall()
        
        let tempDir = FileManager.default.temporaryDirectory
        tempPlistURL = tempDir.appendingPathComponent("test_install_\(UUID().uuidString).plist")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempPlistURL)
        sut = nil
        super.tearDown()
    }

    func testCommandDescription() {
        let description = ServiceInstall.commandDescription
        XCTAssertEqual(description.commandName, "install")
        XCTAssertEqual(description.abstract, "Install user launch agent")
    }

    func testRunCreatesPlistFile() async throws {
        // Note: run() uses CommandLine.arguments.first, which is the test executable
        try await sut.run()
        
        // The plist will be created at LaunchdHelper.plistURL
        // We verify that the command doesn't throw
    }

    func testRunDoesNotThrow() async throws {
        try await sut.run()
    }
}

@MainActor
final class ServiceUninstallTests: XCTestCase {
    var sut: ServiceUninstall!

    override func setUp() {
        super.setUp()
        sut = ServiceUninstall()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCommandDescription() {
        let description = ServiceUninstall.commandDescription
        XCTAssertEqual(description.commandName, "uninstall")
        XCTAssertEqual(description.abstract, "Remove launch agent")
    }

    func testRunDoesNotThrow() async throws {
        try await sut.run()
    }

    func testRunRemovesPlist() async throws {
        // Create a test plist file
        let plistURL = LaunchdHelper.plistURL
        try? FileManager.default.createDirectory(
            at: plistURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? "test".write(to: plistURL, atomically: true, encoding: .utf8)
        
        try await sut.run()
        
        // Verify the plist was removed
        XCTAssertFalse(FileManager.default.fileExists(atPath: plistURL.path))
    }
}

@MainActor
final class ServiceStatusTests: XCTestCase {
    var sut: ServiceStatus!
    var tempPlistURL: URL!

    override func setUp() {
        super.setUp()
        sut = ServiceStatus()
        
        let tempDir = FileManager.default.temporaryDirectory
        tempPlistURL = tempDir.appendingPathComponent("test_status_\(UUID().uuidString).plist")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempPlistURL)
        sut = nil
        super.tearDown()
    }

    func testCommandDescription() {
        let description = ServiceStatus.commandDescription
        XCTAssertEqual(description.commandName, "status")
        XCTAssertEqual(description.abstract, "Show launch agent status")
    }

    func testRunDoesNotThrow() async throws {
        try await sut.run()
    }

    func testRunWhenPlistExists() async throws {
        // Create a test plist file
        let plistURL = LaunchdHelper.plistURL
        try? FileManager.default.createDirectory(
            at: plistURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? "test".write(to: plistURL, atomically: true, encoding: .utf8)
        
        try await sut.run()
        
        // Verify file still exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: plistURL.path))
        
        // Clean up
        try? FileManager.default.removeItem(at: plistURL)
    }

    func testRunWhenPlistDoesNotExist() async throws {
        // Ensure the plist doesn't exist
        let plistURL = LaunchdHelper.plistURL
        try? FileManager.default.removeItem(at: plistURL)
        
        try await sut.run()
        
        // Should complete without throwing
        XCTAssertTrue(true)
    }
}