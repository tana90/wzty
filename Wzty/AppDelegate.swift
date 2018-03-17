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
    
    private static var sharedInstance: AppDelegate = {
        let appDelegate = AppDelegate()   
        do {
            objc_sync_enter(appDelegate)
            defer {
                objc_sync_exit(appDelegate)
            }
        }
        return appDelegate
    }()
    
    class func shared() -> AppDelegate {
        return AppDelegate.sharedInstance
    }
    
    var window: UIWindow?
    var twitter: Swifter?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Init twitter
        AppDelegate.shared().twitter = Swifter(consumerKey: "lLH1TSVtmbpzEcNUaJteq70wp", consumerSecret: "5Y3YDM9PzJr99YIbr4BfPQvM2Y1f92DiWz1NBEqxiUitfET234")
        
        //Set time interval between App Background Refreshes
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        //Request notifications permissions
        NotificationController.shared.requestPermissionsWith { (_) in }
        
        //Change navigation title font
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .semibold), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
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
    
    //Handle shortcuts
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        
        if let loginViewController = window?.rootViewController as? LoginViewController,
            let tabbarViewController = loginViewController.presentedViewController as? TabBarController {
            
            switch shortcutItem.localizedTitle {
            case "Boards":
                tabbarViewController.selectedIndex = 1
                break
            case "Explore":
                tabbarViewController.selectedIndex = 2
            case "Profile":
                tabbarViewController.selectedIndex = 3
                break
            default:
                break
            }
        }
        
    }
    
}

