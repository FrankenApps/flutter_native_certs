package de.frankenapps.flutter_native_certs

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import java.security.cert.X509Certificate
import java.util.Date
import kotlin.test.assertEquals
import kotlin.test.Test

internal class FlutterNativeCertsPluginTest {
    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        val plugin = FlutterNativeCertsPlugin()

        val call = MethodCall("unknownMethod", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }

    @Test
    fun filterExpiredCertificates_excludesExpiredCertificatesByDefault() {
        val now = Date(1_000)
        val expiredCertificate = certificateExpiringAt(999)
        val validCertificate = certificateExpiringAt(1_001)

        val result = filterExpiredCertificates(
            listOf(expiredCertificate, validCertificate),
            includeExpired = false,
            now = now
        )

        assertEquals(listOf(validCertificate), result)
    }

    @Test
    fun filterExpiredCertificates_includesExpiredCertificatesWhenRequested() {
        val expiredCertificate = certificateExpiringAt(999)
        val validCertificate = certificateExpiringAt(1_001)

        val result = filterExpiredCertificates(
            listOf(expiredCertificate, validCertificate),
            includeExpired = true,
            now = Date(1_000)
        )

        assertEquals(listOf(expiredCertificate, validCertificate), result)
    }

    private fun certificateExpiringAt(timestamp: Long): X509Certificate =
        Mockito.mock(X509Certificate::class.java).also { certificate ->
            Mockito.`when`(certificate.notAfter).thenReturn(Date(timestamp))
        }
}
