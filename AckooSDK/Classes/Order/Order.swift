//
//  Order.swift
//  AckooSDK
//
//  Created by mihir mehta on 10/06/20.
//

import Foundation

/// Order details
/// Information regarding purchased order

public class Order: NSObject, Codable {
    /// Order Id
    let id: String

    /// Total amount of all the order items
    var amount: Double

    /// currency string (USD, GBP, EUR)
    var currency: String

    /// Order Item
    var items: [OrderItem]

    /// Order initializer (consstructor)
    /// - Parameters:
    ///   - id: order id
    ///   - amount: total amount of all the items from this order
    ///   - symbol: currency string (USD, GBP, EUR)
    ///   - items: Order Item
    ///   - createdOn: order created date and time in UTC
    ///   - modifiedOn: order last modified date and time in UTC
    ///   - validatedOn: order validated date and time in UTC
    @objc
    public init(id: String, amount: Double, currency: String, items: [OrderItem]) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.items = items
    }

    public func toDict() -> [String: String] {
        return [
            "orderId": self.id,
            "amount": "\(self.amount)",
            "currency": self.currency
        ]
    }
  static func requiresMainQueueSetup() -> Bool {
      return false
  }
}
