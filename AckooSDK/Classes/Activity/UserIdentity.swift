//
//  UserIdentity.swift
//  AckooSDK
//
//  Created by mihir mehta on 11/06/20.
//

import Foundation
import AdSupport
import CoreTelephony
import UIKit


class UserIdentity:Encodable {
    var advertisingId:String?
    var fingerprint:FingerPrintingOption?
    let batteryLevel:Float
    let isFirstOpen:Bool
    private var fingerPrintingParam:FingerPrintingOption = FingerPrintingOption()
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.advertisingId = UserIdentity.getIDFAOfDevice()
        if UIDevice.current.isBatteryMonitoringEnabled {
            self.batteryLevel =  UIDevice.current.batteryLevel
        } else {
            self.batteryLevel = 0.0
        }
        if let firstOpen:Bool = UserDefaults.standard.object(forKey: "AckooisFirstOpen") as? Bool {
            self.isFirstOpen = firstOpen
        } else {
            self.isFirstOpen = true
            UserDefaults.standard.set(false, forKey: "AckooisFirstOpen")
        }
        self.fingerprint = self.getDevicInfo()
    }
    class private func getIDFAOfDevice() -> String {
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    private func getDevicInfo() -> FingerPrintingOption {
        return self.fingerPrintingParam
    }
}

class FingerPrintingOption:Encodable {
    let locale:DeviceLocale = DeviceLocale()
    let hardware:DeviceHardware = DeviceHardware()
    let network:DeviceNetwork = DeviceNetwork()
    
}


class DeviceLocale:Encodable {
    let languageCode = Locale.current.languageCode
    let regionCode = Locale.current.regionCode ?? "none"
    
    let calenderIdentifier:String = "\(Locale.current.calendar.identifier)"
    let timezone = TimeZone.current.identifier
    let keyboards:[String]
    
    init() {
        if let keyboardString = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] {
            self.keyboards = keyboardString
        } else {
            keyboards = []
        }
    }
}

class DeviceHardware:Encodable {
    let model:String = UIDevice.current.modelName
    let storageCapacity:Int
    let deviceName = UIDevice.current.name
    
    init() {
        
        let fileManager = FileManager.default
        if let path = fileManager.urls(for: .libraryDirectory, in: .systemDomainMask).last?.path,
            let systemSize = try? fileManager.attributesOfFileSystem(forPath: path)[.systemSize] as? Int
        {
            self.storageCapacity = systemSize
        } else {
            self.storageCapacity = 0
        }
        
    }
}

class DeviceNetwork:Encodable {
    let mobileNetworkCode:String
    let mobileCountryCode:String
    init() {
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
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}


