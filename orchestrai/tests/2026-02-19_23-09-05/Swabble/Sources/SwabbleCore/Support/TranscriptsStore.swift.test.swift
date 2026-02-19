import XCTest
import Foundation

@testable import SwabbleCore

final class TranscriptsStoreTests: XCTestCase {
    
    var tempDir: URL!
    var testFileURL: URL!
    
    override func setUp() {
        super.setUp()
        
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(
            "TranscriptsStoreTests-\(UUID().uuidString)",
            isDirectory: true
        )
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        testFileURL = tempDir.appendingPathComponent("transcripts.log")
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // MARK: - Initialization Tests
    
    func test_init_createsApplicationSupportDirectory() {
        let store = TranscriptsStore()
        XCTAssertNotNil(store)
    }
    
    func test_init_loadsExistingTranscriptsFromFile() {
        // Create a test file with existing transcripts
        let testContent = "transcript1\ntranscript2\ntranscript3"
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let dir = homeDir.appendingPathComponent("Library/Application Support/swabble", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileURL = dir.appendingPathComponent("transcripts.log")
        
        try? testContent.write(to: fileURL, atomically: false, encoding: .utf8)
        
        let store = TranscriptsStore()
        let latest = store.latest()
        
        XCTAssertEqual(latest.count, 3)
        XCTAssertEqual(latest[0], "transcript1")
        XCTAssertEqual(latest[1], "transcript2")
        XCTAssertEqual(latest[2], "transcript3")
        
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func test_init_loadsExistingTranscriptsAndRespectLimit() {
        // Create a test file with more than 100 transcripts
        let lines = (1...150).map { "transcript\($0)" }
        let testContent = lines.joined(separator: "\n")
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let dir = homeDir.appendingPathComponent("Library/Application Support/swabble", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileURL = dir.appendingPathComponent("transcripts.log")
        
        try? testContent.write(to: fileURL, atomically: false, encoding: .utf8)
        
        let store = TranscriptsStore()
        let latest = store.latest()
        
        XCTAssertEqual(latest.count, 100)
        XCTAssertEqual(latest[0], "transcript51")
        XCTAssertEqual(latest[99], "transcript150")
        
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func test_init_withoutExistingFile_startsEmpty() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let dir = homeDir.appendingPathComponent("Library/Application Support/swabble", isDirectory: true)
        let fileURL = dir.appendingPathComponent("transcripts.log")
        
        try? FileManager.default.removeItem(at: fileURL)
        
        let store = TranscriptsStore()
        let latest = store.latest()
        
        XCTAssertEqual(latest.count, 0)
    }
    
    func test_init_withCorruptFile_startsEmpty() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let dir = homeDir.appendingPathComponent("Library/Application Support/swabble", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileURL = dir.appendingPathComponent("transcripts.log")
        
        // Write invalid UTF-8 data
        let invalidData = Data([0xFF, 0xFE, 0xFD])
        try? invalidData.write(to: fileURL)
        
        let store = TranscriptsStore()
        let latest = store.latest()
        
        XCTAssertEqual(latest.count, 0)
        
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: - append Tests
    
    func test_append_addsTextToEntries() async {
        let store = TranscriptsStore()
        
        await store.append(text: "new transcript")
        
        let latest = await store.latest()
        XCTAssertTrue(latest.contains("new transcript"))
    }
    
    func test_append_multipleTexts_allAreStored() async {
        let store = TranscriptsStore()
        
        await store.append(text: "first")
        await store.append(text: "second")
        await store.append(text: "third")
        
        let latest = await store.latest()
        XCTAssertEqual(latest.count, 3)
        XCTAssertEqual(latest[0], "first")
        XCTAssertEqual(latest[1], "second")
        XCTAssertEqual(latest[2], "third")
    }
    
    func test_append_exceedingLimit_removesOldest() async {
        let store = TranscriptsStore()
        
        // Add 101 entries
        for i in 1...101 {
            await store.append(text: "transcript\(i)")
        }
        
        let latest = await store.latest()
        XCTAssertEqual(latest.count, 100)
        XCTAssertEqual(latest[0], "transcript2")
        XCTAssertEqual(latest[99], "transcript101")
    }
    
    func test_append_exactlyAtLimit_allStored() async {
        let store = TranscriptsStore()
        
        // Add exactly 100 entries
        for i in 1...100 {
            await store.append(text: "transcript\(i)")
        }
        
        let latest = await store.latest()
        XCTAssertEqual(latest.count, 100)
        XCTAssertEqual(latest[0], "transcript1")
        XCTAssertEqual(latest[99], "transcript100")
    }
    
    func test_append_writesToFile() async {
        let store = TranscriptsStore()
        
        await store.append(text: "persisted text")
        
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let fileURL = homeDir.appendingPathComponent("Library/Application Support/swabble/transcripts.log")
        
        if let data = try? Data(contentsOf: fileURL),
           let content = String(data: data, encoding: .utf8) {
            XCTAssertTrue(content.contains("persisted text"))
        }
    }
    
    func test_append_emptyString_isStored() async {
        let store = TranscriptsStore()
        
        await store.append(text: "")
        
        let latest = await store.latest()
        XCTAssertEqual(latest.count, 1)
        XCTAssertEqual(latest[0], "")
    }
    
    func test_append_stringWithNewlines_isStored() async {
        let store = TranscriptsStore()
        
        await store.append(text: "line1\nline2")
        
        let latest = await store.latest()
        XCTAssertEqual(latest.count, 1)
        XCTAssertEqual(latest[0], "line1\nline2")
    }
    
    func test_append_preservesOrderAcrossMultipleCalls() async {
        let store = TranscriptsStore()
        
        for i in 1...5 {
            await store.append(text: "entry\(i)")
        }
        
        let latest = await store.latest()
        
        for (index, entry) in latest.enumerated() {
            XCTAssertEqual(entry, "entry\(index + 1)")
        }
    }
    
    // MARK: - latest Tests
    
    func test_latest_returnsCurrentEntries() async {
        let store = TranscriptsStore()
        
        await store.append(text: "entry1")
        await store.append(text: "entry2")
        
        let latest = await store.latest()
        XCTAssertEqual(latest.count, 2)
        XCTAssertEqual(latest, ["entry1", "entry2"])
    }
    
    func test_latest_returnsEmptyArrayWhenNoEntries() async {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let fileURL = homeDir.appendingPathComponent("Library/Application Support/swabble/transcripts.log")
        try? FileManager.default.removeItem(at: fileURL)
        
        let store = TranscriptsStore()
        
        let latest = await store.latest()
        XCTAssertEqual(latest.count, 0)
    }
    
    // MARK: - shared singleton Test
    
    func test_shared_returnsSameInstance() {
        let instance1 = TranscriptsStore.shared
        let instance2 = TranscriptsStore.shared
        
        XCTAssertEqual(ObjectIdentifier(instance1), ObjectIdentifier(instance2))
    }
    
    // MARK: - String extension appendLine Tests
    
    func test_appendLineExtension_appendsToNewFile() throws {
        let testFile = tempDir.appendingPathComponent("test.txt")
        try "Hello World".appendLine(to: testFile)
        
        let content = try String(contentsOf: testFile, encoding: .utf8)
        XCTAssertEqual(content, "Hello World\n")
    }
    
    func test_appendLineExtension_appendsToExistingFile() throws {
        let testFile = tempDir.appendingPathComponent("test.txt")
        try "Line 1".write(to: testFile, atomically: false, encoding: .utf8)
        
        try "Line 2".appendLine(to: testFile)
        
        let content = try String(contentsOf: testFile, encoding: .utf8)
        XCTAssertEqual(content, "Line 1Line 2\n")
    }
    
    func test_appendLineExtension_emptyString() throws {
        let testFile = tempDir.appendingPathComponent("test.txt")
        try "".appendLine(to: testFile)
        
        let content = try String(contentsOf: testFile, encoding: .utf8)
        XCTAssertEqual(content, "\n")
    }
    
    func test_appendLineExtension_multipleAppends() throws {
        let testFile = tempDir.appendingPathComponent("test.txt")
        try "Line 1".appendLine(to: testFile)
        try "Line 2".appendLine(to: testFile)
        try "Line 3".appendLine(to: testFile)
        
        let content = try String(contentsOf: testFile, encoding: .utf8)
        XCTAssertEqual(content, "Line 1\nLine 2\nLine 3\n")
    }
    
    func test_appendLineExtension_stringWithSpecialCharacters() throws {
        let testFile = tempDir.appendingPathComponent("test.txt")
        try "Line with émojis 🎉".appendLine(to: testFile)
        
        let content = try String(contentsOf: testFile, encoding: .utf8)
        XCTAssertEqual(content, "Line with émojis 🎉\n")
    }
    
    func test_appendLineExtension_invalidEncodingHandled() throws {
        let testFile = tempDir.appendingPathComponent("test.txt")
        
        let invalidString = "Test"
        try invalidString.appendLine(to: testFile)
        
        let content = try String(contentsOf: testFile, encoding: .utf8)
        XCTAssertTrue(content.contains("Test"))
    }
}