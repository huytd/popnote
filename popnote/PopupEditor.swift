//
//  PopupEditor.swift
//  popnote
//
//  Created by Dataglance on 9/21/16.
//  Copyright © 2016 Huy. All rights reserved.
//

import Cocoa

class PopupEditor: NSViewController, NSTextStorageDelegate {

    @IBOutlet var textEditor: EditorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.wantsLayer = true
        self.textEditor.textStorage?.delegate = self
    }
    
    override func viewWillAppear() {
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        //box.layer?.setNeedsDisplay()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        (NSApplication.shared().delegate as! AppDelegate).currentEditContent = textStorage.string
    }
    
    @IBAction func openClick(_ sender: AnyObject) {
        (NSApplication.shared().delegate as! AppDelegate).showWindow(sender: sender)
        textEditor.textStorage?.mutableString.setString("")
    }
}
