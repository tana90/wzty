//
//  SettingsViewController.swift
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

import UIKit

final class SettingsViewController: BaseSettingsViewController {
    
    
}


extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            CoreDataManager.shared.deleteAllData(entity: "User", from: CoreDataManager.shared.backgroundContext)
            CoreDataManager.shared.deleteAllData(entity: "User", from: CoreDataManager.shared.managedObjectContext)
            
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if indexPath.row == 1 {
            KeyChain.remove("username")
            KeyChain.remove("oauthKey")
            KeyChain.remove("secretKey")
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nil
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = initialViewController
            return
        }
    }
}
