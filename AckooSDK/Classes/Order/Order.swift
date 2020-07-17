//
//  Order.swift
//  AckooSDK
//
//  Created by mihir mehta on 10/06/20.
//

import Foundation


/// Order details
/// Information regarding purchased order
@objc(Order)
public class Order:NSObject,Codable {
    /// Order Id
    let id:String
    
    /// Total amount of all the order items
    var totalAmount:Double
    
    /// currency string (USD, GBP, EUR)
    var currencySymbol:String?
    
    /// Order Item
    var items:[OrderItem]
    
    /// order created date and time in UTC
    var createdOn:TimeInterval
    
    /// order last modified date and time in UTC
    var modifiedOn:TimeInterval
    
    
    /// order validated date and time in UTC
    var validatedOn:TimeInterval?
    
    
    /// Order initializer (consstructor)
    /// - Parameters:
    ///   - id: order id
    ///   - totalAmount: total amount of all the items from this order
    ///   - symbol: currency string (USD, GBP, EUR)
    ///   - items: Order Item
    ///   - createdOn: order created date and time in UTC
    ///   - modifiedOn: order last modified date and time in UTC
    ///   - validatedOn: order validated date and time in UTC
    @objc   
    public init(id:String,totalAmount:Double,symbol:String?,items:[OrderItem],createdOn:TimeInterval,modifiedOn:TimeInterval,validatedOn:TimeInterval) {
        self.id = id
        self.totalAmount = totalAmount
        self.currencySymbol = symbol
        self.items = items
        self.createdOn = createdOn
        self.modifiedOn = modifiedOn
        self.validatedOn = validatedOn
    }
  
  static func requiresMainQueueSetup() -> Bool {
      return false
  }
}
