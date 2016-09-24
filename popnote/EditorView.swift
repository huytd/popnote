//
//  EditorView.swift
//  popnote
//
//  Created by Dataglance on 9/21/16.
//  Copyright © 2016 Huy. All rights reserved.
//

import Cocoa

class EditorView: NSTextView, NSTextViewDelegate, NSTextStorageDelegate {
    override func awakeFromNib() {
        self.delegate = self
        self.textStorage?.delegate = self
        self.font = StyleKit.codeFont
    }
    
    func lines(startWith: String) -> [NSRange]? {
        let text = self.textStorage?.string
        let lines = text?.components(separatedBy: "\n")
        var ranges = [NSRange]()
        for line in lines! {
            if (line.hasPrefix(startWith)) {
                let lineIndex = text?.range(of: line)?.lowerBound
                ranges.append(NSRange(location: (text?.distance(from: (text?.startIndex)!, to: lineIndex!))!, length: line.characters.count))
            }
        }
        return ranges
    }
    
    func lines(has: String) -> [NSRange]? {
        let text = self.textStorage?.string
        let lines = text?.components(separatedBy: "\n")
        var ranges = [NSRange]()
        for line in lines! {
            if (line.contains(has)) {
                let lineIndex = text?.range(of: line)?.lowerBound
                ranges.append(NSRange(location: (text?.distance(from: (text?.startIndex)!, to: lineIndex!))!, length: line.characters.count))
            }
        }
        return ranges
    }
    
    func matches(regex: String) -> [NSRange]? {
        let text = self.textStorage?.string
        let regex = try! NSRegularExpression(pattern: regex, options: [])
        var ranges = [NSRange]()
        let results = regex.matches(in: text!, options: [], range: NSRange(location: 0, length: (text?.characters.count)!))
        for result in results {
            ranges.append(result.range)
        }
        return ranges
    }
    
    func setBold(range: NSRange) {
        self.textStorage?.addAttribute(NSStrokeWidthAttributeName, value: -5, range: range)
    }
    
    func setNormal(range: NSRange) {
        self.textStorage?.removeAttribute(NSStrokeWidthAttributeName, range: range)
    }
    
    func setColor(range: NSRange, color: NSColor) {
        self.textStorage?.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
    }
    
    func setStrike(range: NSRange) {
        self.textStorage?.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: range)
    }
    
    func resetStyle(range: NSRange) {
        self.textStorage?.removeAttribute(NSForegroundColorAttributeName, range: range)
        self.textStorage?.removeAttribute(NSStrokeWidthAttributeName, range: range)
        self.textStorage?.removeAttribute(NSStrikethroughStyleAttributeName, range: range)
    }
    
    // MARK: - Text View
    override func didChangeText() {
        let appDelegate  = (NSApplication.shared().delegate as! AppDelegate)
        if appDelegate.currentSelectedTitle != nil {
            appDelegate.saveDocument(sender: nil)
        }
    }
    
    // MARK: - Text Storage
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        let content = textStorage.string
        (NSApplication.shared().delegate as! AppDelegate).currentEditContent = content
        let n = content.characters.count
        if (n > 0) {
            self.resetStyle(range: NSRange(location: 0, length: n))
            
            if let checkBoxesRanges = lines(has: " [x] ") {
                for checkBox in checkBoxesRanges {
                    self.setColor(range: checkBox, color: NSColor.markdownQuotes())
                    self.setStrike(range: checkBox)
                }
            }
            if let checkBoxesEmptyRanges = matches(regex: "\\s\\[\\s\\]\\s") {
                for checkBox in checkBoxesEmptyRanges {
                    self.setColor(range: checkBox, color: NSColor.markdownCode())
                }
            }
            
            if let headerRanges = lines(startWith: "#") {
                for header in headerRanges {
                    self.setColor(range: header, color: NSColor.markdownHeaders())
                    self.setBold(range: header)
                }
            }
            if let codeRanges = lines(startWith: "\t") {
                for code in codeRanges {
                    self.setColor(range: code, color: NSColor.markdownCode())
                }
            }
            if let quoteRanges = lines(startWith: ">") {
                for quote in quoteRanges {
                    self.setColor(range: quote, color: NSColor.markdownQuotes())
                }
            }
            if let inlineCodes = matches(regex: "`.*?`") {
                for code in inlineCodes {
                    self.setColor(range: code, color: NSColor.markdownCode())
                }
            }
            if let codeBlocks = matches(regex: "```[\\S\\s]*?```") {
                for code in codeBlocks {
                    self.setColor(range: code, color: NSColor.markdownCodeBlock())
                }
            }
            if let linkRanges = matches(regex: "!?\\[.*?\\]\\(.*?\\)") {
                for link in linkRanges {
                    self.setColor(range: link, color: NSColor.markdownLinks())
                }
            }
            if let boldRanges = matches(regex: "\\*\\*.*?\\*\\*") {
                for bold in boldRanges {
                    self.setBold(range: bold)
                }
            }
            if let strikeRanges = matches(regex: "~.*?~") {
                for strike in strikeRanges {
                    self.setStrike(range: strike)
                }
            }
            if let numberedRanges = matches(regex: "\\d+\\.[\\S\\s]*?") {
                for num in numberedRanges {
                    self.setColor(range: num, color: NSColor.markdownList())
                    self.setBold(range: num)
                }
            }
            if let dashListRanges = matches(regex: "-\\s[\\S\\s]*?") {
                for dash in dashListRanges {
                    self.setColor(range: dash, color: NSColor.markdownList())
                    self.setBold(range: dash)
                }
            }
        }
    }
}
