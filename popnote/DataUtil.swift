//
//  DataUtil.swift
//  popnote
//
//  Created by Dataglance on 9/20/16.
//  Copyright © 2016 Huy. All rights reserved.
//

import Foundation
import CoreData
import Cocoa

extension Note {
    class func getAll() -> [Note] {
        let context = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        let fetched = try! context.fetch(fetchRequest)
        return fetched
    }
    
    class func getNote(title: String) -> Note? {
        let context = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "title==%@", title)
        let fetched = try! context.fetch(fetchRequest)
        return fetched.first
    }
    
    class func create(title: String, content: String) -> Bool {
        let context = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let currentNote = getNote(title: title)
        if (currentNote == nil) {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
            note.title = title
            note.content = content
            note.date = Date() as NSDate?
        } else {
            currentNote!.content = content
        }
        do {
            try context.save()
            return true
        } catch {
            print("Error saving data")
            return false
        }
    }
    
    class func delete(title: String) -> Bool {
        let context = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "title==%@", title)
        let fetched = try! context.fetch(fetchRequest)
        
        for note in fetched {
            context.delete(note)
        }
        
        try! context.save()
        
        return true
    }
}
