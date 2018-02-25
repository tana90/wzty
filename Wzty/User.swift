//
//  User.swift
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
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import Foundation
import CoreData

final class User: NSManagedObject {
    
    @NSManaged var objectId: String?
    @NSManaged var userImageUrl: String?
    @NSManaged var username: String?
    @NSManaged var name: String?
    @NSManaged var following: Bool
    @NSManaged var followingsCount: NSNumber?
    @NSManaged var location: String?
    
    @NSManaged var insertedTimestamp: NSNumber?
    
    @NSManaged var boardId: String?
    
    @NSManaged var sinceId: String?
    @NSManaged var maxId: String?
    
    @NSManaged var nextCursor: String?
    
    func write(json: [String: JSON]) {
        
        //Object ID
        if let _ = json["id_str"]?.string {
            self.objectId = json["id_str"]?.string
        }
        
        //User image Url
        if let _ = json["profile_image_url"]?.string {
            self.userImageUrl = json["profile_image_url"]?.string
            self.userImageUrl = self.userImageUrl?.replacingOccurrences(of: "_normal", with: "")
        }
        
        //Username
        if let _ = json["screen_name"]?.string {
            self.username = json["screen_name"]?.string
        }
        
        //Name
        if let _ = json["name"]?.string {
            self.name = json["name"]?.string
        }
        
        //Following true/false
        if let _ = json["following"]?.bool {
            self.following = (json["following"]?.bool)!
        }
        
        //Followings count
        if let _ = json["friends_count"]?.double {
            followingsCount = NSNumber(value: Int((json["friends_count"]?.double)!))
        } else {
            followingsCount = NSNumber(value: 0)
        }
        
        //Location
        if let _ = json["location"]?.string {
            location = json["location"]?.string
        }
        
        //Inserted timestamp
        if self.insertedTimestamp == nil || self.insertedTimestamp?.intValue == 0 {
            self.insertedTimestamp = NSNumber(value: Date.timestamp())
        }
    }
}


extension User {
    
    static func add(objects: [JSON]) {
        
        for json in objects {
            add(json) { (newObject) in }
        }
        //Save data
        CoreDataManager.shared.saveContextBackground()
    }
    
    
    static func add(_ json: JSON,
                    result: (NSManagedObject!) -> (Void)) {
        
        guard let objectId = json["id_str"].string else { return }
        fetchBy(id: objectId) { (user) in
            guard let _ = user else {
                //Insert new user
                if let newObject = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataManager.shared.backgroundContext) as? User {
                    newObject.write(json: json.object!)
                    result(newObject)
                }
                return
            }
            //Update existing user
            (user! as! User).write(json: json.object!)
            result(user!)
        }
    }
    
    
    static func fetchBy(id: String,
                        result: (NSManagedObject?) -> (Void)) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let predicate = NSPredicate(format: "objectId == %@", id)
        request.predicate = predicate
        request.fetchLimit = 1
        request.fetchBatchSize = 1
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
    
    
    static func fetchBy(predicate: NSPredicate,
                        result: @escaping (User?) -> (Void)) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = predicate
        request.fetchLimit = 1
        request.fetchBatchSize = 1
        CoreDataManager.shared.backgroundContext.performAndWait {
            do {
                let results = try CoreDataManager.shared.backgroundContext.fetch(request) as? [User]
                guard let _ = results?.last else {
                    result(nil)
                    return
                }
                result(results?.last)
            } catch _ {
                console("Error fetching object by id.")
                result(nil)
            }
        }
    }
    
    
    static func fetchAllBy(predicate: NSPredicate,
                           result: ([User?]?) -> (Void)) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = predicate
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        CoreDataManager.shared.backgroundContext.performAndWait {
            do {
                let results = try CoreDataManager.shared.backgroundContext.fetch(request) as? [User]
                result(results)
            } catch _ {
                console("Error fetching object by id.")
                result(nil)
            }
        }
    }
    
    
    static func fetch(_ result: ([NSManagedObject?]?) -> (Void)) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        CoreDataManager.shared.backgroundContext.performAndWait {
            do {
                let results = try CoreDataManager.shared.backgroundContext.fetch(request) as? [NSManagedObject]
                result(results)
            } catch _ {
                console("Error fetching object by id.")
                result(nil)
            }
        }
    }
}




extension User {
    
    //Reload current user from cloud
    static func refreshCurrent(_ user: @escaping (User!) -> (Void)) {
        
        AppDelegate.shared().twitter?.verifyAccountCredentials(includeEntities: false, skipStatus: true, success: { (json) in
            User.add(json, result: { (newObject) in
                user(newObject as? User)
            })
        }, failure: { (error) in
            user(nil)
        })
    }
    
    
    //Get current user
    static func current(refreshable: Bool = false ,_ user: @escaping (User!) -> (Void)) {
        
        guard let username = KeyChain.load(string: "username") else { return }
        //Check if we already have current user in database
        let predicate = NSPredicate(format: "username == %@", username)
        User.fetchBy(predicate: predicate) { (result) in
            if refreshable {
                //Fetch current user from Twitter
                refreshCurrent { (newObject) in
                    user(newObject)
                }
            } else {
                guard let _ = result else {
                    //Fetch current user from Twitter if there is no user info
                    refreshCurrent { (newObject) in
                        user(newObject)
                    }
                    return
                }
                user(result!)
            }
        }
    }
    
    
    //Get all current users followings
    static func followings(of user: User,
                           _ finished: @escaping (Bool) -> (Void),
                           with cursor: String = "-1") {
        
        AppDelegate.shared().twitter?.getUserFollowing(for: UserTag.id(user.objectId!), cursor: cursor, count: 50, skipStatus: true, includeUserEntities: true, success: { (json, currentCursor, nextCursor) in
            User.add(objects: json.array!)
            user.nextCursor = nextCursor
            CoreDataManager.shared.saveContextBackground()
            finished(true)
        }, failure: { (error) in
            console("Error: \(error)")
        })
    }
    
    
    
    //Search users
    static func searchUsers(_ query: String, 
                            _ finished: @escaping (Bool, Int) -> (Void)) {
        
        let timestamp = Date.timestamp()
        AppDelegate.shared().twitter?.searchUsers(using: query, page: 0, count: 50, includeEntities: false, success: { (json) in
            User.add(objects: json.array!)
            finished(true, timestamp)
        }, failure: { (error) in
            console("Error: \(error)")
        })
    }
    
    
    
    //Follow/Unfollow user
    static func follow(_ status: Bool,
                       _ userId: String, 
                       _ finished: @escaping (Bool) -> (Void)) {
        
        let userTag = UserTag.id(userId)
        if status == true {
            AppDelegate.shared().twitter?.followUser(for: userTag, follow: true, success: { (json) in
                User.add(json, result: { (user) in 
                    (user as! User).following = true
                    CoreDataManager.shared.saveContextBackground()
                    finished(true)
                })
            }, failure: { (error) in
                console("Error: \(error)")
            })
        } else {
            AppDelegate.shared().twitter?.unfollowUser(for: userTag, success: { (json) in
                User.add(json, result: { (user) in 
                    (user as! User).following = false
                    CoreDataManager.shared.saveContextBackground()
                    finished(true)
                })
            }, failure: { (error) in
                console("Error: \(error)")
            }) 
        }
    }
    
    
    //Report user
    static func report(_ userId: String, 
                       _ finished: @escaping (Bool) -> (Void)) {
        
        let userTag = UserTag.id(userId)
        AppDelegate.shared().twitter?.reportSpam(for: userTag, success: { (json) in
            finished(true)
        }, failure: { (error) in
            console("Error: \(error)")
        })
    }
}
