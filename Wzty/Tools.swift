//
//  Utils.swift
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
//  Created by Tudor Ana on 06/11/2017.
//

import UIKit

func measure(title: String, block: @escaping ( @escaping () -> ()) -> ()) {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    
    block {
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        console("\(title):: Time: \(timeElapsed)")
    }
}


func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try body()
}


func console<T>(_ object: T, filename: String = #file, line: Int = #line, funcname: String = #function, isSolo: Bool? = false) {
    
    let className = filename.split{$0 == "/"}.map(String.init).last
    print("[\(Date()) :: \(className ?? "Unknow class") : \(funcname)(\(line))] - \(object)")
    
}

func logout() {
    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    let initialViewController = storyboard.instantiateInitialViewController()
    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nil
    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = initialViewController
}

func clearCache() {
    
    CoreDataManager.shared.deleteAllData(entity: "Post", from: CoreDataManager.shared.backgroundContext)
    CoreDataManager.shared.deleteAllData(entity: "Post", from: CoreDataManager.shared.managedObjectContext)
    
    CoreDataManager.shared.deleteAllData(entity: "User", from: CoreDataManager.shared.backgroundContext)
    CoreDataManager.shared.deleteAllData(entity: "User", from: CoreDataManager.shared.managedObjectContext)
    
    CoreDataManager.shared.saveContextBackground()
    CoreDataManager.shared.saveContext()
}
