//
//package com.example.sos_wear_app
//
//import android.Manifest
//import android.content.pm.PackageManager
//import android.os.Build
//import androidx.annotation.NonNull
//import androidx.core.app.ActivityCompat
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import com.google.android.gms.location.FusedLocationProviderClient
//import com.google.android.gms.location.LocationServices
//import com.google.android.gms.location.LocationRequest
//import com.google.android.gms.location.Priority
//import com.google.android.gms.tasks.Task
//import android.location.Location
//import com.google.android.gms.tasks.CancellationTokenSource
//import android.os.Handler
//import android.os.Looper
//import android.util.Log
//
//class MainActivity : FlutterActivity() {
//    private val CHANNEL = "location_service"
//    private lateinit var fusedLocationClient: FusedLocationProviderClient
//    private val cancellationTokenSource = CancellationTokenSource()
//    private val TAG = "WearLocationService"
//
//    // Timeout for location requests (10 seconds)
//    private val LOCATION_TIMEOUT = 10000L
//
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            when (call.method) {
//                "getCurrentLocation" -> {
//                    if (checkLocationPermissions()) {
//                        getCurrentLocationWithFallback(result)
//                    } else {
//                        result.error("PERMISSION_DENIED", "Location permissions not granted", null)
//                    }
//                }
//                else -> result.notImplemented()
//            }
//        }
//    }
//
//    private fun getCurrentLocationWithFallback(result: MethodChannel.Result) {
//        if (!checkLocationPermissions()) {
//            result.error("PERMISSION_DENIED", "Location permissions not granted", null)
//            return
//        }
//
//        Log.d(TAG, "Starting location request...")
//
//        // Set up timeout handler
//        val timeoutHandler = Handler(Looper.getMainLooper())
//        var isCompleted = false
//
//        val timeoutRunnable = Runnable {
//            if (!isCompleted) {
//                isCompleted = true
//                cancellationTokenSource.cancel()
//                Log.w(TAG, "Location request timed out, trying last known location")
//                getLastKnownLocationAsFallback(result)
//            }
//        }
//
//        timeoutHandler.postDelayed(timeoutRunnable, LOCATION_TIMEOUT)
//
//        // Try to get current location with optimized settings for Wear OS
//        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000)
//                .setWaitForAccurateLocation(false) // Don't wait for high accuracy on Wear OS
//                .setMaxUpdateDelayMillis(5000)    // Max 5 seconds delay
//                .setMinUpdateIntervalMillis(1000) // Minimum 1 second between updates
//                .build()
//
//        fusedLocationClient.getCurrentLocation(
//                Priority.PRIORITY_HIGH_ACCURACY,
//                cancellationTokenSource.token
//        ).addOnCompleteListener { task: Task<Location> ->
//            timeoutHandler.removeCallbacks(timeoutRunnable)
//
//            if (!isCompleted) {
//                isCompleted = true
//
//                if (task.isSuccessful && task.result != null) {
//                    val location = task.result
//                    Log.d(TAG, "Got current location: ${location.latitude}, ${location.longitude}")
//                    result.success(mapOf(
//                            "latitude" to location.latitude,
//                            "longitude" to location.longitude,
//                            "accuracy" to location.accuracy.toDouble(),
//                            "timestamp" to location.time,
//                            "source" to "current"
//                    ))
//                } else {
//                    Log.w(TAG, "Current location failed: ${task.exception?.message}")
//                    // Fallback to last known location
//                    getLastKnownLocationAsFallback(result)
//                }
//            }
//        }
//    }
//
//    private fun getLastKnownLocationAsFallback(result: MethodChannel.Result) {
//        if (!checkLocationPermissions()) {
//            result.error("PERMISSION_DENIED", "Location permissions not granted", null)
//            return
//        }
//
//        fusedLocationClient.lastLocation.addOnCompleteListener { task ->
//            if (task.isSuccessful && task.result != null) {
//                val location = task.result
//                Log.d(TAG, "Got last known location: ${location.latitude}, ${location.longitude}")
//                result.success(mapOf(
//                        "latitude" to location.latitude,
//                        "longitude" to location.longitude,
//                        "accuracy" to location.accuracy.toDouble(),
//                        "timestamp" to location.time,
//                        "source" to "cached"
//                ))
//            } else {
//                Log.e(TAG, "Failed to get any location: ${task.exception?.message}")
//                result.error("LOCATION_ERROR", "Failed to get location: ${task.exception?.message}", null)
//            }
//        }
//    }
//
//    private fun checkLocationPermissions(): Boolean {
//        val fineLocationGranted = ActivityCompat.checkSelfPermission(
//                this,
//                Manifest.permission.ACCESS_FINE_LOCATION
//        ) == PackageManager.PERMISSION_GRANTED
//
//        val coarseLocationGranted = ActivityCompat.checkSelfPermission(
//                this,
//                Manifest.permission.ACCESS_COARSE_LOCATION
//        ) == PackageManager.PERMISSION_GRANTED
//
//        return fineLocationGranted || coarseLocationGranted
//    }
//
//    override fun onDestroy() {
//        cancellationTokenSource.cancel()
//        super.onDestroy()
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
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val CHANNEL = "location_service"
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var cancellationTokenSource = CancellationTokenSource()
    private val TAG = "WearLocationService"

    // Timeout for location requests (8 seconds - reduced for better UX)
    private val LOCATION_TIMEOUT = 8000L

    // Thread-safe completion tracking
    private val isRequestActive = AtomicBoolean(false)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        try {
            fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
            Log.d(TAG, "FusedLocationProviderClient initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize location client: ${e.message}", e)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getCurrentLocation" -> {
                        handleLocationRequest(result)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in method channel handler: ${e.message}", e)
                safeErrorResult(result, "METHOD_ERROR", "Method call failed: ${e.message}")
            }
        }
    }

    private fun handleLocationRequest(result: MethodChannel.Result) {
        try {
            // Prevent multiple concurrent requests
            if (!isRequestActive.compareAndSet(false, true)) {
                Log.w(TAG, "Location request already in progress")
                safeErrorResult(result, "REQUEST_IN_PROGRESS", "Another location request is already active")
                return
            }

            if (!checkLocationPermissions()) {
                isRequestActive.set(false)
                safeErrorResult(result, "PERMISSION_DENIED", "Location permissions not granted")
                return
            }

            if (!::fusedLocationClient.isInitialized) {
                isRequestActive.set(false)
                safeErrorResult(result, "CLIENT_ERROR", "Location client not initialized")
                return
            }

            getCurrentLocationWithFallback(result)

        } catch (e: Exception) {
            isRequestActive.set(false)
            Log.e(TAG, "Error handling location request: ${e.message}", e)
            safeErrorResult(result, "REQUEST_ERROR", "Failed to process location request: ${e.message}")
        }
    }

    private fun getCurrentLocationWithFallback(result: MethodChannel.Result) {
        var timeoutHandler: Handler? = null
        var timeoutRunnable: Runnable? = null

        try {
            Log.d(TAG, "Starting location request...")

            // Create fresh cancellation token for each request
            cancellationTokenSource = CancellationTokenSource()

            // Set up timeout handler with null safety
            timeoutHandler = Handler(Looper.getMainLooper())
            timeoutRunnable = Runnable {
                try {
                    if (isRequestActive.get()) {
                        Log.w(TAG, "Location request timed out, trying fallback")
                        cancellationTokenSource.cancel()
                        getLastKnownLocationAsFallback(result)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error in timeout handler: ${e.message}", e)
                    completeRequestSafely(result, "TIMEOUT_ERROR", "Location request timed out with error")
                }
            }

            timeoutHandler.postDelayed(timeoutRunnable, LOCATION_TIMEOUT)

            // Get current location with error handling
            fusedLocationClient.getCurrentLocation(
                    Priority.PRIORITY_HIGH_ACCURACY,
                    cancellationTokenSource.token
            ).addOnCompleteListener { task: Task<Location> ->
                try {
                    // Remove timeout callback safely
                    timeoutHandler?.removeCallbacks(timeoutRunnable ?: return@addOnCompleteListener)

                    if (!isRequestActive.get()) {
                        Log.d(TAG, "Request already completed, ignoring result")
                        return@addOnCompleteListener
                    }

                    if (task.isSuccessful && task.result != null) {
                        val location = task.result
                        Log.d(TAG, "Got current location: ${location.latitude}, ${location.longitude}")

                        val locationData = createLocationMap(location, "current")
                        completeRequestSafely(result, locationData)

                    } else {
                        val exception = task.exception
                        Log.w(TAG, "Current location failed: ${exception?.message}")

                        // Try fallback instead of immediate error
                        getLastKnownLocationAsFallback(result)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error in location complete listener: ${e.message}", e)
                    completeRequestSafely(result, "LOCATION_ERROR", "Error processing location result")
                }
            }.addOnFailureListener { exception ->
                try {
                    timeoutHandler?.removeCallbacks(timeoutRunnable ?: return@addOnFailureListener)
                    Log.e(TAG, "Location request failed: ${exception.message}", exception)

                    if (isRequestActive.get()) {
                        getLastKnownLocationAsFallback(result)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error in failure listener: ${e.message}", e)
                    completeRequestSafely(result, "LOCATION_ERROR", "Location request failed")
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error starting location request: ${e.message}", e)
            timeoutHandler?.removeCallbacks(timeoutRunnable ?: Runnable {})
            completeRequestSafely(result, "START_ERROR", "Failed to start location request")
        }
    }

    private fun getLastKnownLocationAsFallback(result: MethodChannel.Result) {
        try {
            if (!isRequestActive.get()) {
                Log.d(TAG, "Request already completed, skipping fallback")
                return
            }

            if (!checkLocationPermissions()) {
                completeRequestSafely(result, "PERMISSION_DENIED", "Location permissions not granted for fallback")
                return
            }

            Log.d(TAG, "Attempting fallback to last known location")

            fusedLocationClient.lastLocation.addOnCompleteListener { task ->
                try {
                    if (!isRequestActive.get()) {
                        Log.d(TAG, "Request already completed, ignoring fallback result")
                        return@addOnCompleteListener
                    }

                    if (task.isSuccessful && task.result != null) {
                        val location = task.result
                        Log.d(TAG, "Got last known location: ${location.latitude}, ${location.longitude}")

                        val locationData = createLocationMap(location, "cached")
                        completeRequestSafely(result, locationData)

                    } else {
                        Log.e(TAG, "Failed to get any location: ${task.exception?.message}")
                        completeRequestSafely(result, "NO_LOCATION", "No location available from any source")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error in last location listener: ${e.message}", e)
                    completeRequestSafely(result, "FALLBACK_ERROR", "Error in location fallback")
                }
            }.addOnFailureListener { exception ->
                try {
                    Log.e(TAG, "Last location request failed: ${exception.message}", exception)
                    completeRequestSafely(result, "FALLBACK_FAILED", "Fallback location request failed")
                } catch (e: Exception) {
                    Log.e(TAG, "Error in fallback failure listener: ${e.message}", e)
                    completeRequestSafely(result, "FALLBACK_ERROR", "Critical error in fallback")
                }
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error in fallback method: ${e.message}", e)
            completeRequestSafely(result, "FALLBACK_ERROR", "Exception in fallback method")
        }
    }

    private fun createLocationMap(location: Location, source: String): Map<String, Any> {
        return try {
            mapOf(
                    "latitude" to location.latitude,
                    "longitude" to location.longitude,
                    "accuracy" to (if (location.hasAccuracy()) location.accuracy.toDouble() else -1.0),
                    "timestamp" to location.time,
                    "source" to source
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error creating location map: ${e.message}", e)
            mapOf(
                    "latitude" to location.latitude,
                    "longitude" to location.longitude,
                    "source" to source,
                    "error" to "partial_data"
            )
        }
    }

    private fun completeRequestSafely(result: MethodChannel.Result, data: Map<String, Any>) {
        try {
            if (isRequestActive.compareAndSet(true, false)) {
                result.success(data)
                Log.d(TAG, "Location request completed successfully")
            } else {
                Log.d(TAG, "Request already completed, not sending duplicate result")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error completing request with success: ${e.message}", e)
        }
    }

    private fun completeRequestSafely(result: MethodChannel.Result, code: String, message: String) {
        try {
            if (isRequestActive.compareAndSet(true, false)) {
                result.error(code, message, null)
                Log.e(TAG, "Location request completed with error: $code - $message")
            } else {
                Log.d(TAG, "Request already completed, not sending duplicate error")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error completing request with error: ${e.message}", e)
        }
    }

    private fun safeErrorResult(result: MethodChannel.Result, code: String, message: String) {
        try {
            result.error(code, message, null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send error result: ${e.message}", e)
        }
    }

    private fun checkLocationPermissions(): Boolean {
        return try {
            val fineLocationGranted = ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED

            val coarseLocationGranted = ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED

            fineLocationGranted || coarseLocationGranted
        } catch (e: Exception) {
            Log.e(TAG, "Error checking permissions: ${e.message}", e)
            false
        }
    }

    override fun onDestroy() {
        try {
            isRequestActive.set(false)
            cancellationTokenSource.cancel()
            Log.d(TAG, "MainActivity destroyed, cancelled location requests")
        } catch (e: Exception) {
            Log.e(TAG, "Error in onDestroy: ${e.message}", e)
        }
        super.onDestroy()
    }
}

