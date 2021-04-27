//
//  Package.swift
//  AckooSDK
//
//  Created by mihir mehta on 13/06/20.
//

import PackageDescription

let package = Package(name: "AckooSDK",
                      platforms: [.iOS(.v11)],
                      products: [.library(name: "AckooSDK",
                                          targets: ["AckooSDK"])],
                      swiftLanguageVersions: [.v5])
