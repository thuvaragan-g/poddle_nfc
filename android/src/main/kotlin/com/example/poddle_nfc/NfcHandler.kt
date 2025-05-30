package com.example.poddle_nfc

import android.net.Uri
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.nfc.tech.NdefFormatable
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

const val kId = "nfcId"
const val kContent = "nfcContent"
const val kError = "nfcError"
const val kStatus = "nfcStatus"

@RequiresApi(Build.VERSION_CODES.KITKAT)
sealed class AbstractNfcHandler(protected val result: MethodChannel.Result, protected val call: MethodCall) : NfcAdapter.ReaderCallback {
    protected fun unregister() = PoddleNfcPlugin.listeners.remove(this)
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
class NfcWriter(result: MethodChannel.Result, call: MethodCall) : AbstractNfcHandler(result, call) {
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onTagDiscovered(tag: Tag) {
        val type = call.argument<String>("path")
                ?: return result.error("404", "Missing parameter", null)
        val payload = call.argument<String>("label")
                ?: return result.error("404", "Missing parameter", null)
//        val nfcRecord = NdefRecord(NdefRecord.TNF_EXTERNAL_TYPE, type.toByteArray(), byteArrayOf(), payload.toByteArray())
        val uri = Uri.parse(payload)
        val record = NdefRecord.createUri(uri)
        val nfcMessage = NdefMessage(arrayOf(record))
        writeMessageToTag(nfcMessage, tag)
        val data = mapOf(kId to "", kContent to payload, kError to "", kStatus to "write")
        val mainHandler = Handler(Looper.getMainLooper())
        mainHandler.post {
            result.success(data)
        }
        unregister()
    }

    private fun writeMessageToTag(nfcMessage: NdefMessage, tag: Tag?): Boolean {
        val nDefTag = Ndef.get(tag)

        nDefTag?.let {
            it.connect()
            if (it.maxSize < nfcMessage.toByteArray().size) {
                //Message to large to write to NFC tag
                return false
            }
            return if (it.isWritable) {
                it.use { ndef ->
                    ndef.writeNdefMessage(nfcMessage)
                }
                //Message is written to tag
                true
            } else {
                //NFC tag is read-only
                false
            }
        }

        val nDefFormatableTag = NdefFormatable.get(tag)

        nDefFormatableTag?.let {
            it.use { ndef ->
                ndef.connect()
                ndef.format(nfcMessage)
            }
            //The data is written to the tag
            true
        }
        //NDEF is not supported
        return false
    }
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
class NfcReader(result: MethodChannel.Result, call: MethodCall) : AbstractNfcHandler(result, call) {
    override fun onTagDiscovered(tag: Tag) {
        tag.read { data ->
            result.success(data)
        }
        unregister()
    }
}

@RequiresApi(Build.VERSION_CODES.KITKAT)
class NfcScanner(private val plugin: PoddleNfcPlugin) : NfcAdapter.ReaderCallback {
    override fun onTagDiscovered(tag: Tag) {
        val sink = plugin.eventSink ?: return
        tag.read { data ->
            sink.success(data)
        }
    }
}

private fun ByteArray.bytesToHexString(): String {
    val stringBuilder = StringBuilder("0x")

    for (i in indices) {
        stringBuilder.append(Character.forDigit(get(i).toInt() ushr 4 and 0x0F, 16))
        stringBuilder.append(Character.forDigit(get(i).toInt() and 0x0F, 16))
    }

    return stringBuilder.toString()
}

private fun Tag.read(callback: (Map<*, *>) -> Unit) {
    // convert tag to NDEF tag
    val ndef = Ndef.get(this)
    if (ndef == null) {
        callback(mapOf(kId to null, kContent to null, kError to "failed to get NDEF", kStatus to "error"))
        return
    }
    ndef.connect()
    val ndefMessage = ndef.ndefMessage ?: ndef.cachedNdefMessage
    val message = ndefMessage.toByteArray()
            .toString(Charsets.US_ASCII)
    val id = id.bytesToHexString()
    ndef.close()
    val data = mapOf(kId to id, kContent to message, kError to "", kStatus to "reading")
    val mainHandler = Handler(Looper.getMainLooper())
    mainHandler.post {
        callback(data)
    }
}