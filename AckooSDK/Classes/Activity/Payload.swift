//
//  Payload.swift
//  AckooSDK
//
//  Created by mihir mehta on 19/06/20.
//

import Foundation

/// User activity that holds information regarding user's actions

class Payload:Encodable {
    let name:AckooEventTypeString
    let properties:PayloadProperty
    
    init(type:AckooEventTypeString,payload:PayloadProperty) {
        self.name = type
        self.properties = payload
        
    }
}
class PayloadProperty:Encodable {
    /// Order details
    var orderDetail:Order?
    /// userActivity
    var userActivity:UserActivity
    
    init(order:Order?,activity:UserActivity) {
        self.orderDetail = order
        self.userActivity = activity
    }
}
