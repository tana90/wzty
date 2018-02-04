//
//  NotificationsController.swift
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
//  Created by Tudor Ana on 12/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import Foundation
import UserNotifications

final class NotificationController {
    
    static let shared = NotificationController()
    private var markedNotifications: [String] = []
    
    func requestPermissionsWith(completion: ((Bool) -> (Void))? ) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            guard error == nil else {
                completion?(false)
                return
            }
            completion?(granted)
        }
    }
    
    
    func notify(_ finished: @escaping () -> (Void)) {
        
        Post.homeTimeline { [weak self] (status) in
            
            
            Post.fetchAll() { (posts) in
                guard let _ = self,
                    let posts = posts,
                    posts.count > 0 else {
                        finished()
                        return
                }
                
                guard self!.markedNotifications.count > 0 else {
                    self!.markedNotifications.append((posts.first??.objectId)!)
                    
                    if let firstPost = posts.first {
                        self!.scheduleNotificationWith(post: firstPost!)
                    }
                    finished()
                    return
                }
                
                var notificationFound = false
                postsLoop: for post in posts {
                    
                    notificationFound = false
                    markedLoop: for markedNotification in self!.markedNotifications {
                        
                        
                        if post?.objectId == markedNotification {
                            notificationFound = true
                        }
                    }
                    if notificationFound == false {
                        self!.markedNotifications.append((post?.objectId)!)
                        self!.scheduleNotificationWith(post: post!)
                        finished()
                        return
                    }
                }
                
                return
            }
        }
    }
    
    private func scheduleNotificationWith(post: Post!) {
        
        let predicate = NSPredicate(format: "objectId == %@", post.userId!)
        User.fetchBy(predicate: predicate) { (user) in
            guard let _ = user else { return }
            
            URL(string: post.link!)!.fetchUrlMedia({ (title, details, image) in
                
                let content = UNMutableNotificationContent()
                content.title = String(format: "%@", user!.username.defaultValue(defaultValue: ""))
                content.subtitle = String(format: "%@", title.defaultValue(defaultValue: "New notification"))
                content.body = String(format: "%@", details.defaultValue(defaultValue: ""))
                content.categoryIdentifier = "local"
                if let postId = post.objectId {
                    content.userInfo = ["postId" : postId]
                }
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                let request = UNNotificationRequest(identifier: "localNotification", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { (error) in
                }
                
            }, failure: { (error) in
                console("Error \(error)")
            })
            
            
        }
        
        
    }
}
