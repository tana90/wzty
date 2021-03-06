//
//  NavigationTableHeaderView.swift
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
//  Created by Tudor Ana on 12/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit

final class NavigationTableHeaderView: UIView {
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    public var closeActionHandler: (()->Void)?
    public var moreActionHander: (()->Void)?
    
    
    @IBAction func closeAction() {
        if let handler = closeActionHandler {
            handler()
        }
    }
    
    @IBAction func moreAction() {
        if let handler = moreActionHander {
            handler()
        }
    }
    
    func showTitle() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) { [weak self] in
            guard let _ = self else { return }
            self!.titleLabel.alpha = 1.0
        }.startAnimation()
    }
    
    func hideTitle() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) { [weak self] in
            guard let _ = self else { return }
            self!.titleLabel.alpha = 0.0
            }.startAnimation()
    }
}
