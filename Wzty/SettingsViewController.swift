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
import MessageUI

final class SettingsViewController: BaseTableViewController {
    
}

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "showLicenseAgreementSegue", sender: self)
            }
            if indexPath.row == 1 {
                self.performSegue(withIdentifier: "showPrivacyPolicySegue", sender: self)
            }
            if indexPath.row == 2 {
                self.performSegue(withIdentifier: "showFaqSegue", sender: self)
            }
            if indexPath.row == 3 {
                self.performSegue(withIdentifier: "showAboutSegue", sender: self)
            }
            if indexPath.row == 4 {
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                }
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                let alertViewController = UIAlertController(title: "Are you sure you want to clear cache?", message: nil, preferredStyle: .alert)
                let clearAction = UIAlertAction(title: "Clear cache", style: .destructive) { (alert) in
                    clearCache()
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                }
                
                alertViewController.addAction(clearAction)
                alertViewController.addAction(cancelAction)
                self.present(alertViewController, animated: true, completion: nil)
            }
            if indexPath.row == 1 {
                
                let alertViewController = UIAlertController(title: "Are you sure you want to logout?", message: nil, preferredStyle: .alert)
                let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (alert) in
                    
                    clearCache()
                    logout()
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                }
                
                alertViewController.addAction(logoutAction)
                alertViewController.addAction(cancelAction)
                self.present(alertViewController, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self 
        
        mailComposerVC.setToRecipients(["contact@wztnews.com"])
        mailComposerVC.setSubject("Feedback")
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
