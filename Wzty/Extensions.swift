//
//  Extensions.swift
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

import Foundation
import UIKit


extension UIImage {
    
    func blur(quantity: CGFloat) -> UIImage {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: self)
        let originalOrientation = self.imageOrientation
        let originalScale = self.scale
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(quantity, forKey: kCIInputRadiusKey) 
        let outputImage = filter?.outputImage
        
        var cgImage:CGImage?
        
        if let asd = outputImage {
            cgImage = context.createCGImage(asd, from: (inputImage?.extent)!)
        }
        
        if let cgImageA = cgImage {
            return UIImage(cgImage: cgImageA, scale: originalScale, orientation: originalOrientation)
        }
        
        return self
    }
    
    var roundedImage: UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.width)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

//MARK: - UIView
extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return UIColor.clear
            }
        } set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            } else {
                return UIColor.clear
            }
        } set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        } set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        } set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        } set {
            layer.shadowOffset = newValue
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        let layer = self.layer
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        //Optional, to improve performance:
        layer.shadowPath = UIBezierPath.init(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        
        let backgroundCGColor = self.backgroundColor?.cgColor
        self.backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
}

//MARK: - UITextField
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}


//MARK: - Optional
extension Optional {
    
    func defaultValue(defaultValue: Wrapped) -> Wrapped {
        switch(self) {
        case .none:
            return defaultValue
        case .some(let value):
            return value
        }
    }
}

//MARK: - Date
extension Date {
    
    static func timestamp() -> Int {
        return Int((Date().timeIntervalSince1970 * 1000000.0).rounded())
    }
    
    func getReadableVersion() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat =  "EEEE\nMMMM dd"
        return formatter.string(from: self as Date).uppercased()
    }
    
    func getElapsedDays() -> Int! {
        
        let unitFlags = Set<Calendar.Component>([.day])
        var components = Calendar.current.dateComponents(unitFlags, from: self, to: Date())
        let interval = components.day
        
        if interval! > 0 {
            return interval!
        } else {
            return 0
        }
    }
    
    func getElapsedInterval(shortFormat: Bool) -> String {
        
        
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "en_US")
        monthFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM dd", options: 0, locale: NSLocale.current)
        
        let yearFormatter = DateFormatter()
        yearFormatter.locale = Locale(identifier: "en_US")
        yearFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM dd YYYY", options: 0, locale: NSLocale.current)
        
        let unitFlags = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])
        
        
        
        var components = Calendar.current.dateComponents(unitFlags, from: self, to: Date())
        var interval = components.year
        
        if interval! > 0 {
            return yearFormatter.string(from: self as Date)
        }
        
        interval = components.month
        
        if interval! > 0 {
            return monthFormatter.string(from: self as Date)
        }
        
        interval = components.day
        
        if interval! > 0 {
            if shortFormat {
                return String.localizedStringWithFormat(NSLocalizedString("%d days", comment: "{number of days} days"), interval!)
            } else {
                return String.localizedStringWithFormat(NSLocalizedString("%d %@ ago", comment: "{number of days}d"), interval!, interval! == 1 ? "day" : "days")
            }
        }
        
        interval = components.hour
        
        if interval! > 0 {
            if shortFormat {
                return String.localizedStringWithFormat(NSLocalizedString("%d hrs", comment: "{number h} hrs"), interval!)
            } else {
                return String.localizedStringWithFormat(NSLocalizedString("%d %@ ago", comment: "{number of hours}h"), interval!,
                                                        interval! == 1 ? "hour" : "hours")
            }
        }
        
        interval = components.minute
        
        if interval! > 0 {
            if shortFormat {
                return String.localizedStringWithFormat(NSLocalizedString("%d min", comment: "{number m} min"), interval!)
            } else {
                return String.localizedStringWithFormat(NSLocalizedString("%d %@ ago", comment: "{number of minutes}m"), interval!,
                                                        interval! == 1 ? "minute" : "minutes")
            }
        }
        
        interval = components.second
        
        if interval! > 0 {
            return String.localizedStringWithFormat(NSLocalizedString("Now", comment: "Now"))
        }
        
        if shortFormat {
            return NSLocalizedString("1s", comment: "now")
        } else {
            return NSLocalizedString("1s", comment: "one second ago")
        }
    }
}

//MARK: - URL
public extension URL {
    
    struct ValidationQueue {
        static var queue = OperationQueue()
    }
    
    func fetchUrlMedia(_ completion: @escaping ((_ title: String?, _ description: String?, _ previewImage: String?) -> Void), failure: @escaping ((_ errorMessage: String) -> Void)) {
        
        let request = NSMutableURLRequest(url: self)
        let newUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36"
        request.setValue(newUserAgent, forHTTPHeaderField: "User-Agent")
        ValidationQueue.queue.cancelAllOperations()
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            guard error == nil,
                let urlResponse = response as? HTTPURLResponse,
                urlResponse.statusCode >= 200 && urlResponse.statusCode < 400,
                let data = data else {
                    DispatchQueue.main.async {
                        failure("Unable to get URL data")
                    }
                    return
            }
            
            if let doc = HTML(html: data, encoding: String.Encoding.utf8) {
                let title = doc.title
                var description: String? = nil
                var previewImage: String? = nil
                if let nodes = doc.head?.xpath("//meta").enumerated() {
                    for node in nodes {
                        if node.element["property"]?.contains("description") == true ||
                            node.element["name"] == "description" {
                            description = node.element["content"]
                        }
                        
                        if node.element["property"]?.contains("image") == true &&
                            node.element["content"]?.contains("http") == true {
                            previewImage = node.element["content"]
                        }
                        
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    completion(String.removeUrls(text: title), String.removeUrls(text: description), previewImage)
                })
            }
            
        }).resume()
    }
}


//MARK: - String
extension String {
    
    static func removeUrls(text: String?) -> String? {
        
        if let textT = text {
            var rmvText = textT.replacingOccurrences(of: "@(https?://([-\\w\\.]+[-\\w])+(:\\d+)?(/([\\w/_\\.#-]*(\\?\\S+)?[^\\.\\s])?)?)@", with: "", options: .regularExpression, range: textT.startIndex ..< textT.endIndex)
            rmvText = rmvText.replacingOccurrences(of: "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)", with: "", options: .regularExpression, range: textT.startIndex ..< textT.endIndex)
            
            rmvText = rmvText.replacingOccurrences(of: "&abreve;", with: "a")
            rmvText = rmvText.replacingOccurrences(of: "&Abreve;", with: "A")
            rmvText = rmvText.replacingOccurrences(of: "&tcedil;", with: "t")
            rmvText = rmvText.replacingOccurrences(of: "&Tcedil;", with: "T")
            rmvText = rmvText.replacingOccurrences(of: "&scedil;", with: "s")
            rmvText = rmvText.replacingOccurrences(of: "&Scedil;", with: "S")
            rmvText = rmvText.replacingOccurrences(of: "&comma;", with: ",")
            rmvText = rmvText.replacingOccurrences(of: "&colon;", with: ":")
            rmvText = rmvText.replacingOccurrences(of: "&period;", with: ".")
            rmvText = rmvText.replacingOccurrences(of: "&vert;", with: "-")
            rmvText = rmvText.replacingOccurrences(of: "&quest;", with: "?")
            rmvText = rmvText.replacingOccurrences(of: "&excl;", with: "!")
            rmvText = rmvText.replacingOccurrences(of: "&lpar;", with: "(")
            rmvText = rmvText.replacingOccurrences(of: "&rpar;", with: ")")
            rmvText = rmvText.replacingOccurrences(of: "&sol;", with: "/")
            rmvText = rmvText.replacingOccurrences(of: "&percnt;", with: "%")
            rmvText = rmvText.replacingOccurrences(of: "&lt;", with: "<")
            rmvText = rmvText.replacingOccurrences(of: "&gt;", with: ">")
            rmvText = rmvText.replacingOccurrences(of: "&le;", with: "<=")
            rmvText = rmvText.replacingOccurrences(of: "&ge;", with: ">=")
            rmvText = rmvText.replacingOccurrences(of: "&hellip;", with: "...")
            rmvText = rmvText.replacingOccurrences(of: "&amp;", with: "&")
            rmvText = rmvText.replacingOccurrences(of: "&ldquo;", with: "\"")
            rmvText = rmvText.replacingOccurrences(of: "&rdquo;", with: "\"")
            rmvText = rmvText.replacingOccurrences(of: "&rsquo;", with: "'")
            rmvText = rmvText.replacingOccurrences(of: "\"", with: "")
            rmvText = rmvText.replacingOccurrences(of: "“", with: "")
            rmvText = rmvText.replacingOccurrences(of: "”", with: "")
            
            rmvText = rmvText.replacingOccurrences(of: "&mdash;", with: "—")
            rmvText = rmvText.replacingOccurrences(of: "&ndash;", with: "—")
            rmvText = rmvText.replacingOccurrences(of: "&middot;", with: "·")
            rmvText = rmvText.replacingOccurrences(of: "&micro;", with: "µ")
            rmvText = rmvText.replacingOccurrences(of: "&permil;", with: "‰")
            rmvText = rmvText.replacingOccurrences(of: "&deg;", with: "°")
            rmvText = rmvText.replacingOccurrences(of: "&trade;", with: "™")
            rmvText = rmvText.replacingOccurrences(of: "&reg;", with: "®")
            rmvText = rmvText.replacingOccurrences(of: "&copy;", with: "©")
            rmvText = rmvText.replacingOccurrences(of: "&dagger;", with: "†")
            rmvText = rmvText.replacingOccurrences(of: "&bull;", with: "•")
            rmvText = rmvText.replacingOccurrences(of: "&raquo;", with: "»")
            rmvText = rmvText.replacingOccurrences(of: "&laquo;", with: "«")
            rmvText = rmvText.replacingOccurrences(of: "&pound;", with: "£")
            rmvText = rmvText.replacingOccurrences(of: "&euro;", with: "€")
            
            //Romanian
            rmvText = rmvText.replacingOccurrences(of: "&#258;", with: "Ă")
            rmvText = rmvText.replacingOccurrences(of: "&Acirc;", with: "Â")
            rmvText = rmvText.replacingOccurrences(of: "&Icirc;", with: "Î")
            rmvText = rmvText.replacingOccurrences(of: "&#350;", with: "Ş")
            rmvText = rmvText.replacingOccurrences(of: "&#354;", with: "Ţ")
            rmvText = rmvText.replacingOccurrences(of: "&#259;", with: "ă")
            rmvText = rmvText.replacingOccurrences(of: "&acirc;", with: "â")
            rmvText = rmvText.replacingOccurrences(of: "&icirc;", with: "î")
            rmvText = rmvText.replacingOccurrences(of: "&#351;", with: "ş")
            rmvText = rmvText.replacingOccurrences(of: "&#355;", with: "ţ")
            
            //German
            rmvText = rmvText.replacingOccurrences(of: "&Auml;", with: "Ä")
            rmvText = rmvText.replacingOccurrences(of: "&Ouml;", with: "Ö")
            rmvText = rmvText.replacingOccurrences(of: "&Uuml;", with: "Ü")
            rmvText = rmvText.replacingOccurrences(of: "&auml;", with: "ä")
            rmvText = rmvText.replacingOccurrences(of: "&ouml;", with: "ö")
            rmvText = rmvText.replacingOccurrences(of: "&uuml;", with: "ü")
            rmvText = rmvText.replacingOccurrences(of: "&szlig;", with: "ß")
            
            //French
            rmvText = rmvText.replacingOccurrences(of: "&Agrave;", with: "À")
            rmvText = rmvText.replacingOccurrences(of: "&Ccedil;", with: "Ç")
            rmvText = rmvText.replacingOccurrences(of: "&Egrave;", with: "È")
            rmvText = rmvText.replacingOccurrences(of: "&Eacute;", with: "É")
            rmvText = rmvText.replacingOccurrences(of: "&Ecirc;", with: "Ê")
            rmvText = rmvText.replacingOccurrences(of: "&Euml;", with: "Ë")
            rmvText = rmvText.replacingOccurrences(of: "&Iuml;", with: "Ï")
            rmvText = rmvText.replacingOccurrences(of: "&Ocirc;", with: "Ô")
            rmvText = rmvText.replacingOccurrences(of: "&OElig;", with: "Œ")
            rmvText = rmvText.replacingOccurrences(of: "&Ugrave;", with: "Ù")
            rmvText = rmvText.replacingOccurrences(of: "&Ucirc;", with: "Û")
            rmvText = rmvText.replacingOccurrences(of: "&Uuml;", with: "Ü")
            rmvText = rmvText.replacingOccurrences(of: "&#376;", with: "Ÿ")
            
            rmvText = rmvText.replacingOccurrences(of: "&agrave;", with: "à")
            rmvText = rmvText.replacingOccurrences(of: "&ccedil;", with: "ç")
            rmvText = rmvText.replacingOccurrences(of: "&egrave;", with: "è")
            rmvText = rmvText.replacingOccurrences(of: "&eacute;", with: "é")
            rmvText = rmvText.replacingOccurrences(of: "&ecirc;", with: "ê")
            rmvText = rmvText.replacingOccurrences(of: "&euml;", with: "ë")
            rmvText = rmvText.replacingOccurrences(of: "&iuml;", with: "ï")
            rmvText = rmvText.replacingOccurrences(of: "&ocirc;", with: "ô")
            rmvText = rmvText.replacingOccurrences(of: "&oElig;", with: "œ")
            rmvText = rmvText.replacingOccurrences(of: "&ugrave;", with: "ù")
            rmvText = rmvText.replacingOccurrences(of: "&ucirc;", with: "û")
            rmvText = rmvText.replacingOccurrences(of: "&uuml;", with: "ü")
            rmvText = rmvText.replacingOccurrences(of: "&yuml;", with: "ÿ")

            
            
            
            let components = rmvText.components(separatedBy: "Twitter:")
            if components.count > 1 {
                rmvText = components[1]
            }
            
            return rmvText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
}

//MARK: - Array
extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}


//MARK: - UISearchBarViewController
extension UISearchController {
    
    public func preferredStatusBarStyle() -> UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
}


extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 51)
    }
}


//MARK: - Bundle
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}


extension UIColor {
    
    func lighter(by percentage: CGFloat = 10.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 10.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 10.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
    
    var inverted: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        UIColor.red.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a)
    }
    
    class func hexString(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
