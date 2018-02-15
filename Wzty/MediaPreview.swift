//
//  MediaPreview.swift
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
//  Created by Tudor Ana on 13/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit

final class MediaPreview: BaseViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    var isZoomed: Bool = false
    
    @IBAction func closeAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func show(_ imageUrl: String?) {
        
        guard let _ = imageUrl else {
            closeAction()
            return
        }
        
        imageView.kf.setImage(with: URL(string: imageUrl!), placeholder: nil, options: nil, progressBlock: { (pregress, maxProgress) in
            
        }) { (image, error, cache, url) in
            
            DispatchQueue.main.safeAsync { [weak  self] in
                guard let _ = self else { return }
                self!.scrollView.delegate = self
                let raport = max((image?.size.width)! / self!.scrollView.frame.size.width, (image?.size.height)! / self!.scrollView.frame.size.height)
                let maxSize = max(2.0, raport)
                
                self!.scrollView.setZoomScale(1.0, animated: true)
                self!.scrollView.maximumZoomScale = maxSize
                self!.scrollView.minimumZoomScale = 1.0
                
                self!.isZoomed = false
                
                let doubleTap = UITapGestureRecognizer(target: self!, action: #selector(self!.doubleTapped))
                doubleTap.numberOfTapsRequired = 2
                self!.scrollView.addGestureRecognizer(doubleTap)
                
                let singleTap = UITapGestureRecognizer(target: self!, action: #selector(self!.singleTap))
                singleTap.numberOfTapsRequired = 1
                self!.scrollView.addGestureRecognizer(singleTap)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: { [weak self] in
                    guard let _ = self else { return }
                    self!.singleTap()
                })
            }
        }
    }
    

    @objc func doubleTapped() {
        if isZoomed == false {
            scrollView.setZoomScale(2.0, animated: true)
            isZoomed = true
            
            UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) { [weak self] in
                self!.navigationView.alpha = 0.0
                }.startAnimation()
        } else {
            scrollView.setZoomScale(1, animated: true)
            isZoomed = false
            
            UIViewPropertyAnimator(duration: 0.3, curve: .easeIn) { [weak self] in
                self!.navigationView.alpha = 1.0
                }.startAnimation()
        }
    }
    
    @objc func singleTap() {
        
        if scrollView.zoomScale <= 1.0 {
            if navigationView.alpha == 0.0 {
                
                UIViewPropertyAnimator(duration: 0.3, curve: .easeIn) { [weak self] in
                    self!.navigationView.alpha = 1.0
                    }.startAnimation()
            } else {
                UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) { [weak self] in
                    self!.navigationView.alpha = 0.0
                    }.startAnimation()
            }
        } else {
            UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) { [weak self] in
                self!.navigationView.alpha = 0.0
                }.startAnimation()
        }
    }
}

extension MediaPreview: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    final func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let alpha = max(abs(scrollView.contentOffset.y) / 200, abs(scrollView.contentOffset.x) / 200)
        
        if scrollView.zoomScale <= 1.0 {
            backView.alpha = 1 - alpha
        } else {
            backView.alpha = 1
        }
        
        if scrollView.zoomScale <= 1.0,
            scrollView.contentOffset.y < -100.0 || scrollView.contentOffset.y > 100 ||
                scrollView.contentOffset.x < -90.0 || scrollView.contentOffset.x > 90
        {
            closeAction()
        }
    }
}
