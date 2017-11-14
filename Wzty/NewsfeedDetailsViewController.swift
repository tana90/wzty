//
//  NewsfeedDetailsViewController.swift
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

final class NewsfeedDetailsViewController: BaseDetailsViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension NewsfeedDetailsViewController {

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let postT = post else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        switch indexPath.row {
        case 0:
            let detailsCell = tableView.dequeueReusableCell(withIdentifier: "newsfeedDetailsCell") as! NewsfeedDetailsCell
            detailsCell.showImageActionHandler = { [unowned self] in
                print("Show image")
                let mediaPreview = MediaPreview(nibName: "MediaPreview", bundle: nil)
                self.present(mediaPreview, animated: true, completion: nil)
                mediaPreview.show(postT.imageUrl)
            }
            detailsCell.show(postT)
            return detailsCell
        case 1:
            let webViewCell = tableView.dequeueReusableCell(withIdentifier: "newsfeedWebCell") as! NewsfeedWebCell
            webViewCell.beginScrollHandler = {
                tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
            }
            webViewCell.changeTitleHandler = { [weak self] title in
                guard let strongSelf = self else { return }
                strongSelf.navigationHeaderView.titleLabel.text = title
            }
            webViewCell.closeHandler = {
                tableView.isScrollEnabled = true
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            webViewCell.show(postT)
            return webViewCell
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
}

extension NewsfeedDetailsViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("Prefetch row \(indexPaths)")
    }
}
