//
//  Utils.swift
//  SSMPOSSDKTestApp
//
//  Created by CK on 25/05/2023.
//

import Foundation

struct Utils {
    static func infoForKey(_ key: String) -> String? {
        (Bundle.main.infoDictionary?[key] as? String)?
            .replacingOccurrences(of: "\\", with: "")
    }
}
