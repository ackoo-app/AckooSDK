//
//  UserIdentity.swift
//  AckooSDK
//
//  Created by mihir mehta on 11/06/20.
//

import Foundation
import CoreTelephony

class UserIdentity:Encodable {
    var advertisingId:String?
    var fingerprint:FingerPrintingOption?
    
    init(idfaUuidString:String) {
        self.advertisingId = idfaUuidString
    }
}

class FingerPrintingOption:Encodable {
    let languageCode = Locale.current.languageCode
    let regionCode = Locale.current.regionCode
    let calendor = Locale.current.calendar.identifier.hashValue
    let timezone = TimeZone.current.identifier
    let keyboard:String
    let deviceName = UIDevice.current.name
    let systemSize:Int
    let mobileNetworkCode:String
    let mobileCountryCode:String
    var batteryLevel:Float
    
    init () {
        if let keyboardString = UserDefaults.standard.object(forKey: "AppleKeyboards") as? String {
            self.keyboard = keyboardString
        } else {
            keyboard = ""
        }
        
        let fileManager = FileManager.default
        if let path = fileManager.urls(for: .libraryDirectory, in: .systemDomainMask).last?.path,
            let systemSize = try? fileManager.attributesOfFileSystem(forPath: path)[.systemSize] as? Int
        {
            self.systemSize = systemSize
        } else {
            self.systemSize = 0
        }
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        if let tempCode:String = carrier?.mobileNetworkCode {
            self.mobileNetworkCode = tempCode
        } else {
            self.mobileNetworkCode = "none"
        }
        if let tempCode:String = carrier?.mobileCountryCode {
            self.mobileCountryCode = tempCode
        } else {
            self.mobileCountryCode = "none"
        }
        if UIDevice.current.isBatteryMonitoringEnabled {
            self.batteryLevel =  UIDevice.current.batteryLevel
        } else {
            self.batteryLevel = 0.0
        }
    }
}

