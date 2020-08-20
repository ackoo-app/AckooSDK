//
//  ViewController.swift
//  AckooSDK
//
//  Created by mihirpmehta on 06/06/2020.
//  Copyright (c) 2020 mihirpmehta. All rights reserved.
//

import AckooSDK
import Foundation
import UIKit

class ViewController: UIViewController {
    @IBOutlet var isSdkActiveLabel: UILabel!
    @IBOutlet var sdkSessionTokenLabel: UILabel!

    @IBOutlet var userIdInput: UITextField!
    @IBOutlet var userEmailInput: UITextField!

    @IBOutlet var amountInput: UITextField!
    @IBOutlet var currencyInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func recheckIsSdkActive(_: Any) {
        isSdkActiveLabel.text = String(AckooSDKManager.shared().isUserValidForSDK())
        sdkSessionTokenLabel.text = String(getToken())
    }

    @IBAction func purchase(_: Any) {
        if amountInput.text == nil || amountInput.text!.isEmpty {
            return showAlert(title: "validationError", message: "amount is empty")
        }

        if currencyInput.text == nil || currencyInput.text!.isEmpty {
            return showAlert(title: "validationError", message: "currency is empty")
        }
        let amount = Double(amountInput.text!)
        let order = Order(id: "asd", totalAmount: amount!, symbol: currencyInput.text!, items: [])
        AckooSDKManager.shared().reportPurchase(order: order) { succeeded, response in
            var message = ""
            if succeeded {
                print(response)
            } else {
                if let errorMessage = (response as! [String: Any])["error"] as! String? {
                    message = errorMessage
                } else {
                    message = "unknown error"
                }
            }
            self.showAlert(title: "Purchase track: \(succeeded)", message: message)
        }
    }

    @IBAction func login(_: Any) {
        // self.sendReportActivity(.login);
        if userIdInput.text == nil || userIdInput.text!.isEmpty {
            return showAlert(title: "validationError", message: "userId is empty")
        }

        if userEmailInput.text == nil || userEmailInput.text!.isEmpty {
            return showAlert(title: "validationError", message: "user email is empty")
        }
        AckooSDKManager.shared().identify(id: userIdInput.text!, user: ["email": userEmailInput.text!]) { succeeded, response in
            var message = ""
            if succeeded {
                print(response)
            } else {
                if let errorMessage = (response as! [String: Any])["error"] as! String? {
                    message = errorMessage
                } else {
                    message = "unknown error"
                }
            }

            self.showAlert(title: "Login track: \(succeeded)", message: message)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getToken() -> String {
        if let token: String = UserDefaults.standard.object(forKey: "AckooSDKSessionToken") as? String {
            return token
        }
        return "empty"
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            print("Alert dismissed")
        }))
        present(alert, animated: true)
    }
}
