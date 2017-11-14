//
//  KeyChain.swift
//  Wzty
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Tudor Ana on 05/11/2017.
//

import Foundation

struct KeyChain {
    
    static func remove(_ key: String) {
        let deleteQuery = KeyChain.query(key)
        let status: OSStatus = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess else { return }
    }
    
    static func load(_ key: String) -> Data? {
        
        var loadQuery = KeyChain.query(key)
        loadQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        loadQuery[kSecReturnData as String] = kCFBooleanTrue
        var result: AnyObject?
        let status = SecItemCopyMatching(loadQuery as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        
        return (result as! Data)
    }
    
    static func load(string key: String) -> String? {
        return String(data: KeyChain.load(key).defaultValue(defaultValue: Data()), encoding: .utf8)
    }
    
    static func save(_ value: Data, forkey: String) {
        
        //Remove old
        KeyChain.remove(forkey)

        //Add new one
        var saveQuery = KeyChain.query(forkey)
        saveQuery[kSecValueData as String] = value
        let status: OSStatus = SecItemAdd(saveQuery as CFDictionary, nil)
        guard status == errSecSuccess else { return }
        
    }
    
    
    static func query(_ key: String) -> [String : Any] {
        
        return [kSecClass as String : kSecClassGenericPassword as String,
                kSecAttrGeneric as String : key,
                kSecAttrAccount as String : key,
                kSecAttrService as String : "com.wztnews.wzty",
                kSecAttrAccessible as String : kSecAttrAccessibleAlwaysThisDeviceOnly as String]
    }
}

