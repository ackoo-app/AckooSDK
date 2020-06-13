//
//  UserIdentity.swift
//  AckooSDK
//
//  Created by mihir mehta on 11/06/20.
//

import Foundation

class UserIdentity:Encodable {
    var idfaUuidString:String?
    var fingerPrintingParam:FingerPrintingOption?
    
    init(idfaUuidString:String) {
        self.idfaUuidString = idfaUuidString
    }
}

class FingerPrintingOption:Encodable {
    let languageCode = Locale.current.languageCode
    let regionCode = Locale.current.regionCode
    let calendor = Locale.current.calendar.identifier.hashValue
    let timezone = TimeZone.current.identifier
    let keyboard:String
    
    init () {
        if let keyboardString = UserDefaults.standard.object(forKey: "AppleKeyboards") as? String {
            self.keyboard = keyboardString
        } else {
            keyboard = ""
        }
    }
}

