package com.example.screen_locker

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.system.exitProcess
import android.app.ActivityManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.screen_locker/device_admin"
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var componentName: ComponentName

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        componentName = ComponentName(this, DeviceAdminReceiver::class.java)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDeviceAdmin" -> {
                    result.success(devicePolicyManager.isAdminActive(componentName))
                }
                "requestDeviceAdmin" -> {
                    val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
                    intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
                    intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "Device admin permission is required to lock the screen")
                    startActivityForResult(intent, 1)
                    result.success(true)
                }
                "lockScreen" -> {
                    if (devicePolicyManager.isAdminActive(componentName)) {
                        lockScreenAndExit()
                        result.success(true)
                    } else {
                        result.error("PERMISSION_DENIED", "Device admin permission not granted", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun lockScreenAndExit() {
        devicePolicyManager.lockNow()
        android.os.Handler().postDelayed({
            // Remove from recent apps
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            activityManager.appTasks.forEach { task ->
                task.finishAndRemoveTask()
            }
            // Close all activities and exit
            finishAndRemoveTask()
            finishAffinity()
            exitProcess(0)
        }, 500)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1) {
            if (devicePolicyManager.isAdminActive(componentName)) {
                lockScreenAndExit()
            }
        }
    }
}