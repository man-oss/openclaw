import XCTest
import AVFoundation
@testable import SwabbleCore

final class BufferConverterTests: XCTestCase {
    
    var converter: BufferConverter!
    
    override func setUp() {
        super.setUp()
        converter = BufferConverter()
    }
    
    override func tearDown() {
        converter = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func createAudioFormat(sampleRate: Double, channels: AVAudioChannelCount) -> AVAudioFormat {
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: channels
        )
        return format!
    }
    
    func createAudioBuffer(
        format: AVAudioFormat,
        frameLength: AVAudioFrameCount
    ) -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameLength)!
        buffer.frameLength = frameLength
        return buffer
    }
    
    // MARK: - Convert Tests
    
    func testConvertBufferWithIdenticalFormats() {
        let format = createAudioFormat(sampleRate: 16000, channels: 1)
        let buffer = createAudioBuffer(format: format, frameLength: 2048)
        
        let result = try? converter.convert(buffer, to: format)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, format)
        XCTAssertEqual(result?.frameLength, buffer.frameLength)
    }
    
    func testConvertBufferWithDifferentSampleRates() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 48000, channels: 1)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 2048)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
        // Frame length should be scaled by sample rate ratio
        let expectedFrameLength = Int(Double(2048) * (48000.0 / 16000.0))
        XCTAssertEqual(result?.frameLength, expectedFrameLength)
    }
    
    func testConvertBufferWithDifferentChannelCounts() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 16000, channels: 2)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 2048)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
    }
    
    func testConvertBufferWithBothSampleRateAndChannelChanges() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 48000, channels: 2)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 2048)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
    }
    
    func testConvertWithSmallFrameLength() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 48000, channels: 1)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 1)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
    }
    
    func testConvertWithLargeFrameLength() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 48000, channels: 1)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 65536)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
    }
    
    func testConvertWithHighSampleRateDownsampling() {
        let inputFormat = createAudioFormat(sampleRate: 192000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 4096)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
    }
    
    func testConvertWithLowSampleRateUpsampling() {
        let inputFormat = createAudioFormat(sampleRate: 8000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 96000, channels: 1)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 2048)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
    }
    
    func testConvertReuseConverterWithSameFormat() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 48000, channels: 1)
        let buffer1 = createAudioBuffer(format: inputFormat, frameLength: 2048)
        let buffer2 = createAudioBuffer(format: inputFormat, frameLength: 1024)
        
        let result1 = try? converter.convert(buffer1, to: outputFormat)
        let result2 = try? converter.convert(buffer2, to: outputFormat)
        
        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertEqual(result1?.format, result2?.format)
    }
    
    func testConvertSwitchConverterWhenOutputFormatChanges() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat1 = createAudioFormat(sampleRate: 48000, channels: 1)
        let outputFormat2 = createAudioFormat(sampleRate: 44100, channels: 1)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 2048)
        
        let result1 = try? converter.convert(buffer, to: outputFormat1)
        let result2 = try? converter.convert(buffer, to: outputFormat2)
        
        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotEqual(result1?.format, result2?.format)
    }
    
    func testConvertWithMonoToStereo() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 16000, channels: 2)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 2048)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
    }
    
    func testConvertWithStereoToMono() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 2)
        let outputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 2048)
        
        let result = try? converter.convert(buffer, to: outputFormat)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.format, outputFormat)
    }
    
    func testConverterErrorHandling() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 48000, channels: 1)
        let buffer = createAudioBuffer(format: inputFormat, frameLength: 2048)
        
        // Test with valid conversion
        let result = try? converter.convert(buffer, to: outputFormat)
        XCTAssertNotNil(result)
    }
    
    func testConvertMultipleBuffersSequentially() {
        let inputFormat = createAudioFormat(sampleRate: 16000, channels: 1)
        let outputFormat = createAudioFormat(sampleRate: 48000, channels: 1)
        
        let buffer1 = createAudioBuffer(format: inputFormat, frameLength: 2048)
        let buffer2 = createAudioBuffer(format: inputFormat, frameLength: 1024)
        let buffer3 = createAudioBuffer(format: inputFormat, frameLength: 4096)
        
        let result1 = try? converter.convert(buffer1, to: outputFormat)
        let result2 = try? converter.convert(buffer2, to: outputFormat)
        let result3 = try? converter.convert(buffer3, to: outputFormat)
        
        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotNil(result3)
    }
}