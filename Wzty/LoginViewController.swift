//
//  LoginViewController.swift
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

final class LoginViewController: BaseViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBAction func loginAction() {
        activityIndicatorView.startAnimating()
        AppDelegate.shared().twitter?.authorize(with: URL(string: "wzty://authentication")!, presentFrom: self, success: { [unowned self] (accessToken, urlResponse) in
            //Get user info
            guard let username = accessToken?.screenName,
                let oauthKey = accessToken?.key,
                let secretKey = accessToken?.secret
                else { 
                    self.activityIndicatorView.stopAnimating()
                    return 
            }
            
            //Save credentials
            KeyChain.save(username.data(using: .utf8)!, forkey: "username")
            KeyChain.save(oauthKey.data(using: .utf8)!, forkey: "oauthKey")
            KeyChain.save(secretKey.data(using: .utf8)!, forkey: "secretKey")
            
            self.loginSuccessfull()
            
            }, failure: { [unowned self] (error) in
                self.activityIndicatorView.stopAnimating()
                console("Error: \(error)")
        })
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //Check if we are alrString(describing: eady) logged in
        guard let username = KeyChain.load(string: "username"),
            username.count > 0,
            let oauthKey = KeyChain.load(string: "oauthKey"),
            oauthKey.count > 0,
            let secretKey = KeyChain.load(string: "secretKey"),
            secretKey.count > 0
            else { 
                activityIndicatorView.stopAnimating()
                return 
        }
        
        //Authenticate automatically
        AppDelegate.shared().twitter = Swifter.init(consumerKey: "lLH1TSVtmbpzEcNUaJteq70wp", consumerSecret: "5Y3YDM9PzJr99YIbr4BfPQvM2Y1f92DiWz1NBEqxiUitfET234", oauthToken: oauthKey, oauthTokenSecret: secretKey)
        
        AppDelegate.shared().twitter?.verifyAccountCredentials(includeEntities: false, skipStatus: true, success: { [unowned self] (json) in
            self.loginSuccessfull()
        }, failure: { [unowned self] (error) in
            self.activityIndicatorView.stopAnimating()
            console(error)
        })
    }
    
    func loginSuccessfull() {       
        activityIndicatorView.stopAnimating()
        self.performSegue(withIdentifier: "showTabbarControllerSegue", sender: self)
    }
}
