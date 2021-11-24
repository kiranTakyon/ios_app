//
//  Extensions.swift
//  Ambassador Education
//
//  Created by    Kp on 22/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation
import UIKit
import DGActivityIndicatorView
import CommonCrypto

extension UIViewController{
    
    func startLoadingAnimation(){
        
        
        let activityView = UIView()
        let screenRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 60)//CGRect(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height + 60)//UIScreen.mainScreen().bounds
        activityView.backgroundColor = UIColor.gray
        activityView.tag = 1000001
        self.view.addSubview(activityView)
        activityView.frame = CGRect(x: 0,y: 0,  width:screenRect.width,  height: screenRect.height)

        
        let colors = Colors()
        activityView.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer?.frame = activityView.frame
        activityView.layer.insertSublayer(backgroundLayer!, at: 0)
        
        let activityIndicator = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.lineScale, tintColor: UIColor.white, size: 40.00)
        
        
        let xVal = UIScreen.main.bounds.width/2 - 25
        let yVal = UIScreen.main.bounds.height/2 - 25
        
        activityIndicator?.frame = CGRect(x: xVal, y: yVal, width: 50, height: 50)
        activityIndicator?.tag = 100000
        activityIndicator?.startAnimating()
        activityView.addSubview(activityIndicator!)
        
        self.view.addSubview(activityView)
        
    }
    
    
    func stopLoadingAnimation(){
        if let activity = self.view.viewWithTag(100000) as? DGActivityIndicatorView{
            activity.stopAnimating()
            activity.removeFromSuperview()
        }
        
        if let activityView = self.view.viewWithTag(1000001){
            activityView.removeFromSuperview()
        }
    }
}


class Colors {
    var gl:CAGradientLayer!
    
    init() {
        let colorTop = UIColor.appOrangeColor().cgColor////UIColor(red:  169.0 / 255.0, green: 2.0 / 255.0, blue: 0, alpha:1).cgColor//UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom =  UIColor(red: 1, green:1 , blue: 1, alpha: 1).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}


extension UIColor{
    
    class func appOrangeColor() -> UIColor
    {
        return UIColor.colorFromHEX(hexValue: 0xE9503B)
    }
    
    class func appLightGrey() -> UIColor
    {
        return UIColor.colorFromHEX(hexValue: 0xf5f5f5)
    }
    
    
    
    class func appBlueColor() -> UIColor{
        
        return UIColor.colorFromHEX(hexValue: 0x0A1971)
    }
    class func colorFromHEX(hexValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hexValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    
    var byWords: [String] {
        var byWords:[String] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: .byWords) {
            guard let word = $0 else { return }
            print($1,$2,$3)
            byWords.append(word)
        }
        return byWords
    }
    func firstWords(_ max: Int) -> [String] {
        return Array(byWords.prefix(max))
    }
    var firstWord: String {
        return byWords.first ?? ""
    }
    func lastWords(_ max: Int) -> [String] {
        return Array(byWords.suffix(max))
    }
    var lastWord: String {
        return byWords.last ?? ""
    }
}

extension String {
    
    var htmlToAttributedString: NSAttributedString? {
        
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    // extension String {
    var replacingHTMLEntities: String? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
                ], documentAttributes: nil).string
        } catch {
            return nil
        }
    }
}

extension NSAttributedString {
    
    public convenience init?(HTMLString html: String, font: UIFont? = nil) throws {
        
        let options: [String: Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue)
        ]
        
        guard let data = html.data(using: .utf8, allowLossyConversion: true) else {
            throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
        }
        
        
        if let font = font {
            guard let attr = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
                throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
            }
            var attrs = attr.attributes(at: 0, effectiveRange: nil)
            attrs[NSFontAttributeName] = font
            attr.setAttributes(attrs, range: NSRange(location: 0, length: attr.length))
            self.init(attributedString: attr)
        } else {
            try? self.init(data: data, options: options, documentAttributes: nil)
        }
        
    }
    
}


let imageCache = NSCache<AnyObject, AnyObject>()

class ImageLoader : UIImageView {
    
    var imageURLString : String?
    
    let activityIndicator = UIActivityIndicatorView()
    
    func loadImageWithUrl(_ urlString : String){
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(red:0.97, green:0.70, blue:0.06, alpha:1.0)
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        imageURLString = urlString
        
        if let url = URL(string: urlString) {
            
            image = nil
            activityIndicator.startAnimating()
            
            if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
                
                self.image = imageFromCache
                activityIndicator.stopAnimating()
                return
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                if error != nil{
                    print(error as Any)
                    
                    DispatchQueue.main.async(execute: {
                        
                        self.activityIndicator.stopAnimating()
                         self.image = UIImage(named:"Default")
                    })
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    
                    if let imgaeToCache = UIImage(data: data!){
                        
                        if self.imageURLString == urlString {
                            self.image = imgaeToCache
                        }
                        
                        self.activityIndicator.stopAnimating()
                        imageCache.setObject(imgaeToCache, forKey: urlString as AnyObject)
                    }else{
                        self.image = UIImage(named:"UserDefault")
                        self.activityIndicator.stopAnimating()


                    }
                })
            }) .resume()
        }else{
            
            self.image = UIImage(named:"Default")
        }
    }
}

extension String {
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}


extension UIViewController{
    
    func addNoDataFoundLabel(textValue:String = "No Items availble")  {
        
        DispatchQueue.main.async {
            func getString()->String{
                var str = ""
                    str = textValue //"No items available"
                return str
            }
            
            if let label = self.view.viewWithTag(8001) as? UILabel{
                label.text = getString()
            }
            else{
                
                
                let frame = CGRect(x: 0, y: 0, width: 210, height: 50)//CGRectMake(0, 0, self.view.bounds.size.width, 50)
                let label = UILabel(frame: frame)
                label.text = getString()
               
                label.numberOfLines = 0
                    label.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 80)//self.view.center + 50
                
                label.tag = 8001
                label.textColor = UIColor.appBlueColor()
                label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                label.textAlignment = .center
                label.alpha = 0.5
                
               
                
                self.view.addSubview(label)
                
                let imageFrame = CGRect(x: self.view.center.x - 50, y: label.center.y - 110, width: 100, height: 100)
                let imageLogo = UIImageView(frame: imageFrame)
                imageLogo.alpha = 0.5
                label.tag = 8002
                imageLogo.image = UIImage(named:"TakyonLogo")
                
                self.view.addSubview(imageLogo)
            }
        }
    }
    
    func removeNoDataLabel(){
        
        if let label = self.view.viewWithTag(8001) as? UILabel{
            label.removeFromSuperview()
        }
        
        if let imageView = self.view.viewWithTag(8002) as? UIImageView{
            imageView.removeFromSuperview()
        }
    }

}



//    var utf8Data: Data? {
//    return data(using: .utf8 )
//}
		// faqTextView.attributedText = contObj.license.utf8Data?.attributedString


public enum ImageFormat {
    case png
    case jpeg(CGFloat)
}

extension UIImage {
    
    public func base64(format: ImageFormat) -> String? {
        var imageData: Data?
        switch format {
        case .png: imageData = UIImagePNGRepresentation(self)
        case .jpeg(let compression): imageData = UIImageJPEGRepresentation(self, compression)
        }
        return imageData?.base64EncodedString()
    }
}


extension Data {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options :[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}


extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}

public extension Sequence where Iterator.Element: Hashable {
    var uniqueElements: [Iterator.Element] {
        return Array( Set(self) )
    }
}
public extension Sequence where Iterator.Element: Equatable {
    var uniqueElements: [Iterator.Element] {
        return self.reduce([]){
            uniqueElements, element in
            
            uniqueElements.contains(element)
                ? uniqueElements
                : uniqueElements + [element]
        }
    }
}

extension String {
    func md5() -> String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deinitialize()
        
        return String(format: hash as String)
    }
}

extension String {
    func toFloat() -> Float? {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.floatValue
    }
    
    func toDouble() -> Double {
        let numberFormatter = NumberFormatter()
        if let value = numberFormatter.number(from: self)?.doubleValue{
           return value
        }
        return 0.0 
    }
    
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

//MARK :- Optional String to its value
protocol StringProtocol {
    var asString: String { get }
}

extension StringProtocol {
    var asString: String { return self as! String }
}

extension String: StringProtocol { }

extension Optional where Wrapped : StringProtocol {
    
    var safeValue: String {
        if case let .some(value) = self {
            return value.asString
        }
        return ""
    }
    
    var safeValueForNA: String {
        if case let .some(value) = self {
            return value.asString
        }
        return ""
    }
    
}

//MARK :- Optional Int to its value
protocol IntProtocol{
    var asInt: Int{get}
}

extension IntProtocol {
    var asInt: Int { return self as! Int }
}

extension Int: IntProtocol { }

extension Optional where Wrapped : IntProtocol {
    
    var safeValueOfInt: Int {
        if case let .some(value) = self {
            return value.asInt
        }
        return 0
    }
}
