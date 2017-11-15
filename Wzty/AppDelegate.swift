//
//  AppDelegate.swift
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
//  Created by Tudor Ana on 04/11/2017.
//

import UIKit
import Social

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = AppDelegate()
    var window: UIWindow?
    var twitter: Swifter?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Init twitter
        AppDelegate.shared.twitter = Swifter(consumerKey: "lLH1TSVtmbpzEcNUaJteq70wp", consumerSecret: "5Y3YDM9PzJr99YIbr4BfPQvM2Y1f92DiWz1NBEqxiUitfET234")
        
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        //Request notifications permissions
        NotificationController.shared.requestPermissionsWith { (status) in
        }
        
        //Change navigation title font
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.heavy), NSAttributedStringKey.foregroundColor: UIColor.black]
        
        return true
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataManager.shared.saveContextBackground()
        CoreDataManager.shared.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContextBackground()
        CoreDataManager.shared.saveContext()
    }
    
    
    //Background fetch
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationController.shared.notify {
            completionHandler(.newData)
        }
    }
    

    //Handle URL open
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        Swifter.handleOpenURL(url)
        return true
    }

}

