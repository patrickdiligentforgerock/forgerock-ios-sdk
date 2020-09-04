//
//  CookieHelper.swift
//  FRAuth
//
//  Created by patrick on 3/9/20.
//

import Foundation

class MultiSessionCookies {
    
    static var delegate: FRAuthDelegate?
    
    static func prefixedCookieName(_ cookieName: String) -> String {
        var value = "default_cookieName"
        if let prefix = delegate?.keyForSession?() {
            value = "\(prefix)_\(cookieName)"
        }
        FRLog.i("[Cookies] Prefixed Cookie Name: \(value)")
        return value
    }

    static func filterWithPrefix(_ name: String) -> Bool {
        let prefix = delegate?.keyForSession?() ?? "default"
        FRLog.i("[Cookies] filtering - Cookie Name: \(name) - matches: \(name.hasPrefix(prefix + "_"))")
        return name.hasPrefix(prefix + "_")
    }
    
    static func deleteAllRelatedCookies() -> Void {
        if let frAuth = FRAuth.shared, frAuth.serverConfig.enableCookie, let cookieItems = frAuth.keychainManager.cookieStore.allItems() {
            for cookieObj in cookieItems {
                if let cookieData = cookieObj.value as? Data, let cookie = NSKeyedUnarchiver.unarchiveObject(with: cookieData) as? HTTPCookie, MultiSessionCookies.filterWithPrefix(cookieObj.key) {
                    frAuth.keychainManager.cookieStore.delete(cookie.name + "-" + cookie.domain)
                    FRLog.v("[Cookies] Delete - Cookie Name: \(cookie.name)")
                }
            }
        }
    }
}
