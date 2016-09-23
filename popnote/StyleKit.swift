//
//  StyleKit.swift
//  popnote
//
//  Created by Dataglance on 9/21/16.
//  Copyright © 2016 Huy. All rights reserved.
//

import Cocoa

class StyleKit {
    static let codeFont = NSFont(name: "Menlo", size: 14.0)
    static let codeItalicFont = NSFont(name: "Menlo-Italic", size: 14.0)
}

extension NSColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    // Headers
    class func markdownHeaders() -> NSColor {
        return NSColor(hex: 0x3F51B5)
    }
    
    // Bold
    
    // Italic
    
    // List
    class func markdownList() -> NSColor {
        return NSColor(hex: 0x689F38)
    }
    
    // Strikethrough
    
    // Link
    class func markdownLinks() -> NSColor {
        return NSColor(hex: 0xc0392b)
    }
    
    // Code
    class func markdownCode() -> NSColor {
        return NSColor(hex: 0xe67e22)
    }
    
    class func markdownCodeBlock() -> NSColor {
        return NSColor(hex: 0x9b59b6)
    }
    
    // Quotes
    class func markdownQuotes() -> NSColor {
        return NSColor(hex: 0x7f8c8d)
    }
    
}
