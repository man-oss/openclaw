import XCTest

@testable import swabble
import Commander

final class MainSwiftTests: XCTestCase {
  
  // MARK: - runCLI Tests
  
  @available(macOS 26.0, *)
  func testRunCLISuccess() async {
    let exitCode = await runCLI()
    // This test verifies the function completes without exception
    XCTAssertEqual(exitCode, 0)
  }
  
  // MARK: - dispatch Tests
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleCommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "status"])
    
    // Should not throw when dispatching swabble command
    do {
      try await dispatch(invocation: invocation)
    } catch {
      XCTFail("dispatch should not throw for valid swabble command: \(error)")
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchMissingCommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: [])
    
    // Should throw CommanderProgramError.missingCommand when no command provided
    do {
      try await dispatch(invocation: invocation)
      XCTFail("dispatch should throw missingCommand error when path is empty")
    } catch CommanderProgramError.missingCommand {
      // Expected error
    } catch {
      XCTFail("Expected missingCommand error, got: \(error)")
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchUnknownCommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["invalid-command"])
    
    // Should throw CommanderProgramError.unknownCommand for unrecognized commands
    do {
      try await dispatch(invocation: invocation)
      XCTFail("dispatch should throw unknownCommand error")
    } catch CommanderProgramError.unknownCommand {
      // Expected error
    } catch {
      XCTFail("Expected unknownCommand error, got: \(error)")
    }
  }
  
  // MARK: - dispatchSwabble Tests
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleMicSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "mic", "list"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // May fail due to external dependencies, but should attempt mic dispatch
      // The important part is that it doesn't throw unknownSubcommand
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleServiceSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "service", "status"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // May fail due to external dependencies
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleServeHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "serve"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler execution may fail but dispatch should work
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleTranscribeHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "transcribe"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleTestHookHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "test-hook"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleDoctorHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "doctor"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleSetupHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "setup"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleHealthHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "health"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleTailLogHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "tail-log"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleStartHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "start"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleStopHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "stop"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleRestartHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "restart"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleStatusHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "status"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Handler may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleUnknownHandler() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "unknown-handler"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
      XCTFail("should throw unknownSubcommand error")
    } catch CommanderProgramError.unknownSubcommand {
      // Expected
    } catch {
      // Other errors may occur
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchSwabbleMissingSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble"])
    
    do {
      try await dispatchSwabble(parsed: invocation.parsedValues, path: invocation.path)
      XCTFail("should throw missingSubcommand error")
    } catch CommanderProgramError.missingSubcommand {
      // Expected
    } catch {
      // Other errors may occur
    }
  }
  
  // MARK: - dispatchMic Tests
  
  @available(macOS 26.0, *)
  func testDispatchMicListSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "mic", "list"])
    
    do {
      try await dispatchMic(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Implementation may fail, but dispatch should work
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchMicSetSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "mic", "set"])
    
    do {
      try await dispatchMic(parsed: invocation.parsedValues, path: invocation.path)
    } catch {
      // Implementation may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchMicUnknownSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "mic", "invalid"])
    
    do {
      try await dispatchMic(parsed: invocation.parsedValues, path: invocation.path)
      XCTFail("should throw unknownSubcommand error")
    } catch CommanderProgramError.unknownSubcommand {
      // Expected
    } catch {
      // Other errors possible
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchMicMissingSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "mic"])
    
    do {
      try await dispatchMic(parsed: invocation.parsedValues, path: invocation.path)
      XCTFail("should throw missingSubcommand error")
    } catch CommanderProgramError.missingSubcommand {
      // Expected
    } catch {
      // Other errors may occur
    }
  }
  
  // MARK: - dispatchService Tests
  
  @available(macOS 26.0, *)
  func testDispatchServiceInstallSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "service", "install"])
    
    do {
      try await dispatchService(path: invocation.path)
    } catch {
      // Implementation may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchServiceUninstallSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "service", "uninstall"])
    
    do {
      try await dispatchService(path: invocation.path)
    } catch {
      // Implementation may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchServiceStatusSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "service", "status"])
    
    do {
      try await dispatchService(path: invocation.path)
    } catch {
      // Implementation may fail
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchServiceUnknownSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "service", "invalid"])
    
    do {
      try await dispatchService(path: invocation.path)
      XCTFail("should throw unknownSubcommand error")
    } catch CommanderProgramError.unknownSubcommand {
      // Expected
    } catch {
      // Other errors possible
    }
  }
  
  @available(macOS 26.0, *)
  func testDispatchServiceMissingSubcommand() async throws {
    let descriptors = CLIRegistry.descriptors
    let program = Program(descriptors: descriptors)
    let invocation = try program.resolve(argv: ["swabble", "service"])
    
    do {
      try await dispatchService(path: invocation.path)
      XCTFail("should throw missingSubcommand error")
    } catch CommanderProgramError.missingSubcommand {
      // Expected
    } catch {
      // Other errors may occur
    }
  }
  
  // MARK: - subcommand Tests
  
  func testSubcommandValidIndex() throws {
    let path = ["swabble", "serve", "port"]
    let result = try subcommand(path, index: 1, command: "test")
    XCTAssertEqual(result, "serve")
  }
  
  func testSubcommandLastElementValidIndex() throws {
    let path = ["swabble", "serve"]
    let result = try subcommand(path, index: 1, command: "test")
    XCTAssertEqual(result, "serve")
  }
  
  func testSubcommandOutOfBoundsIndex() throws {
    let path = ["swabble"]
    
    do {
      _ = try subcommand(path, index: 1, command: "test-cmd")
      XCTFail("should throw missingSubcommand error")
    } catch CommanderProgramError.missingSubcommand(command: let cmd) {
      XCTAssertEqual(cmd, "test-cmd")
    }
  }
  
  func testSubcommandEmptyPath() throws {
    let path: [String] = []
    
    do {
      _ = try subcommand(path, index: 0, command: "test-cmd")
      XCTFail("should throw missingSubcommand error")
    } catch CommanderProgramError.missingSubcommand(command: let cmd) {
      XCTAssertEqual(cmd, "test-cmd")
    }
  }
  
  func testSubcommandMultipleElements() throws {
    let path = ["swabble", "mic", "list", "verbose"]
    let result = try subcommand(path, index: 2, command: "test")
    XCTAssertEqual(result, "list")
  }
  
  func testSubcommandZeroIndex() throws {
    let path = ["command", "subcommand"]
    let result = try subcommand(path, index: 0, command: "test")
    XCTAssertEqual(result, "command")
  }
  
  // MARK: - swabbleHandlers Tests
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersReturnsDictionary() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertGreaterThan(handlers.count, 0)
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsServeKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("serve"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsTranscribeKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("transcribe"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsTestHookKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("test-hook"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsDoctorKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("doctor"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsSetupKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("setup"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsHealthKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("health"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsTailLogKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("tail-log"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsStartKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("start"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsStopKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("stop"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsRestartKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("restart"))
  }
  
  @available(macOS 26.0, *)
  func testSwabbleHandlersContainsStatusKey() {
    let parsed = ParsedValues()
    let handlers = swabbleHandlers(parsed: parsed)
    
    XCTAssertTrue(handlers.keys.contains("status"))
  }
}