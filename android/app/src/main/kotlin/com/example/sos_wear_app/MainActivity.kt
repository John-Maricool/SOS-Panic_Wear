//package com.example.sos_wear_app
//import android.Manifest
//import android.content.pm.PackageManager
//import android.os.Build
//import androidx.annotation.NonNull
//import androidx.core.app.ActivityCompat
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.plugins.GeneratedPluginRegistrant
//import android.location.Location
//import android.os.Bundle
//import com.google.android.gms.location.FusedLocationProviderClient
//import com.google.android.gms.location.LocationServices
//import io.flutter.plugin.common.EventChannel
//import com.google.android.gms.location.LocationCallback
//import com.google.android.gms.location.LocationResult
//import com.google.android.gms.location.LocationRequest
//import java.util.concurrent.TimeUnit
//
//class MainActivity : FlutterActivity() {
//    private val CHANNEL = "location_service"
//    private val LOCATION_CHANNEL = "location_updates"
//    private val PERMISSION_REQUEST_CODE = 123
//    private lateinit var fusedLocationClient: FusedLocationProviderClient
//    private var eventSink: EventChannel.EventSink? = null
//    private lateinit var locationCallback: LocationCallback // Declare locationCallback as a class property
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
//    }
//
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//                .setMethodCallHandler { call, result ->
//                    when (call.method) {
//                        "requestPermission" -> {
//                            requestLocationPermission(result)
//                        }
//                        "checkPermission" -> {
//                            result.success(checkLocationPermission())
//                        }
//                        else -> result.notImplemented()
//                    }
//                }
//
//        EventChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL)
//                .setStreamHandler(object : EventChannel.StreamHandler {
//                    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
//                        this@MainActivity.eventSink = eventSink
//                        startLocationUpdates()
//                    }
//
//                    override fun onCancel(arguments: Any?) {
//                        stopLocationUpdates()
//                    }
//                })
//    }
//
//    private fun requestLocationPermission(result: MethodChannel.Result) {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            if (ActivityCompat.checkSelfPermission(
//                            this,
//                            Manifest.permission.ACCESS_FINE_LOCATION
//                    ) == PackageManager.PERMISSION_GRANTED
//            ) {
//                result.success(true)
//                return
//            }
//            ActivityCompat.requestPermissions(
//                    this,
//                    arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
//                    PERMISSION_REQUEST_CODE
//            )
//        }
//    }
//
//    private fun checkLocationPermission(): Boolean {
//        return ActivityCompat.checkSelfPermission(
//                this,
//                Manifest.permission.ACCESS_FINE_LOCATION
//        ) == PackageManager.PERMISSION_GRANTED
//    }
//
//    private fun startLocationUpdates() {
//        if (checkLocationPermission()) {
//            val locationRequest = getLocationRequest()
//            locationCallback = object : LocationCallback() {
//                override fun onLocationResult(locationResult: LocationResult) {
//                    for (location in locationResult.locations) {
//                        eventSink?.success("${location.latitude} ${location.longitude}")
//                    }
//                }
//            }
//            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null)
//        }
//    }
//
//    private fun stopLocationUpdates() {
//        fusedLocationClient.removeLocationUpdates(locationCallback)
//    }
//
//    private fun getLocationRequest(): LocationRequest {
//        return LocationRequest.create().apply {
//            interval = 5000
//            fastestInterval = 5000
//            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
//        }
//    }
//
//    override fun onRequestPermissionsResult(
//            requestCode: Int,
//            permissions: Array<out String>,
//            grantResults: IntArray
//    ) {
//        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
//        if (requestCode == PERMISSION_REQUEST_CODE) {
//            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                eventSink?.success(true)
//            } else {
//                eventSink?.success(false)
//            }
//        }
//    }
//}
package com.example.sos_wear_app

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.Task
import android.location.Location
import com.google.android.gms.tasks.CancellationTokenSource
import android.os.Handler
import android.os.Looper
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "location_service"
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private val cancellationTokenSource = CancellationTokenSource()
    private val TAG = "WearLocationService"

    // Timeout for location requests (10 seconds)
    private val LOCATION_TIMEOUT = 10000L

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentLocation" -> {
                    if (checkLocationPermissions()) {
                        getCurrentLocationWithFallback(result)
                    } else {
                        result.error("PERMISSION_DENIED", "Location permissions not granted", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getCurrentLocationWithFallback(result: MethodChannel.Result) {
        if (!checkLocationPermissions()) {
            result.error("PERMISSION_DENIED", "Location permissions not granted", null)
            return
        }

        Log.d(TAG, "Starting location request...")

        // Set up timeout handler
        val timeoutHandler = Handler(Looper.getMainLooper())
        var isCompleted = false

        val timeoutRunnable = Runnable {
            if (!isCompleted) {
                isCompleted = true
                cancellationTokenSource.cancel()
                Log.w(TAG, "Location request timed out, trying last known location")
                getLastKnownLocationAsFallback(result)
            }
        }

        timeoutHandler.postDelayed(timeoutRunnable, LOCATION_TIMEOUT)

        // Try to get current location with optimized settings for Wear OS
        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000)
                .setWaitForAccurateLocation(false) // Don't wait for high accuracy on Wear OS
                .setMaxUpdateDelayMillis(5000)    // Max 5 seconds delay
                .setMinUpdateIntervalMillis(1000) // Minimum 1 second between updates
                .build()

        fusedLocationClient.getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                cancellationTokenSource.token
        ).addOnCompleteListener { task: Task<Location> ->
            timeoutHandler.removeCallbacks(timeoutRunnable)

            if (!isCompleted) {
                isCompleted = true

                if (task.isSuccessful && task.result != null) {
                    val location = task.result
                    Log.d(TAG, "Got current location: ${location.latitude}, ${location.longitude}")
                    result.success(mapOf(
                            "latitude" to location.latitude,
                            "longitude" to location.longitude,
                            "accuracy" to location.accuracy.toDouble(),
                            "timestamp" to location.time,
                            "source" to "current"
                    ))
                } else {
                    Log.w(TAG, "Current location failed: ${task.exception?.message}")
                    // Fallback to last known location
                    getLastKnownLocationAsFallback(result)
                }
            }
        }
    }

    private fun getLastKnownLocationAsFallback(result: MethodChannel.Result) {
        if (!checkLocationPermissions()) {
            result.error("PERMISSION_DENIED", "Location permissions not granted", null)
            return
        }

        fusedLocationClient.lastLocation.addOnCompleteListener { task ->
            if (task.isSuccessful && task.result != null) {
                val location = task.result
                Log.d(TAG, "Got last known location: ${location.latitude}, ${location.longitude}")
                result.success(mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                        "accuracy" to location.accuracy.toDouble(),
                        "timestamp" to location.time,
                        "source" to "cached"
                ))
            } else {
                Log.e(TAG, "Failed to get any location: ${task.exception?.message}")
                result.error("LOCATION_ERROR", "Failed to get location: ${task.exception?.message}", null)
            }
        }
    }

    private fun checkLocationPermissions(): Boolean {
        val fineLocationGranted = ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        val coarseLocationGranted = ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        return fineLocationGranted || coarseLocationGranted
    }

    override fun onDestroy() {
        cancellationTokenSource.cancel()
        super.onDestroy()
    }
}