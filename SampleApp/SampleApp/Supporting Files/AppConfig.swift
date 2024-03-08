//
//  AppConfig.swift
//  SSMPOSSDKTestApp
//
//  Created by CK on 25/05/2023.
//

import Foundation

struct AppConfig
{
    static let ACCESS_KEY = Utils.infoForKey("ACCESS_KEY")
    static let SECRET_KEY = Utils.infoForKey("SECRET_KEY")
    static let ATTESTATION_CERT_PINNING = Utils.infoForKey("ATTESTATION_CERT_PINNING")
    static let ATTESTATION_HOST = Utils.infoForKey("ATTESTATION_HOST")
    static let ATTESTATION_REFRESH_INTERVAL = UInt(Utils.infoForKey("ATTESTATION_REFRESH_INTERVAL")!) 
    static let KEYLOADING_HOST = Utils.infoForKey("KEYLOADING_HOST")
    static let KEYLOADING_HOST_CERT_PINNING = Utils.infoForKey("KEYLOADING_HOST_CERT_PINNING")
    static let KEYLOADING_CA_CERT = Utils.infoForKey("KEYLOADING_CA_CERT")
}
