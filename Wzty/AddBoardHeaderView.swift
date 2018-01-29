//
//  AddBoardHeaderView.swift
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
//  Created by Tudor Ana on 16/01/2018.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit

final class AddBoardHeaderView: UIView {
    
    @IBOutlet weak var textField: UITextField?
    
    public var changeNameHandler: ((String) -> ())?
    
    @IBAction func textDidChange(_ sender: UITextField) {
        if let handler = changeNameHandler {
            handler(sender.text!)
        }
    }
}

