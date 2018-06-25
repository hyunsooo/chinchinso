//
//  GlobalState.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 3..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import Foundation

final class GlobalState {
    static let instance = GlobalState()
    
    enum Constants: String {
        case uidKey
        case firebaseIdKey
        case nameKey
        case emailKey
        case passwordKey
        case openDateKey
        case hashCountKey
    }
    
    /* Server API 호출에 필요한 로그인된 uid 값 */
    var uid: Int? {
        get {
            let id = UserDefaults.standard.integer(forKey: Constants.uidKey.rawValue)
            return id
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.uidKey.rawValue)
        }
    }
    
    var name: String? {
        get {
            let name = UserDefaults.standard.string(forKey: Constants.nameKey.rawValue)
            return name
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.nameKey.rawValue)
        }
    }
    
    var email: String? {
        get {
            let email = UserDefaults.standard.string(forKey: Constants.emailKey.rawValue)
            return email
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.emailKey.rawValue)
        }
    }
    
    var password: String? {
        get {
            let password = UserDefaults.standard.string(forKey: Constants.passwordKey.rawValue)
            return password
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.passwordKey.rawValue)
        }
    }
    
    var openDate: Bool? {
        get {
            let openDate = UserDefaults.standard.bool(forKey: Constants.openDateKey.rawValue)
            return openDate
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.openDateKey.rawValue)
        }
    }
    
    var hashCount: Int? {
        get {
            let count = UserDefaults.standard.integer(forKey: Constants.hashCountKey.rawValue)
            return count
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.hashCountKey.rawValue)
        }
    }
    
    var firebaseId: String? {
        get {
            let uid = UserDefaults.standard.string(forKey: Constants.firebaseIdKey.rawValue)
            return uid
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.firebaseIdKey.rawValue)
        }
    }
}
