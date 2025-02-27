import Flutter
import UIKit
import ContactsUI


public class SwiftFlutterNativeContactPickerPlugin: NSObject, FlutterPlugin , CNContactPickerDelegate{

var _result: FlutterResult?;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_native_contact_picker", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterNativeContactPickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if("selectContact" == call.method) {
        if(_result != nil) {
              _result?(FlutterError(code: "multiple_requests", message: "Cancelled by a second request.", details: nil));
              _result = nil;
          }
          _result = result;

          if #available(iOS 9.0, *){
              let contactPicker = CNContactPickerViewController()
              contactPicker.delegate = self
              contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
              
              // find proper keyWindow
              var keyWindow: UIWindow? = nil
              if #available(iOS 13, *) {
                  keyWindow = UIApplication.shared.connectedScenes.filter {
                      $0.activationState == .foregroundActive
                  }.compactMap { $0 as? UIWindowScene
                  }.first?.windows.filter({ $0.isKeyWindow}).first
              } else {
                  keyWindow = UIApplication.shared.keyWindow
              }
              
              let viewController = keyWindow?.rootViewController
              viewController?.present(contactPicker, animated: true, completion: nil)
          }
      }
       else
          {
              result(FlutterMethodNotImplemented)
          }
    }

      @available(iOS 9.0, *)
      public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {

          var data = Dictionary<String, Any>()
          data["fullName"] = CNContactFormatter.string(from: contact, style: CNContactFormatterStyle.fullName)

          let numbers: Array<String> = contact.phoneNumbers.compactMap { $0.value.stringValue as String }
          data["phoneNumbers"] = numbers

          _result?(data)
          _result = nil
      }

      @available(iOS 9.0, *)
      public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
          _result?(nil)
          _result = nil
      }
}
