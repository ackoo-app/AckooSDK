//
//  Payload.swift
//  AckooSDK
//
//  Created by mihir mehta on 19/06/20.
//

import Foundation

/// User activity that holds information regarding user's actions
class Payload:Encodable {
    
    let name:AckooEventType
    
    let properties:UserActivity
    

    init(type:AckooEventType,activity:UserActivity) {
        self.name = type
        self.properties = activity
        
    }
   
}
