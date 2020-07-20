//
//  RNAckooSDKManager.swift
//  AckooSDK
//
//  Created by Mihir.Mehta on 20/07/20.
//

import Foundation

typealias RNResponseSenderBlock = ([AnyHashable]?) -> Void

@objc
class RNAckooSDKManager:NSObject {
    @objc public override init() {
        super.init()
    }
    @objc
    func reportActivity(_ value:NSDictionary,RNCallBack:@escaping RNResponseSenderBlock)  {
        //let date:TimeInterval = Date().timeIntervalSince1970
        //Check if valid type in dictionary
        guard let type:Int = value["type"] as? Int, let typeEnum:AckooEventType = AckooEventType(rawValue: type) else {
            RNCallBack(["Not valid type of Event",NSNull()])
            return
        }
        var email:String? = nil
        var isLoggedIn:Bool? = nil
        if let emailStr:String = value["email"] as? String {
            email = emailStr
        }
        if let isLoggedInBool:Bool = value["isLoggedIn"] as? Bool {
            isLoggedIn = isLoggedInBool
        }
        let activity:UserActivity = UserActivity(isLoggedIn: isLoggedIn, email: email)
        AckooSDKManager.shared().reportActivity(type: typeEnum, activity: activity) { (succeeded, response) in
            if (succeeded) {
                if let reaponseAny:AnyHashable = response as? AnyHashable {
                    RNCallBack([NSNull(),reaponseAny])
                }
                
            } else {
                if let reaponseAny:AnyHashable = response as? AnyHashable {
                    RNCallBack([reaponseAny,NSNull()])
                }
            }
        }
        
        
    }
    @objc
    func reportPurchase(_ value:NSDictionary,RNCallBack:@escaping RNResponseSenderBlock)  {
        //let date:TimeInterval = Date().timeIntervalSince1970
        //         if (name == .purchase) {
        //             let item:OrderItem = OrderItem.init(sku: "CM01-R", name: appDelegate.productName ?? "Default Product", amount: 13.35)
        //              let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
        //             AckooSDKManager.shared().reportPurchase(type: name, activity: activity, order: order) { (succeeded, response) in
        //                 print(succeeded)
        //             }
        //         }
        //Check if valid type in dictionary
        guard let orderItemsArr:[[AnyHashable:Any]] = value["orderItems"] as? [[AnyHashable:Any]],orderItemsArr.count > 0 else {
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
        guard let orderId:String = value["orderId"] as? String else {
           RNCallBack(["Order Informaton doesn't contains valid Id",NSNull()])
           return
        }
        // let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
        
        guard let totalAmount:Double = value["totalAmount"] as? Double else {
            RNCallBack(["Product total amount doesn't exist",NSNull()])
            return
        }
        let symbol:String? = value["symbol"] as? String
        let createdOn:Double? = value["createdOn"] as? Double
        let modifiedOn:Double? = value["modifiedOn"] as? Double
        let validatedOn:Double? = value["validatedOn"] as? Double
        
        let order:Order = Order(id: orderId, totalAmount: totalAmount, symbol: symbol, items: orderItems, createdOn: createdOn, modifiedOn: modifiedOn, validatedOn: validatedOn)
        
        
        var email:String? = nil
        var isLoggedIn:Bool? = nil
        if let emailStr:String = value["email"] as? String {
            email = emailStr
        }
        if let isLoggedInBool:Bool = value["isLoggedIn"] as? Bool {
            isLoggedIn = isLoggedInBool
        }
        let activity:UserActivity = UserActivity(isLoggedIn: isLoggedIn, email: email)
        
        AckooSDKManager.shared().reportPurchase(type: .purchase, activity: activity, order: order) { (succeeded, response) in
            if (succeeded) {
                if let reaponseAny:AnyHashable = response as? AnyHashable {
                    RNCallBack([NSNull(),reaponseAny])
                }
                
            } else {
                if let reaponseAny:AnyHashable = response as? AnyHashable {
                    RNCallBack([reaponseAny,NSNull()])
                }
            }
        }
        
        //         if (name == .purchase) {
        //             let item:OrderItem = OrderItem.init(sku: "CM01-R", name: appDelegate.productName ?? "Default Product", amount: 13.35)
        //              let order:Order = Order(id: "135497-25943", totalAmount: 13.35, symbol: "USD", items: [item], createdOn:date , modifiedOn: date, validatedOn: date)
        //             AckooSDKManager.shared().reportPurchase(type: name, activity: activity, order: order) { (succeeded, response) in
        //                 print(succeeded)
        //             }
        //         }
    }
    
}
