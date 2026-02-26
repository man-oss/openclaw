import XCTest
import Commander
@testable import swabble

@MainActor
final class HealthCommandTests: XCTestCase {
    var sut: HealthCommand!

    override func setUp() {
        super.setUp()
        sut = HealthCommand()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        let command = HealthCommand()
        XCTAssertNotNil(command)
    }

    func testInitWithParsedValues() {
        let parsedValues = ParsedValues()
        let command = HealthCommand(parsed: parsedValues)
        XCTAssertNotNil(command)
    }

    func testCommandDescription() {
        let description = HealthCommand.commandDescription
        XCTAssertEqual(description.commandName, "health")
        XCTAssertEqual(description.abstract, "Health probe")
    }

    func testRunPrintsOk() {
        let output = captureStdout {
            _ = try? self.sut.run()
        }
        XCTAssertTrue(output.contains("ok"))
    }

    func testRunDoesNotThrow() async throws {
        try await sut.run()
    }

    func testRunMultipleTimes() async throws {
        try await sut.run()
        try await sut.run()
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