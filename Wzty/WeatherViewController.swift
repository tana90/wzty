//
//  WeatherViewController.swift
//  Wzty
//
//  Created by Tudor Ana on 3/19/18.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit

final class WeatherViewController: BaseTableViewController {
    
    @IBAction func closeAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
