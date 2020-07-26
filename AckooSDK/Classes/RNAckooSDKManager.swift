//
//  RNAckooSDKManager.swift
//  AckooSDK
//
//  Created by Mihir.Mehta on 20/07/20.
//

import Foundation
import UIKit
typealias RNResponseSenderBlock = ([AnyHashable]?) -> Void

@objc(RNAckooSDKManager)
class RNAckooSDKManager:NSObject {
    @objc public override init() {
        super.init()
    }
    @objc
    func reportActivity(_ values:NSDictionary,RNCallBack:@escaping RNResponseSenderBlock)  {
        //let date:TimeInterval = Date().timeIntervalSince1970
        //Check if valid type in dictionary
      guard let type:Int = values["type"] as? Int, let typeEnum:AckooEventType = AckooEventType(rawValue: type) else {
            RNCallBack(["Not valid type of Event",NSNull()])
            return
        }
        var email:String? = nil
        var isLoggedIn:Bool? = nil
        if let emailStr:String = values["email"] as? String {
            email = emailStr
        }
        if let isLoggedInBool:Bool = values["isLoggedIn"] as? Bool {
            isLoggedIn = isLoggedInBool
        }
        let activity:UserActivity = UserActivity(isLoggedIn: isLoggedIn, email: email)
        AckooSDKManager.shared().reportActivity(type: typeEnum, activity: activity) { (succeeded, response) in
            if (succeeded) {
                if let responseAny:AnyHashable = response as? AnyHashable {
                  print("Swift response is \(response)")
                    RNCallBack([NSNull(),responseAny])
                }
                
            } else {
                if let responseAny:AnyHashable = response as? AnyHashable {
                    RNCallBack([responseAny,NSNull()])
                }
            }
        }
        
        
    }
    @objc
    func reportPurchase(_ values:NSDictionary,RNCallBack:@escaping RNResponseSenderBlock)  {
        
        guard let orderItemsArr:[[AnyHashable:Any]] = values["orderItems"] as? [[AnyHashable:Any]],orderItemsArr.count > 0 else {
            RNCallBack(["Argument does not have order items",NSNull()])
            return
        }
        var orderItems:[OrderItem] = []
        for orderItem in orderItemsArr {
            guard let name:String = orderItem["productName"] as? String else {
                RNCallBack(["Product Name doesn't exist",NSNull()])
                return
            }
            guard let amount:Double = orderItem["amount"] as? Double else {
                RNCallBack(["Product amount doesn't exist",NSNull()])
                return
            }
            let sku:String? = orderItem["sku"] as? String
            let orderItem:OrderItem = OrderItem(sku: sku, name: name, amount: amount)
            orderItems.append(orderItem)
        }
        guard let orderId:String = values["orderId"] as? String else {
            RNCallBack(["Order Informaton doesn't contains valid Id",NSNull()])
            return
        }
        
        
        guard let totalAmount:Double = values["totalAmount"] as? Double else {
            RNCallBack(["Product total amount doesn't exist",NSNull()])
            return
        }
        let symbol:String? = values["symbol"] as? String
        let createdOn:Double? = values["createdOn"] as? Double
        let modifiedOn:Double? = values["modifiedOn"] as? Double
        let validatedOn:Double? = values["validatedOn"] as? Double
        
        let order:Order = Order(id: orderId, totalAmount: totalAmount, symbol: symbol, items: orderItems, createdOn: createdOn, modifiedOn: modifiedOn, validatedOn: validatedOn)
        
        
        var email:String? = nil
        var isLoggedIn:Bool? = nil
        if let emailStr:String = values["email"] as? String {
            email = emailStr
        }
        if let isLoggedInBool:Bool = values["isLoggedIn"] as? Bool {
            isLoggedIn = isLoggedInBool
        }
        let activity:UserActivity = UserActivity(isLoggedIn: isLoggedIn, email: email)
        
        AckooSDKManager.shared().reportPurchase(type: .purchase, activity: activity, order: order) { (succeeded, response) in
            if (succeeded) {
                if let responseAny:AnyHashable = response as? AnyHashable {
                    RNCallBack([NSNull(),responseAny])
                }
                
            } else {
                if let responseAny:AnyHashable = response as? AnyHashable {
                    RNCallBack([responseAny,NSNull()])
                }
            }
        }
    }
    @objc
    func isTheUSerValidForAckooSDK(_ RNCallBack:@escaping RNResponseSenderBlock)  {
        AckooSDKManager.shared().isUserValidForSDK { (isValid) in
          print("Is valid is = \(isValid)")
            RNCallBack([NSNull(),isValid])
        }
    }
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
