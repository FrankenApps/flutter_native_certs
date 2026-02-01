package de.frankenapps.flutter_native_certs

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.KeyStore
import java.security.MessageDigest
import java.security.cert.X509Certificate

/**
 * The FlutterNativeCertsPlugin is used to load all certificates from Androids'
 * certificate store and supply them to the Flutter engine.
 */
class FlutterNativeCertsPlugin : FlutterPlugin, MethodCallHandler {
    // The MethodChannel that will facilitate the communication between Flutter and native Android.
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity.
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_native_certs")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "getCertificates") {
            getCertificates(call, result)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    /**
     * Loads all certificates from the native certificate store and returns them to the Flutter
     * engine.
     *
     * @param call The method call from Flutter.
     * @param result The result of the method call.
     */
    private fun getCertificates(call: MethodCall, result: Result) {
        val includeSystem = call.argument<Boolean>("includeSystemCertificates") ?: true
        val includeUser = call.argument<Boolean>("includeUserCertificates") ?: true

        val certificates: List<X509Certificate> = try {
            val keyStore = KeyStore.getInstance("AndroidCAStore")
            keyStore.load(null, null)
            keyStore.aliases().toList().filter { alias ->
                (includeUser && alias.startsWith("user")) ||
                        (includeSystem && alias.startsWith("system"))
            }.map { alias ->
                keyStore.getCertificate(alias) as X509Certificate
            }
        } catch (e: Exception) {
            result.error(
                "getCertificates",
                "Failed to load certificates",
                e.localizedMessage)
            return
        }

        val certificateList = certificates.map { cert ->
            val sha1Digest = MessageDigest.getInstance("SHA-1")
            mapOf(
                "subject" to cert.subjectX500Principal.name,
                "issuer" to cert.issuerX500Principal.name,
                "der" to cert.encoded,
                "sha1" to sha1Digest.digest(cert.encoded),
                "startValidity" to cert.notBefore.time,
                "endValidity" to cert.notAfter.time
            )
        }
        result.success(certificateList)
    }
}
