//
//  OrderItem.swift
//  AckooSDK
//
//  Created by mihir mehta on 10/06/20.
//

import Foundation


/// Order item with details like sku, name amount

public class OrderItem:NSObject,Codable {
    
    
    /// sku of the product
    let sku:String?
    
    /// product name
    let name:String
    
    /// total amount
    let amount:Double
    
    
    /// OrderItem initializer (constructor)
    /// - Parameters:
    ///   - sku: sku of the product
    ///   - name: product name
    ///   - amount: total amount
    @objc
    public init(sku:String?,name:String,amount:Double) {
        self.sku = sku
        self.name = name
        self.amount = amount
    }
  
  static func requiresMainQueueSetup() -> Bool {
      return false
  }
}

