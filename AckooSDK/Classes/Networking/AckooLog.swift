//
//  AckooLog.swift
//  AckooSDK
//
//  Created by Sally Ahmed1 on 12/15/20.
//

import Foundation
public func print(_ object: Any ,logLevel: AckooLogLevel){
    switch logLevel {
    case .critical:
        Swift.print("[AckooSDK]: " ,object)
    case .debug:
        Swift.print("[AckooSDK]: " ,object)
    case.none:
        break
    }
}
