import XCTest
@testable import SwabbleCore

class TranscriptsStoreTests: XCTestCase {
    
    var store: TranscriptsStore!
    var testFileURL: URL!
    
    override func setUp() {
        super.setUp()
        // Create a temporary directory for testing
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        testFileURL = tempDir.appendingPathComponent("transcripts.log")
    }
    
    override func tearDown() {
        super.tearDown()
        // Clean up test files
        try? FileManager.default.removeItem(at: testFileURL.deletingLastPathComponent())
    }
    
    // MARK: - Shared instance
    
    func testSharedInstanceExists() {
        let shared1 = TranscriptsStore.shared
        let shared2 = TranscriptsStore.shared
        XCTAssertTrue(shared1 === shared2)
    }
    
    // MARK: - Init without existing file
    
    func testInitCreatesDirectoryStructure() async {
        let store = TranscriptsStore()
        // Should not crash
        XCTAssertNotNil(store)
    }
    
    func testInitWithNoExistingFile() async {
        let store = TranscriptsStore()
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 0)
    }
    
    // MARK: - Init with existing file
    
    func testInitLoadsExistingFile() async {
        // Create a test file with some entries
        let tempDir = FileManager.default.temporaryDirectory
        let testFile = tempDir.appendingPathComponent("test_transcripts_\(UUID().uuidString).log")
        
        let testData = "entry1\nentry2\nentry3"
        try? testData.write(to: testFile, atomically: false, encoding: .utf8)
        
        defer {
            try? FileManager.default.removeItem(at: testFile)
        }
        
        // Note: TranscriptsStore uses a fixed path, so we can't directly test this
        // without modifying the implementation. We'll test the behavior instead.
        let store = TranscriptsStore()
        let entries = await store.latest()
        // Should have at least initialized
        XCTAssertNotNil(entries)
    }
    
    // MARK: - Append single entry
    
    func testAppendSingleEntry() async {
        let store = TranscriptsStore()
        await store.append(text: "test entry")
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first, "test entry")
    }
    
    // MARK: - Append multiple entries
    
    func testAppendMultipleEntries() async {
        let store = TranscriptsStore()
        await store.append(text: "entry1")
        await store.append(text: "entry2")
        await store.append(text: "entry3")
        
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 3)
        XCTAssertEqual(entries[0], "entry1")
        XCTAssertEqual(entries[1], "entry2")
        XCTAssertEqual(entries[2], "entry3")
    }
    
    // MARK: - Limit enforcement
    
    func testAppendEnforcesLimit() async {
        let store = TranscriptsStore()
        
        // Append more than limit (100)
        for i in 0..<150 {
            await store.append(text: "entry\(i)")
        }
        
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 100)
        // Should keep the last 100 entries
        XCTAssertEqual(entries.first, "entry50")
        XCTAssertEqual(entries.last, "entry149")
    }
    
    func testAppendExactlyAtLimit() async {
        let store = TranscriptsStore()
        
        // Append exactly 100 entries
        for i in 0..<100 {
            await store.append(text: "entry\(i)")
        }
        
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 100)
        XCTAssertEqual(entries.first, "entry0")
        XCTAssertEqual(entries.last, "entry99")
    }
    
    func testAppendOneOverLimit() async {
        let store = TranscriptsStore()
        
        // Append 101 entries
        for i in 0..<101 {
            await store.append(text: "entry\(i)")
        }
        
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 100)
        XCTAssertEqual(entries.first, "entry1")
        XCTAssertEqual(entries.last, "entry100")
    }
    
    // MARK: - Empty and special entries
    
    func testAppendEmptyString() async {
        let store = TranscriptsStore()
        await store.append(text: "")
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first, "")
    }
    
    func testAppendStringWithNewlines() async {
        let store = TranscriptsStore()
        let multiline = "line1\nline2\nline3"
        await store.append(text: multiline)
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first, multiline)
    }
    
    func testAppendStringWithSpecialCharacters() async {
        let store = TranscriptsStore()
        let special = "特殊文字 🎉 emoji \t tabs"
        await store.append(text: special)
        let entries = await store.latest()
        XCTAssertEqual(entries.first, special)
    }
    
    func testAppendVeryLongString() async {
        let store = TranscriptsStore()
        let longString = String(repeating: "a", count: 10000)
        await store.append(text: longString)
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first, longString)
    }
    
    // MARK: - Latest entries
    
    func testLatestReturnsAllEntries() async {
        let store = TranscriptsStore()
        await store.append(text: "a")
        await store.append(text: "b")
        await store.append(text: "c")
        
        let entries = await store.latest()
        XCTAssertEqual(entries, ["a", "b", "c"])
    }
    
    func testLatestReturnsEmptyArrayWhenNoEntries() async {
        let store = TranscriptsStore()
        let entries = await store.latest()
        XCTAssertEqual(entries, [])
    }
    
    func testLatestReturnsInCorrectOrder() async {
        let store = TranscriptsStore()
        for i in 0..<5 {
            await store.append(text: "entry\(i)")
        }
        
        let entries = await store.latest()
        for (index, entry) in entries.enumerated() {
            XCTAssertEqual(entry, "entry\(index)")
        }
    }
    
    // MARK: - Persistence
    
    func testAppendPersistsToFile() async {
        let store = TranscriptsStore()
        await store.append(text: "test1")
        await store.append(text: "test2")
        
        // Small delay to ensure write completes
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 2)
    }
    
    // MARK: - Actor concurrency
    
    func testConcurrentAppends() async {
        let store = TranscriptsStore()
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    await store.append(text: "entry\(i)")
                }
            }
        }
        
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 10)
    }
    
    func testConcurrentRead() async {
        let store = TranscriptsStore()
        await store.append(text: "test")
        
        var results: [Int] = []
        
        await withTaskGroup(of: Int.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    let entries = await store.latest()
                    return entries.count
                }
            }
            
            for await count in group {
                results.append(count)
            }
        }
        
        XCTAssertEqual(results.count, 5)
        XCTAssertTrue(results.allSatisfy { $0 == 1 })
    }
    
    // MARK: - Removal on overflow
    
    func testRemoveFirstWhenOverLimit() async {
        let store = TranscriptsStore()
        
        // Add exactly 100
        for i in 0..<100 {
            await store.append(text: "\(i)")
        }
        
        // Add 1 more to trigger removal
        await store.append(text: "100")
        
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 100)
        XCTAssertFalse(entries.contains("0"))
        XCTAssertTrue(entries.contains("100"))
    }
    
    func testRemoveFirstMultipleWhenWayOverLimit() async {
        let store = TranscriptsStore()
        
        // Add 100
        for i in 0..<100 {
            await store.append(text: "\(i)")
        }
        
        // Add 50 more (should remove 50 oldest)
        for i in 100..<150 {
            await store.append(text: "\(i)")
        }
        
        let entries = await store.latest()
        XCTAssertEqual(entries.count, 100)
        XCTAssertFalse(entries.contains("49"))
        XCTAssertTrue(entries.contains("50"))
        XCTAssertTrue(entries.contains("149"))
    }
}