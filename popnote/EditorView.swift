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
    
    func lines(with: String) -> [NSRange]? {
        let text = self.textStorage?.string
        let lines = text?.components(separatedBy: "\n")
        var ranges = [NSRange]()
        for line in lines! {
            if (line.hasPrefix(with)) {
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
    
    // MARK: - Text Storage
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        let content = textStorage.string
        let n = content.characters.count
        textStorage.removeAttribute(NSForegroundColorAttributeName, range: NSRange(location: 0, length: n))
        if (n > 0) {
            if let headerRanges = lines(with: "#") {
                for header in headerRanges {
                    textStorage.addAttribute(NSForegroundColorAttributeName, value: NSColor.markdownHeaders(), range: header)
                    textStorage.addAttribute(NSStrokeWidthAttributeName, value: -5, range: header)
                }
            }
            if let codeRanges = lines(with: "\t") {
                for code in codeRanges {
                    textStorage.addAttribute(NSForegroundColorAttributeName, value: NSColor.markdownCode(), range: code)
                }
            }
            if let quoteRanges = lines(with: ">") {
                for quote in quoteRanges {
                    textStorage.addAttribute(NSForegroundColorAttributeName, value: NSColor.markdownQuotes(), range: quote)
                }
            }
            if let inlineCodes = matches(regex: "`.*?`") {
                for code in inlineCodes {
                    textStorage.addAttribute(NSForegroundColorAttributeName, value: NSColor.markdownCode(), range: code)
                }
            }
            if let codeBlocks = matches(regex: "```[\\S\\s]*?```") {
                for code in codeBlocks {
                    textStorage.addAttribute(NSForegroundColorAttributeName, value: NSColor.markdownCodeBlock(), range: code)
                }
            }
            if let linkRanges = matches(regex: "!?\\[.*?\\]\\(.*?\\)") {
                for link in linkRanges {
                    textStorage.addAttribute(NSForegroundColorAttributeName, value: NSColor.markdownLinks(), range: link)
                }
            }
            if let boldRanges = matches(regex: "\\*\\*.*?\\*\\*") {
                for bold in boldRanges {
                    textStorage.addAttribute(NSStrokeWidthAttributeName, value: -5, range: bold)
                }
            }
            if let strikeRanges = matches(regex: "~.*?~") {
                for strike in strikeRanges {
                    textStorage.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: strike)
                }
            }
            if let numberedRanges = matches(regex: "\\d+\\.[\\S\\s]*?") {
                for num in numberedRanges {
                    textStorage.addAttribute(NSForegroundColorAttributeName, value: NSColor.markdownList(), range: num)
                    textStorage.addAttribute(NSStrokeWidthAttributeName, value: -5, range: num)
                }
            }
        }
    }
}
