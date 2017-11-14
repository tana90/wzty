//
//  Post.swift
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

final class Post: NSManagedObject {
    
    @NSManaged var imageUrl: String?
    @NSManaged var objectId: String?
    @NSManaged var title: String?
    @NSManaged var details: String?
    @NSManaged var timestamp: Int
    @NSManaged var url: String?
    @NSManaged var userId: String?
    
    func write(json: JSON) {
        
        //Object ID
        if let objectId = json["id_str"].string {
            self.objectId = objectId
        }
        
        //Timestamp
        if let inputeddate = json["created_at"].string {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            formatter.locale = Locale(identifier: "en_US")
            if let date = formatter.date(from: inputeddate) {
                self.timestamp = Int(date.timeIntervalSince1970)
            } else {
                self.timestamp = Date.timestamp()
            }
        } else {
            self.timestamp = Date.timestamp()
        }
        
        //Url
        if let urls = json["entities"].object?["urls"]?.array {
            //Link
            if urls.count > 0 {
                if let urlLink = urls[0].object?["expanded_url"]?.string {
                    self.url = urlLink
                }
            }
            
        }
        
        
        //User
        User.add(json["user"], result: { (newObject) in
            self.userId = (newObject as? User)?.objectId
        })
    }
}


extension Post {
    
    static func add(objects: [JSON]) {
        
        for json in objects {
            if let urls = json["entities"].object?["urls"]?.array {
                //Link
                if urls.count > 0 {
                    if let _ = urls[0].object?["expanded_url"]?.string {
                        add(json)
                    }
                }
                
            }
        }
        
        //Save data
        CoreDataManager.shared.saveContextBackground()
    }
    
    
    static func add(_ json: JSON) {
        
        guard let objectId = json["id_str"].string else { return }
        let predicate = NSPredicate(format: "objectId == %@", objectId)
        fetchBy(predicate) { (post) in
            guard let postT = post else {
                if let newObject = NSEntityDescription.insertNewObject(forEntityName: "Post", into: CoreDataManager.shared.backgroundContext) as? Post {
                    newObject.write(json: json)
                }
                return
            }
            
            postT.write(json: json)
        }
    }
    
    
    static func fetchBy(_ predicate: NSPredicate,
                        result: (Post?) -> (Void)) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        request.predicate = predicate
        CoreDataManager.shared.backgroundContext.performAndWait {
            do {
                let results = try CoreDataManager.shared.backgroundContext.fetch(request) as? [Post]
                guard let last = results?.last else {
                    result(nil)
                    return
                }
                result(last)
            } catch _ {
                print("Error fetching object by id.")
                result(nil)
                
            }
        }
    }
    
    
    static func fetchAll(_ result: ([Post?]?) -> (Void)) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        request.fetchLimit = 100
        CoreDataManager.shared.backgroundContext.performAndWait {
            do {
                let results = try CoreDataManager.shared.backgroundContext.fetch(request) as? [Post]
                result(results)
            } catch _ {
                print("Error fetching object by id.")
                result(nil)
            }
        }
    }
    
}


extension Post {
    
    //Get current user timeline
    static func homeTimeline(sinceId: String? = nil,
                             maxId: String? = nil,
                             _ results: @escaping ([Post?]?) -> (Void)) {
        
        AppDelegate.shared.twitter?.getHomeTimeline(count: 100, sinceID: sinceId, maxID: maxId, trimUser: false, contributorDetails: true, includeEntities: true, success: { (json) in
            Post.add(objects: json.array!)
            
            guard let jsonArray = json.array,
                jsonArray.count > 0 else {
                    return
            }
            
            //Save first and last ids to user
            User.current() { (user) in
                
                let firstId = (json.array![0].object?["id_str"]?.string)!
                let lastId = (json.array![json.array!.count - 1].object?["id_str"]?.string)!
                if sinceId != nil && maxId != nil {
                    if sinceId != nil {
                        user?.sinceId = firstId
                    }
                    if maxId != nil {
                        user?.maxId = lastId
                    }
                } else {
                    user?.sinceId = firstId
                    user?.maxId = lastId
                }
                
                //Commit data
                CoreDataManager.shared.saveContextBackground()
            }
            
            Post.fetchAll() { (posts) in
                results(posts)
            }
            
        }, failure: { (error) in
            print("Error: \(error)")
        })
    }
    
    
    static func homeTimelineBy(userId: String,
                               sinceId: String? = nil,
                               maxId: String? = nil,
                               _ results: @escaping ([Post?]?) -> (Void)) {
        
        AppDelegate.shared.twitter?.getTimeline(for: userId, count: 50, sinceID: sinceId, maxID: maxId, trimUser: false, contributorDetails: true, includeEntities: true, success: { (json) in
            //
        }, failure: { (error) in
            print("Error: \(error)")
        })
    }
}
