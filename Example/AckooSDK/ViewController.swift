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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func open(_ sender: Any) {
        self.sendReportActivity(.openApp)
    }
    @IBAction func purchase(_ sender: Any) {
         self.sendReportActivity(.purchase)
    }
    
    @IBAction func login(_ sender: Any) {
         self.sendReportActivity(.login)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func install(_ sender: Any) {
         self.sendReportActivity(.installApp)
    }
    
    @IBAction func signup(_ sender: Any) {
       // self.sendReportActivity(.register)
        
    }
    
    func sendReportActivity(_ name: AckooEventType) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let date:TimeInterval = Date().timeIntervalSince1970
       
        let activity:UserActivity = UserActivity.init(isLoggedIn: true, email: "user@gmail.com")
        if (name == .purchase) {
            let item:OrderItem = OrderItem.init(sku: "CM01-R", name: appDelegate.productName ?? "Default Product", amount: 13.35)
             let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
            AckooSDKManager.shared().reportPurchase(type: name, activity: activity, order: order) { (succeeded, response) in
                print(succeeded)
            }
        } else {
            AckooSDKManager.shared().reportActivity(type: name, activity: activity) { (succeeded, response) in
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

