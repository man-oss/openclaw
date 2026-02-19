package ai.openclaw.android

import org.junit.Test
import kotlin.test.assertEquals

class CameraHudStateTest {
  
  @Test
  fun testCameraHudStateCreationWithPhotoKind() {
    val token = 12345L
    val kind = CameraHudKind.Photo
    val message = "Taking photo"
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(token, state.token)
    assertEquals(kind, state.kind)
    assertEquals(message, state.message)
  }
  
  @Test
  fun testCameraHudStateCreationWithRecordingKind() {
    val token = 67890L
    val kind = CameraHudKind.Recording
    val message = "Recording video"
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(token, state.token)
    assertEquals(kind, state.kind)
    assertEquals(message, state.message)
  }
  
  @Test
  fun testCameraHudStateCreationWithSuccessKind() {
    val token = 11111L
    val kind = CameraHudKind.Success
    val message = "Success!"
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(token, state.token)
    assertEquals(kind, state.kind)
    assertEquals(message, state.message)
  }
  
  @Test
  fun testCameraHudStateCreationWithErrorKind() {
    val token = 22222L
    val kind = CameraHudKind.Error
    val message = "Error occurred"
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(token, state.token)
    assertEquals(kind, state.kind)
    assertEquals(message, state.message)
  }
  
  @Test
  fun testCameraHudStateWithEmptyMessage() {
    val token = 0L
    val kind = CameraHudKind.Photo
    val message = ""
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(token, state.token)
    assertEquals(kind, state.kind)
    assertEquals(message, state.message)
  }
  
  @Test
  fun testCameraHudStateWithZeroToken() {
    val token = 0L
    val kind = CameraHudKind.Photo
    val message = "Test"
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(0L, state.token)
  }
  
  @Test
  fun testCameraHudStateWithNegativeToken() {
    val token = -1L
    val kind = CameraHudKind.Photo
    val message = "Test"
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(-1L, state.token)
  }
  
  @Test
  fun testCameraHudStateWithLargeToken() {
    val token = Long.MAX_VALUE
    val kind = CameraHudKind.Photo
    val message = "Test"
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(Long.MAX_VALUE, state.token)
  }
  
  @Test
  fun testCameraHudStateWithLongMessage() {
    val token = 1L
    val kind = CameraHudKind.Photo
    val message = "A".repeat(1000)
    
    val state = CameraHudState(token, kind, message)
    
    assertEquals(message, state.message)
    assertEquals(1000, state.message.length)
  }
  
  @Test
  fun testCameraHudStateDataClassEquality() {
    val state1 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val state2 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    
    assertEquals(state1, state2)
  }
  
  @Test
  fun testCameraHudStateDataClassInequality() {
    val state1 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val state2 = CameraHudState(456L, CameraHudKind.Recording, "Different")
    
    assertEquals(state1, state1)
    assertEquals(state2, state2)
  }
  
  @Test
  fun testCameraHudStateDataClassHashCode() {
    val state1 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val state2 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    
    assertEquals(state1.hashCode(), state2.hashCode())
  }
  
  @Test
  fun testCameraHudStateDataClassToString() {
    val state = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val str = state.toString()
    
    assert(str.contains("123"))
    assert(str.contains("Photo"))
    assert(str.contains("Test"))
  }
  
  @Test
  fun testCameraHudStateDataClassCopy() {
    val state1 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val state2 = state1.copy()
    
    assertEquals(state1, state2)
  }
  
  @Test
  fun testCameraHudStateDataClassCopyWithTokenChange() {
    val state1 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val state2 = state1.copy(token = 456L)
    
    assertEquals(123L, state1.token)
    assertEquals(456L, state2.token)
    assertEquals(state1.kind, state2.kind)
    assertEquals(state1.message, state2.message)
  }
  
  @Test
  fun testCameraHudStateDataClassCopyWithKindChange() {
    val state1 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val state2 = state1.copy(kind = CameraHudKind.Success)
    
    assertEquals(state1.token, state2.token)
    assertEquals(CameraHudKind.Photo, state1.kind)
    assertEquals(CameraHudKind.Success, state2.kind)
    assertEquals(state1.message, state2.message)
  }
  
  @Test
  fun testCameraHudStateDataClassCopyWithMessageChange() {
    val state1 = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val state2 = state1.copy(message = "Updated")
    
    assertEquals(state1.token, state2.token)
    assertEquals(state1.kind, state2.kind)
    assertEquals("Test", state1.message)
    assertEquals("Updated", state2.message)
  }
  
  @Test
  fun testCameraHudStateDataClassDestructuring() {
    val state = CameraHudState(123L, CameraHudKind.Photo, "Test")
    val (token, kind, message) = state
    
    assertEquals(123L, token)
    assertEquals(CameraHudKind.Photo, kind)
    assertEquals("Test", message)
  }
  
  @Test
  fun testCameraHudKindEnumPhoto() {
    assertEquals(CameraHudKind.Photo, CameraHudKind.Photo)
  }
  
  @Test
  fun testCameraHudKindEnumRecording() {
    assertEquals(CameraHudKind.Recording, CameraHudKind.Recording)
  }
  
  @Test
  fun testCameraHudKindEnumSuccess() {
    assertEquals(CameraHudKind.Success, CameraHudKind.Success)
  }
  
  @Test
  fun testCameraHudKindEnumError() {
    assertEquals(CameraHudKind.Error, CameraHudKind.Error)
  }
  
  @Test
  fun testCameraHudKindEnumValues() {
    val values = CameraHudKind.values()
    assertEquals(4, values.size)
    assert(values.contains(CameraHudKind.Photo))
    assert(values.contains(CameraHudKind.Recording))
    assert(values.contains(CameraHudKind.Success))
    assert(values.contains(CameraHudKind.Error))
  }
  
  @Test
  fun testCameraHudKindEnumValueOf() {
    assertEquals(CameraHudKind.Photo, CameraHudKind.valueOf("Photo"))
    assertEquals(CameraHudKind.Recording, CameraHudKind.valueOf("Recording"))
    assertEquals(CameraHudKind.Success, CameraHudKind.valueOf("Success"))
    assertEquals(CameraHudKind.Error, CameraHudKind.valueOf("Error"))
  }
  
  @Test
  fun testCameraHudStateWithSpecialCharactersInMessage() {
    val message = "Test @#$%^&*()_+-={}[]|:;<>?,./"
    val state = CameraHudState(1L, CameraHudKind.Photo, message)
    
    assertEquals(message, state.message)
  }
  
  @Test
  fun testCameraHudStateWithUnicodeInMessage() {
    val message = "Test 日本語 العربية Ελληνικά"
    val state = CameraHudState(1L, CameraHudKind.Photo, message)
    
    assertEquals(message, state.message)
  }
}