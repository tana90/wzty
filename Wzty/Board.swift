//
//  Board.swift
//  Wzty
//
//  Created by Tudor Ana on 17/01/2018.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import Foundation
import CoreData

final class Board: NSManagedObject {
    
    @NSManaged var objectId: String?
    @NSManaged var name: String?
    @NSManaged var color: String?
    
    func delete() {
        
        let predicate = NSPredicate(format: "boardId == %@", objectId!)
        User.fetchAllBy(predicate: predicate) { (users) in
            
            if let _ = users {
                for user in users! {
                    user?.boardId = nil
                }
            }
            CoreDataManager.shared.delete(object: self)
        }
    }
    
    func edit(_ userIds: [String]) {
        let predicate = NSPredicate(format: "boardId == %@", objectId!)
        User.fetchAllBy(predicate: predicate) { (users) in
            
            //Remove old users from board
            if let _ = users {
                for user in users! {
                    user?.boardId = nil
                }
            }
            
            //Put new users to board
            for userId in userIds {
                User.fetchBy(id: userId, result: { [unowned self] (user) -> (Void) in
                    (user as? User)?.boardId = self.objectId
                })
            }
            
            //Save
            CoreDataManager.shared.saveContextBackground()
        }
    }
}

extension Board {
    
    static func fetchBy(id: String,
                        result: (NSManagedObject?) -> (Void)) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Board")
        let predicate = NSPredicate(format: "objectId == %@", id)
        request.predicate = predicate
        request.fetchLimit = 1
        CoreDataManager.shared.backgroundContext.performAndWait {
            do {
                let results = try CoreDataManager.shared.backgroundContext.fetch(request) as? [NSManagedObject]
                guard let last = results?.last else {
                    result(nil)
                    return
                }
                result(last)
            } catch _ {
                console("Error fetching object by id.")
                result(nil)
            }
        }
    }
    
    static func add(_ name: String, _ userIds: [String]) {
        
        if let newObject = NSEntityDescription.insertNewObject(forEntityName: "Board", into: CoreDataManager.shared.backgroundContext) as? Board {
            newObject.objectId = NSUUID().uuidString
            newObject.color = "#ff0000"
            newObject.name = name
            console(userIds)
            for userId in userIds {
                User.fetchBy(id: userId, result: { (user) -> (Void) in
                    (user as? User)?.boardId = newObject.objectId
                })
            }
            CoreDataManager.shared.saveContextBackground()
        }
    }
}