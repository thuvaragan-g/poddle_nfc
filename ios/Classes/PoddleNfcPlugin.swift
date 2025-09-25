import Flutter
import UIKit
import CoreNFC

public class PoddleNfcPlugin: NSObject, FlutterPlugin, NFCNDEFReaderSessionDelegate {
    var flutterResult: FlutterResult?
    var nfcSession: NFCNDEFReaderSession?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "poddle_nfc", binaryMessenger: registrar.messenger())
        let instance = PoddleNfcPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        flutterResult = result
        ScantnAction()
    }
    
    private func receiveBatteryLevel(result: FlutterResult) {
        ScantnAction()
    }
    
    // MARK: - NFC Session Management
    
    func ScantnAction() {
        // Check if NFC is available
        guard NFCNDEFReaderSession.readingAvailable else {
            DispatchQueue.main.async {
                self.flutterResult?(FlutterError(
                    code: "NFC_NOT_AVAILABLE",
                    message: "NFC is not available on this device",
                    details: nil
                ))
            }
            return
        }
        
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Ask a staff member to tap their poddle Smartcard here."
        nfcSession?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("The session was invalidated: \(error.localizedDescription)")
        
        // Check if it's an NFC error
        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                // User tapped "Cancel" or dismissed the popup
                print("User canceled NFC scanning")
                DispatchQueue.main.async {
                    self.flutterResult?(FlutterError(
                        code: "USER_CANCELED",
                        message: "User canceled NFC scanning",
                        details: nil
                    ))
                }
                
            case .readerSessionInvalidationErrorSessionTimeout:
                print("NFC session timed out")
                DispatchQueue.main.async {
                    self.flutterResult?(FlutterError(
                        code: "TIMEOUT",
                        message: "NFC session timed out",
                        details: nil
                    ))
                }
                
            case .readerSessionInvalidationErrorSystemIsBusy:
                print("System is busy with another NFC operation")
                DispatchQueue.main.async {
                    self.flutterResult?(FlutterError(
                        code: "SYSTEM_BUSY",
                        message: "NFC system is busy",
                        details: nil
                    ))
                }
                
            case .readerSessionInvalidationErrorSessionTerminatedUnexpectedly:
                print("Session terminated unexpectedly")
                DispatchQueue.main.async {
                    self.flutterResult?(FlutterError(
                        code: "SESSION_TERMINATED",
                        message: "NFC session terminated unexpectedly",
                        details: nil
                    ))
                }
                
            case .readerSessionInvalidationErrorFirstNDEFTagRead:
                // This happens when invalidateAfterFirstRead is true and a tag was read
                print("Session invalidated after first read")
                // Don't send an error for this case as it's expected behavior
                
            default:
                print("Other NFC error: \(nfcError.localizedDescription)")
                DispatchQueue.main.async {
                    self.flutterResult?(FlutterError(
                        code: "NFC_ERROR",
                        message: nfcError.localizedDescription,
                        details: ["errorCode": nfcError.code.rawValue]
                    ))
                }
            }
        } else {
            // Handle other types of errors
            print("Unknown error type: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.flutterResult?(FlutterError(
                    code: "UNKNOWN_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
        }
        
        // Clean up
        nfcSession = nil
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = ""
        
        // Process all messages and records
        for message in messages {
            for payload in message.records {
                if let payloadString = String(data: payload.payload, encoding: .utf8) {
                    result += payloadString
                } else if let payloadString = String(data: payload.payload, encoding: .ascii) {
                    result += payloadString
                } else {
                    result += "Format not supported"
                }
            }
        }
        
        DispatchQueue.main.async {
            print("NFC Data: \(result)")
            let trimmedResult = result.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedResult.isEmpty {
                self.flutterResult?(FlutterError(
                    code: "EMPTY_DATA",
                    message: "NFC tag contains no readable data",
                    details: nil
                ))
            } else {
                self.flutterResult?(trimmedResult)
            }
        }
        
        // Session will be invalidated automatically due to invalidateAfterFirstRead: true
    }
    
    // Optional: Handle session becoming active
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("NFC session became active")
    }
}