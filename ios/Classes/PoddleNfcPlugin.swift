import Flutter
import UIKit
import CoreNFC

public class PoddleNfcPlugin: NSObject, FlutterPlugin, NFCNDEFReaderSessionDelegate {
    var flutterResult: FlutterResult?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "poddle_nfc", binaryMessenger: registrar.messenger())
    let instance = PoddleNfcPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      flutterResult = result
          ScantnAction()
//    result("iOS " + UIDevice.current.systemVersion)
  }
    
    
       private func receiveBatteryLevel(result: FlutterResult) {
           ScantnAction()
   //        let device = UIDevice.current
   //        device.isBatteryMonitoringEnabled = true
   //        if device.batteryState == UIDevice.BatteryState.unknown {
   //            result(FlutterError(code: "UNAVAILABLE",
   //                                message: "Battery level not available.",
   //                                details: nil))
   //        } else {
   //            result(Int(device.batteryLevel * 100))
   //        }
       }
       
       
       
       var nfcSession: NFCNDEFReaderSession?
      public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
           print ("The session was invlidated: \(error.localizedDescription)")
       }
       
       func ScantnAction() {
           nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
           // Set an alert message to guide the user
           nfcSession?.alertMessage = "Hold your iPhone near a writable NFC tag to update."
           nfcSession?.begin()
       }
       
       
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
           var result = ""
           for payload in messages[0].records{
               result += String.init (data: payload.payload, encoding: .ascii) ?? "Format not supported"
           }
           DispatchQueue.main.async {
               print("\(result)")
               
               (self.flutterResult!)("\(result)".trimmingCharacters(in: .whitespacesAndNewlines))
               
               
           }
       }
}

