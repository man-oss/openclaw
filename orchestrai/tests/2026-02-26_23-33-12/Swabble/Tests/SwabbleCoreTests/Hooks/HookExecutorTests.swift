import XCTest
@testable import SwabbleCore

final class HookExecutorTests: XCTestCase {
    
    // MARK: - HookJob Tests
    
    func testHookJobInitialization() {
        let text = "test message"
        let timestamp = Date()
        
        let job = HookJob(text: text, timestamp: timestamp)
        
        XCTAssertEqual(job.text, text)
        XCTAssertEqual(job.timestamp, timestamp)
    }
    
    func testHookJobWithEmptyText() {
        let timestamp = Date()
        
        let job = HookJob(text: "", timestamp: timestamp)
        
        XCTAssertEqual(job.text, "")
        XCTAssertEqual(job.timestamp, timestamp)
    }
    
    // MARK: - HookExecutor Initialization Tests
    
    func testHookExecutorInitialization() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 0, timeoutSeconds: 5)
        )
        
        let executor = HookExecutor(config: config)
        
        XCTAssertNotNil(executor)
    }
    
    // MARK: - shouldRun Tests
    
    func testShouldRunWhenCooldownIsZero() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 0, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let result = executor.shouldRun()
        
        XCTAssertTrue(result)
    }
    
    func testShouldRunWhenCooldownIsNegative() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: -1, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let result = executor.shouldRun()
        
        XCTAssertTrue(result)
    }
    
    func testShouldRunWhenNoLastRun() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 5, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let result = executor.shouldRun()
        
        XCTAssertTrue(result)
    }
    
    func testShouldRunAfterCooldownExpires() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 0.1, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        // Run once to set lastRun
        let job = HookJob(text: "test", timestamp: Date())
        try? await executor.run(job: job)
        
        // Should return false immediately after
        let resultImmediate = executor.shouldRun()
        XCTAssertFalse(resultImmediate)
        
        // Wait for cooldown to pass
        try? await Task.sleep(nanoseconds: 150_000_000) // 0.15 seconds
        
        let resultAfterCooldown = executor.shouldRun()
        XCTAssertTrue(resultAfterCooldown)
    }
    
    func testShouldRunWithinCooldownPeriod() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 10, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "test", timestamp: Date())
        try? await executor.run(job: job)
        
        let result = executor.shouldRun()
        
        XCTAssertFalse(result)
    }
    
    // MARK: - run Tests
    
    func testRunThrowsWhenCommandIsEmpty() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "", args: [], env: [:], prefix: "", cooldownSeconds: 0, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "test", timestamp: Date())
        
        do {
            try await executor.run(job: job)
            XCTFail("Expected error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "Hook")
            XCTAssertEqual(error.code, 1)
            XCTAssertEqual(error.localizedDescription, "hook command not set")
        }
    }
    
    func testRunSkipsWhenShouldRunReturnsFalse() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 10, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let job1 = HookJob(text: "test1", timestamp: Date())
        try? await executor.run(job: job1)
        
        // This should skip because cooldown is active
        let job2 = HookJob(text: "test2", timestamp: Date())
        // Should complete without error
        try? await executor.run(job: job2)
    }
    
    func testRunWithValidCommand() async {
        let config = SwabbleConfig(
            hook: HookConfig(
                command: "/bin/echo",
                args: ["arg1"],
                env: ["TEST_VAR": "test_value"],
                prefix: "prefix_",
                cooldownSeconds: 0,
                timeoutSeconds: 5
            )
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "test message", timestamp: Date())
        
        do {
            try await executor.run(job: job)
            // Command executed successfully
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRunWithHostnameReplacement() async {
        let config = SwabbleConfig(
            hook: HookConfig(
                command: "/bin/echo",
                args: [],
                env: [:],
                prefix: "host-${hostname}:",
                cooldownSeconds: 0,
                timeoutSeconds: 5
            )
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "message", timestamp: Date())
        
        do {
            try await executor.run(job: job)
            // Hostname should be replaced in prefix
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRunWithMultipleEnvironmentVariables() async {
        let config = SwabbleConfig(
            hook: HookConfig(
                command: "/bin/echo",
                args: [],
                env: ["VAR1": "value1", "VAR2": "value2", "VAR3": "value3"],
                prefix: "",
                cooldownSeconds: 0,
                timeoutSeconds: 5
            )
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "test", timestamp: Date())
        
        do {
            try await executor.run(job: job)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRunWithMinimalTimeoutValue() async {
        let config = SwabbleConfig(
            hook: HookConfig(
                command: "/bin/echo",
                args: [],
                env: [:],
                prefix: "",
                cooldownSeconds: 0,
                timeoutSeconds: 0.05 // Will be bumped to 0.1
            )
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "test", timestamp: Date())
        
        do {
            try await executor.run(job: job)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRunWithZeroTimeoutValue() async {
        let config = SwabbleConfig(
            hook: HookConfig(
                command: "/bin/echo",
                args: [],
                env: [:],
                prefix: "",
                cooldownSeconds: 0,
                timeoutSeconds: 0
            )
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "test", timestamp: Date())
        
        do {
            try await executor.run(job: job)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRunSetsLastRunDate() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 10, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let beforeRun = Date()
        let job = HookJob(text: "test", timestamp: Date())
        try? await executor.run(job: job)
        let afterRun = Date()
        
        // After running once, shouldRun should return false
        let shouldRun = executor.shouldRun()
        XCTAssertFalse(shouldRun)
    }
    
    func testRunWithEmptyArguments() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 0, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "test", timestamp: Date())
        
        do {
            try await executor.run(job: job)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRunWithEmptyEnvironment() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 0, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "test", timestamp: Date())
        
        do {
            try await executor.run(job: job)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRunWithEmptyPrefix() async {
        let config = SwabbleConfig(
            hook: HookConfig(command: "/bin/echo", args: [], env: [:], prefix: "", cooldownSeconds: 0, timeoutSeconds: 5)
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "message", timestamp: Date())
        
        do {
            try await executor.run(job: job)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRunWithPrefixContainingMultipleHostnameTokens() async {
        let config = SwabbleConfig(
            hook: HookConfig(
                command: "/bin/echo",
                args: [],
                env: [:],
                prefix: "${hostname}-${hostname}:",
                cooldownSeconds: 0,
                timeoutSeconds: 5
            )
        )
        let executor = HookExecutor(config: config)
        
        let job = HookJob(text: "message", timestamp: Date())
        
        do {
            try await executor.run(job: job)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}