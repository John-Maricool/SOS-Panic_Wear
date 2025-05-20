package com.example.sos_wear_app
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.location.Location
import android.os.Bundle
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import io.flutter.plugin.common.EventChannel
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationRequest
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "location_service"
    private val LOCATION_CHANNEL = "location_updates"
    private val PERMISSION_REQUEST_CODE = 123
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var locationCallback: LocationCallback // Declare locationCallback as a class property

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "requestPermission" -> {
                            requestLocationPermission(result)
                        }
                        "checkPermission" -> {
                            result.success(checkLocationPermission())
                        }
                        else -> result.notImplemented()
                    }
                }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL)
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                        this@MainActivity.eventSink = eventSink
                        startLocationUpdates()
                    }

                    override fun onCancel(arguments: Any?) {
                        stopLocationUpdates()
                    }
                })
    }

    private fun requestLocationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ActivityCompat.checkSelfPermission(
                            this,
                            Manifest.permission.ACCESS_FINE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
            ) {
                result.success(true)
                return
            }
            ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                    PERMISSION_REQUEST_CODE
            )
        }
    }

    private fun checkLocationPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun startLocationUpdates() {
        if (checkLocationPermission()) {
            val locationRequest = getLocationRequest()
            locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    for (location in locationResult.locations) {
                        eventSink?.success("${location.latitude} ${location.longitude}")
                    }
                }
            }
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null)
        }
    }

    private fun stopLocationUpdates() {
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }

    private fun getLocationRequest(): LocationRequest {
        return LocationRequest.create().apply {
            interval = 5000
            fastestInterval = 5000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }
    }

    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<out String>,
            grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                eventSink?.success(true)
            } else {
                eventSink?.success(false)
            }
        }
    }
}