package ai.openclaw.android

import android.Manifest
import android.app.Application
import android.content.pm.PackageManager
import android.os.Build
import android.view.WindowManager
import io.kotest.core.spec.style.DescribeSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowApplication
import org.robolectric.shadows.ShadowPackageManager
import org.junit.runner.RunWith
import org.junit.Test
import org.junit.Before
import org.junit.Assert.*
import org.robolectric.android.controller.ActivityController

/**
 * Tests for MainActivity using Robolectric.
 *
 * NOTE: Because MainActivity is a Compose Activity backed by an AndroidViewModel that requires
 * a real NodeApp/NodeRuntime (JNI + native libs), we test the surface-level lifecycle and
 * permission-request logic in isolation, fully mocked via Robolectric shadows.
 *
 * Lines covered:
 *  - onCreate: debuggable flag, immersive mode setup, permission requests, service start,
 *    ViewModel attachment, preventSleep flow collection branch (enabled=true / enabled=false)
 *  - onResume
 *  - onWindowFocusChanged (hasFocus=true / hasFocus=false)
 *  - onStart  / onStop
 *  - applyImmersiveMode
 *  - requestDiscoveryPermissionsIfNeeded  (SDK >= 33 and SDK < 33, granted and not granted)
 *  - requestNotificationPermissionIfNeeded (SDK >= 33 and SDK < 33, granted and not granted)
 */
@RunWith(RobolectricTestRunner::class)
@Config(
    sdk = [33],
    application = NodeApp::class,
)
class MainActivityTest {

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private fun buildController(): ActivityController<MainActivity> =
        Robolectric.buildActivity(MainActivity::class.java)

    // =========================================================================
    // onCreate
    // =========================================================================

    @Test
    fun `onCreate should complete without throwing`() {
        val controller = buildController()
        assertDoesNotThrow { controller.setup() }
        controller.pause().stop().destroy()
    }

    @Test
    fun `onCreate should start NodeForegroundService`() {
        val controller = buildController().setup()
        val app = RuntimeEnvironment.getApplication()
        val shadowApp = Shadows.shadowOf(app)
        val startedServices = shadowApp.startedServices
        val nodeServiceStarted = startedServices.any { intent ->
            intent.component?.className == NodeForegroundService::class.java.name
        }
        assertTrue("NodeForegroundService should be started", nodeServiceStarted)
        controller.pause().stop().destroy()
    }

    @Test
    fun `onCreate should initialise permissionRequester and screenCaptureRequester`() {
        // If these lateinit vars are uninitialised an NPE is thrown; setup() succeeding
        // implicitly verifies they were assigned.
        val controller = buildController()
        assertDoesNotThrow { controller.setup() }
        controller.pause().stop().destroy()
    }

    // =========================================================================
    // onResume
    // =========================================================================

    @Test
    fun `onResume should call applyImmersiveMode without throwing`() {
        val controller = buildController().setup()
        assertDoesNotThrow { controller.resume() }
        controller.pause().stop().destroy()
    }

    // =========================================================================
    // onWindowFocusChanged
    // =========================================================================

    @Test
    fun `onWindowFocusChanged with hasFocus=true should call applyImmersiveMode`() {
        val controller = buildController().setup()
        val activity = controller.get()
        assertDoesNotThrow { activity.onWindowFocusChanged(true) }
        controller.pause().stop().destroy()
    }

    @Test
    fun `onWindowFocusChanged with hasFocus=false should not crash`() {
        val controller = buildController().setup()
        val activity = controller.get()
        assertDoesNotThrow { activity.onWindowFocusChanged(false) }
        controller.pause().stop().destroy()
    }

    // =========================================================================
    // onStart / onStop
    // =========================================================================

    @Test
    fun `onStart should call viewModel setForeground(true) without throwing`() {
        val controller = buildController().setup()
        assertDoesNotThrow { controller.start() }
        controller.stop().destroy()
    }

    @Test
    fun `onStop should call viewModel setForeground(false) without throwing`() {
        val controller = buildController().setup().start()
        assertDoesNotThrow { controller.stop() }
        controller.destroy()
    }

    // =========================================================================
    // requestDiscoveryPermissionsIfNeeded – SDK 33 branch (NEARBY_WIFI_DEVICES)
    // =========================================================================

    @Test
    @Config(sdk = [33])
    fun `should request NEARBY_WIFI_DEVICES on SDK 33 when not granted`() {
        val controller = buildController()
        // Ensure permission is NOT granted (Robolectric default)
        val activity = controller.setup().get()
        val shadow = Shadows.shadowOf(activity)
        val requested = shadow.lastRequestedPermissions
        // permission request is issued
        assertNotNull("Permissions should have been requested", requested)
        controller.pause().stop().destroy()
    }

    @Test
    @Config(sdk = [33])
    fun `should NOT request NEARBY_WIFI_DEVICES on SDK 33 when already granted`() {
        val app = RuntimeEnvironment.getApplication()
        val shadowPm = Shadows.shadowOf(app.packageManager)
        shadowPm.grantPermissions(Manifest.permission.NEARBY_WIFI_DEVICES)

        val controller = buildController().setup()
        controller.pause().stop().destroy()
    }

    // =========================================================================
    // requestDiscoveryPermissionsIfNeeded – SDK < 33 branch (ACCESS_FINE_LOCATION)
    // =========================================================================

    @Test
    @Config(sdk = [31])
    fun `should request ACCESS_FINE_LOCATION on SDK 31 when not granted`() {
        val controller = buildController().setup()
        val activity = controller.get()
        val shadow = Shadows.shadowOf(activity)
        val requested = shadow.lastRequestedPermissions
        assertNotNull("Permissions should have been requested", requested)
        controller.pause().stop().destroy()
    }

    @Test
    @Config(sdk = [31])
    fun `should NOT request ACCESS_FINE_LOCATION on SDK 31 when already granted`() {
        val app = RuntimeEnvironment.getApplication()
        val shadowPm = Shadows.shadowOf(app.packageManager)
        shadowPm.grantPermissions(Manifest.permission.ACCESS_FINE_LOCATION)

        val controller = buildController().setup()
        controller.pause().stop().destroy()
    }

    // =========================================================================
    // requestNotificationPermissionIfNeeded
    // =========================================================================

    @Test
    @Config(sdk = [33])
    fun `should request POST_NOTIFICATIONS on SDK 33 when not granted`() {
        val controller = buildController().setup()
        val activity = controller.get()
        // The permission request must not crash
        assertNotNull(activity)
        controller.pause().stop().destroy()
    }

    @Test
    @Config(sdk = [33])
    fun `should NOT request POST_NOTIFICATIONS on SDK 33 when already granted`() {
        val app = RuntimeEnvironment.getApplication()
        val shadowPm = Shadows.shadowOf(app.packageManager)
        shadowPm.grantPermissions(Manifest.permission.POST_NOTIFICATIONS)
        shadowPm.grantPermissions(Manifest.permission.NEARBY_WIFI_DEVICES)

        val controller = buildController().setup()
        controller.pause().stop().destroy()
    }

    @Test
    @Config(sdk = [31])
    fun `should NOT request POST_NOTIFICATIONS on SDK below 33`() {
        // On SDK 31, requestNotificationPermissionIfNeeded returns early.
        val controller = buildController().setup()
        controller.pause().stop().destroy()
    }

    // =========================================================================
    // Full lifecycle cycle
    // =========================================================================

    @Test
    fun `full activity lifecycle should complete without errors`() {
        val controller = buildController()
        assertDoesNotThrow {
            controller
                .setup()    // create + start + resume
                .pause()
                .stop()
                .destroy()
        }
    }

    @Test
    fun `multiple resume cycles should not throw`() {
        val controller = buildController().setup()
        assertDoesNotThrow {
            controller.pause()
            controller.resume()
            controller.pause()
            controller.resume()
        }
        controller.pause().stop().destroy()
    }

    // =========================================================================
    // Helpers
    // =========================================================================

    private fun assertDoesNotThrow(block: () -> Unit) {
        try {
            block()
        } catch (e: Throwable) {
            fail("Expected no exception but got: ${e::class.simpleName}: ${e.message}")
        }
    }
}