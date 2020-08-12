//
//  ViewController.swift
//  AckooSDK
//
//  Created by mihirpmehta on 06/06/2020.
//  Copyright (c) 2020 mihirpmehta. All rights reserved.
//

import UIKit
import AckooSDK

class ViewController: UIViewController {
    
    @IBOutlet weak var isSdkActiveLabel: UILabel!
    @IBOutlet weak var sdkSessionTokenLabel: UILabel!
    
    @IBOutlet weak var userIdInput: UITextField!
    @IBOutlet weak var userEmailInput: UITextField!
    
    @IBOutlet weak var amountInput: UITextField!
    @IBOutlet weak var currencyInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func recheckIsSdkActive(_ sender: Any) {
        isSdkActiveLabel.text = String(AckooSDKManager.shared().isUserValidForSDK());
        sdkSessionTokenLabel.text = String(self.getToken());
    }
    @IBAction func purchase(_ sender: Any) {
         if (amountInput.text == nil || amountInput.text!.isEmpty) {
             return showAlert(title: "validationError", message: "amount is empty")
         }
         
         if (currencyInput.text == nil || currencyInput.text!.isEmpty) {
             return showAlert(title: "validationError", message: "currency is empty")
         }
        let amount = Double(amountInput.text!);
        let order = Order(id: "asd", totalAmount: amount! ,symbol: currencyInput.text!, items: []);
        AckooSDKManager.shared().reportPurchase(order: order) { (succeeded, response) in
            self.showAlert(title: "Purchase track: \(succeeded)", message: "check logs for errors");
        };
    }
    
    @IBAction func login(_ sender: Any) {
        //self.sendReportActivity(.login);
        if (userIdInput.text == nil || userIdInput.text!.isEmpty) {
            return showAlert(title: "validationError", message: "userId is empty")
        }
        
        if (userEmailInput.text == nil || userEmailInput.text!.isEmpty) {
            return showAlert(title: "validationError", message: "user email is empty")
        }
        
//      print("userId: \(userIdInput.text!),     userEmail: \(userEmailInput.text!)");
        AckooSDKManager.shared().identify(id: userIdInput.text!, user: ["email": userEmailInput.text!]) { (succeeded, response) in
            self.showAlert(title: "Login track: \(succeeded)", message: "check logs for errors");
        };
        
//        self.showAlert(title: userIdInput.text , message: userEmailInput);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getToken() -> String {
        if let token:String = UserDefaults.standard.object(forKey: "AckooSDKSessionToken") as? String {
            return token
        }
        return "empty";
    }
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            print("Alert dismissed");
        }))
        self.present(alert, animated: true)
    }
    func sendReportActivity(_ name: AckooEventType) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let date:TimeInterval = Date().timeIntervalSince1970
       
        let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com")
        if (name == .purchase) {
            let item:OrderItem = OrderItem.init(sku: "CM01-R", name: appDelegate.productName ?? "Default Product", amount: 13.35)
             let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item])
            AckooSDKManager.shared().reportPurchase( order: order) { (succeeded, response) in
                print(succeeded)
            }
        } else {
            AckooSDKManager.shared().reportActivity(type: name) { (succeeded, response) in
                print(succeeded)
            }
        }
//        AckooSDKManager.shared().isUserValidForSDK { (isValid) in
//            if (isValid) {
//                //report the activity or purchase
//            }
//        }
        
    }
}

