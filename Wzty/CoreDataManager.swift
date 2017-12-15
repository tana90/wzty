//
//  CoreDataManager.swift
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


final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1] as NSURL
    }()
    
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = Bundle.main.url(forResource: "Data", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = { [unowned self] in
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Data.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                       NSInferMappingModelAutomaticallyOption: true]
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: url,
                                               options: options)
        } catch {
            
            var dict = [String: AnyObject]()
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN",
                                       code: 9999,
                                       userInfo: dict)
            
            console("Persistent store -- Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
        }()
    
    
    
    lazy var managedObjectContext: NSManagedObjectContext = { [unowned self] in
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
        }()
    
    
    lazy var backgroundContext: NSManagedObjectContext = { [unowned self] in
        var backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = self.managedObjectContext
        return backgroundContext
        }()
    
    
    
    final func saveContextBackground() {
        backgroundContext.performAndWait({
            if backgroundContext.hasChanges {
                do {
                    try self.backgroundContext.save()
                } catch {
                    let nserror = error as NSError
                    console("Save context in background -- Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        })
    }
    
    
    // MARK: - Core Data Saving support
    final func saveContext() {
        managedObjectContext.performAndWait {
            if managedObjectContext.hasChanges {
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    let nserror = error as NSError
                    console("Save context -- Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    func delete(object: NSManagedObject) {
        backgroundContext.performAndWait {
            backgroundContext.delete(object)
        }
        saveContextBackground()
    }
    
    //Wipe data
    func deleteAllData(entity: String,
                       from context: NSManagedObjectContext)
    {
        let managedContext = context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        managedContext.performAndWait {
            do
            {
                let results = try managedContext.fetch(fetchRequest)
                for managedObject in results
                {
                    let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                    managedContext.delete(managedObjectData)
                }
            } catch let error as NSError {
                console("Detele all data in \(entity) error : \(error) \(error.userInfo)")
            }
        }
    }
    
}
