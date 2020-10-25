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
        AckooSDKManager.shared().getSessionToken { isActive, sessionToken, error in

            if isActive {
                self.showAlert(title: "Ackoo SDK is Active", message: "sessionToken : \(sessionToken)")
            } else {
                print(error)
                self.showAlert(title: "Ackoo SDK is Inactive", message: "code")
            }
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
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                print("Alert dismissed")
            }))
            self.present(alert, animated: true)
        }
    }
}
