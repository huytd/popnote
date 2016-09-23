//
//  AppDelegate.swift
//  popnote
//
//  Created by Dataglance on 9/20/16.
//  Copyright © 2016 Huy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource {
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    let popover = NSPopover()
    var notes = [Note]()
    var currentEditContent: String = ""
    var currentSelectedTitle: String? = nil
    
    @IBOutlet var editor: EditorView!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var noteTableView: NSTableView!
    // MARK: - Pop Over
    
    func showPopup() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func hidePopup(sender: AnyObject) {
        popover.performClose(sender)
    }
    
    func onPopup(sender: AnyObject) {
        if popover.isShown {
            hidePopup(sender: sender)
        } else {
            showPopup()
        }
    }
    
    func showWindow(sender: AnyObject) {
        self.hidePopup(sender: sender)
        self.window.setIsVisible(true)
        self.editor.textStorage?.mutableString.setString(self.currentEditContent)
        self.editor.font = StyleKit.codeFont
        self.currentSelectedTitle = nil
        self.fillData()
    }
    
    // MARK: - Editting
    
    @IBAction func deleteDocument(sender: AnyObject) {
        if (self.currentSelectedTitle != nil) {
            if Note.delete(title: self.currentSelectedTitle!) {
                self.currentSelectedTitle = nil
                self.currentEditContent = ""
                self.editor.textStorage?.mutableString.setString("")
                self.fillData()
            }
        }
    }
    
    @IBAction func saveDocument(sender: AnyObject) {
        if (self.currentSelectedTitle == nil) {
            let a = NSAlert()
            a.messageText = "Enter note title:"
            a.addButton(withTitle: "Save")
            a.addButton(withTitle: "Cancel")
            
            let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            inputTextField.placeholderString = "Your note title here"
            a.accessoryView = inputTextField
            
            a.beginSheetModal(for: self.window!, completionHandler: { (modalResponse) -> Void in
                if modalResponse == NSAlertFirstButtonReturn {
                    let noteTitle = inputTextField.stringValue
                    var content = self.currentEditContent
                    if (self.currentEditContent.characters.count == 0) {
                        content = (self.editor.textStorage?.string)!
                    }
                    if Note.create(title: noteTitle, content: content) {
                        if self.popover.isShown {
                            self.currentEditContent = ""
                            self.showWindow(sender: sender)
                        } else {
                            self.selectNote(title: noteTitle)
                            self.fillData()
                        }
                    }
                }
            })
        } else {
            let note = Note.getNote(title: self.currentSelectedTitle!)
            Note.create(title: (note?.title!)!, content: (self.editor.textStorage?.string)!)
        }
    }
    
    func selectNote(title: String) {
        self.currentSelectedTitle = title
        self.currentEditContent = (Note.getNote(title: title)?.content!)!
        self.editor.textStorage?.mutableString.setString(self.currentEditContent)
        self.editor.font = StyleKit.codeFont
    }
    
    // MARK: - Table View
    
    func fillData() {
        self.notes = Note.getAll()
        self.noteTableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = self.notes[row]
        let cell = tableView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        cell.textField?.stringValue = item.title!
        return cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.notes.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if self.noteTableView.selectedRow != -1 {
            self.selectNote(title: self.notes[self.noteTableView.selectedRow].title!)
        } else {
            self.currentSelectedTitle = nil
            self.currentEditContent = ""
            self.editor.textStorage?.mutableString.setString("")
        }
    }
    
    // MARK: - App Delegate
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "desktop-monitor")
            button.action = #selector(onPopup)
        }
        
        popover.contentViewController = PopupEditor(nibName: "PopupEditor", bundle: nil)
        
        self.noteTableView.delegate = self
        self.noteTableView.dataSource = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: Foundation.URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent("com.huy.popnote")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "popnote", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = FileManager.default
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        do {
            let properties = try self.applicationDocumentsDirectory.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            if !properties.isDirectory! {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch  {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("popnote.storedata")
            do {
                try coordinator!.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                 
                /*
                 Typical reasons for an error here include:
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            if let error = failError {
                NSApplication.shared().presentError(error)
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
            fatalError("Unsresolved error: \(failureReason)")
        } else {
            return coordinator!
        }
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSApplication.shared().presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !managedObjectContext.hasChanges {
            return .terminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

