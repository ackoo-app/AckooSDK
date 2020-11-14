//
//  Payload.swift
//  AckooSDK
//
//  Created by mihir mehta on 19/06/20.
//

import Foundation

/// User activity that holds information regarding user's actions

public protocol AckooType: Encodable {
    func isValidNestedType() -> Bool
}

extension String: AckooType {
    public func isValidNestedType() -> Bool { return true }
}

extension NSNumber: AckooType {
    public func isValidNestedType() -> Bool { return true }
    public func encode(to encoder: Encoder) throws {

    }

}

//private extension Encodable extends  {
//    func encode(to container: inout SingleValueEncodingContainer) throws {
//        try container.encode(self)
//    }
//}
//
//extension JSONEncoder {
//    private struct EncodableWrapper: Encodable {
//        let wrapped: Encodable
//
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.singleValueContainer()
//            try self.wrapped.encode(to: &container)
//        }
//    }
//
//    func encode<Key: Encodable>(_ dictionary: [Key: Encodable]) throws -> Data {
//        let wrappedDict = dictionary.mapValues(EncodableWrapper.init(wrapped:))
//        return try self.encode(wrappedDict)
//    }
//}
//

typealias Props = [String: AckooType]

struct Payload: Encodable {
    let name: String
    let props: [String: String]
}

class PayloadProperty: Encodable {
    /// Order details
    var orderDetail: Order?
    /// userActivity
    var userActivity: UserActivity

    init(order: Order?, activity: UserActivity) {
        self.orderDetail = order
        self.userActivity = activity
    }
}
