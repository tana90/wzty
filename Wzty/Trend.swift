//
//  Trends.swift
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
//  Created by Tudor Ana on 2/26/18.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import Foundation
import CoreData

final class Trend: NSManagedObject {
    
    @NSManaged var objectId: String?
    @NSManaged var name: String?
    @NSManaged var username: String?
    
    func write(_ dic: DefaultDictionary) {
        
        if let _ = dic["c"] as? String {
            self.objectId = dic["c"] as? String
        }
        
        if let _ = dic["n"] as? String {
            self.name = dic["n"] as? String
        }
        
        if let _ = dic["u"] as? String {
            self.username = dic["u"] as? String
        }
    }
    
}

extension Trend {
    
    static func sync(_ finished: @escaping (_ status: Bool) -> (Void)) {
        
        fetch { (trends) -> (Void) in
            guard let _ = trends else { return }
            finished(true)
        }

        let urlString = String(format: "http://tweeplers.com/countdata/?cc=%@&_=%ld", Locale.current.regionCode!, Date.timestamp())
        let request = URLRequest(url: URL(string: urlString)!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            guard error == nil,
                let dataT = data else {
                    return
            }

            dataT.toDictionary({ (dictionary) in

                guard let _ = dictionary,
                    let trends = dictionary!["list"] as? [DefaultDictionary] else { return }
                DispatchQueue.main.safeAsync {
                    CoreDataManager.shared.deleteAllData(entity: "Trend", from: CoreDataManager.shared.backgroundContext)
                    add(trends)
                    finished(true)
                }
                
            })
        }.resume()
    }
    
    static func add(_ trends: [DefaultDictionary]) {
        
        for trend in trends {
            if let newObject = NSEntityDescription.insertNewObject(forEntityName: "Trend", into: CoreDataManager.shared.backgroundContext) as? Trend {
                newObject.write(trend)
            }
        }
        CoreDataManager.shared.saveContextBackground()
    }
    
    static func fetch(_ result: ([NSManagedObject?]?) -> (Void)) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Trend")
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
