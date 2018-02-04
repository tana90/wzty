//
//  Indicator.swift
//  Kingfisher
//
//  Created by João D. Moreira on 30/08/16.
//
//  Copyright (c) 2017 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

public typealias IndicatorView = UIView


public enum IndicatorType {
    /// No indicator.
    case none
    /// Use system activity indicator.
    case activity
    /// Use an image as indicator. GIF is supported.
    case image(imageData: Data)
    /// Use a custom indicator, which conforms to the `Indicator` protocol.
    case custom(indicator: Indicator)
}

// MARK: - Indicator Protocol
public protocol Indicator {
    func startAnimatingView()
    func stopAnimatingView()
    
    var viewCenter: CGPoint { get set }
    var view: IndicatorView { get }
}

extension Indicator {
    public var viewCenter: CGPoint {
        get {
            return view.center
        }
        set {
            view.center = newValue
        }
    }
}

// MARK: - ActivityIndicator
// Displays a NSProgressIndicator / UIActivityIndicatorView
struct ActivityIndicator: Indicator {
    private let activityIndicatorView: UIActivityIndicatorView
    
    var view: IndicatorView {
        return activityIndicatorView
    }
    
    func startAnimatingView() {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
    }
    
    func stopAnimatingView() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
    init() {
        
        let indicatorStyle = UIActivityIndicatorViewStyle.gray
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:indicatorStyle)
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
    }
}

// MARK: - ImageIndicator
// Displays an ImageView. Supports gif
struct ImageIndicator: Indicator {
    private let animatedImageIndicatorView: ImageView
    
    var view: IndicatorView {
        return animatedImageIndicatorView
    }
    
    init?(imageData data: Data, processor: ImageProcessor = DefaultImageProcessor.default, options: KingfisherOptionsInfo = KingfisherEmptyOptionsInfo) {
        
        var options = options
        // Use normal image view to show gif, so we need to preload all gif data.
        if !options.preloadAllGIFData {
            options.append(.preloadAllGIFData)
        }
        
        guard let image = processor.process(item: .data(data), options: options) else {
            return nil
        }
        
        animatedImageIndicatorView = ImageView()
        animatedImageIndicatorView.image = image
        
        animatedImageIndicatorView.contentMode = .center
        
        animatedImageIndicatorView.autoresizingMask = [.flexibleLeftMargin,
                                                       .flexibleRightMargin,
                                                       .flexibleBottomMargin,
                                                       .flexibleTopMargin]
    }
    
    func startAnimatingView() {
        animatedImageIndicatorView.startAnimating()
        animatedImageIndicatorView.isHidden = false
    }
    
    func stopAnimatingView() {
        animatedImageIndicatorView.stopAnimating()
        animatedImageIndicatorView.isHidden = true
    }
}
