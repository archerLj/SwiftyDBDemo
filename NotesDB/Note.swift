//
//  Note.swift
//  NotesDB
//
//  Created by Gabriel Theodoropoulos on 2/20/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import SwiftyDB

// 使用SwiftyDB进行存储的对象必须继承自NSObject, 遵循Storable协议(a SwiftyDB protocol)
// 遵循了Storable协议的类必须实现init方法
//**** SwiftyDB doesn't store collections to the database
class Note: NSObject, Storable {
    
    override required init() {
        super.init()
    }
    
    let database: SwiftyDB! = SwiftyDB(databaseName: "notes") //实例化对象的时候，会创建一个notes.sqlite的数据库，如果已经存在了，那么就会直接打开。
    var noteID: NSNumber!
    var title: String!
    var text: String!
    var textColor: NSData!
    var fontName: String!
    var fontSize: NSNumber!
    var creationDate: NSDate!
    var modificationDate: NSDate!
    var images: [ImageDescriptor]! //doesn't store collections to the database, 所以images永远不会被存储,所以才用NSData.
    var imagesData: NSData!
    
    func storeNoteImagesFromImageViews(imageViews: [PanningImageView]) {
        if imageViews.count > 0 {
            if images == nil {
                images = [ImageDescriptor]()
            } else {
                images.removeAll()
            }
            for i in 0..<imageViews.count {
                let imageView = imageViews[i]
                let imageName = "img_\(Int(NSDate().timeIntervalSince1970))_\(i)"
                images.append(ImageDescriptor(frameData: imageView.frame.toNSData(), imageName: imageName))
                Helper.saveImage(imageView.image!, withName: imageName)
            }
            imagesData = NSKeyedArchiver.archivedDataWithRootObject(images)
        } else {
            imagesData = NSKeyedArchiver.archivedDataWithRootObject(NSNull()) //“nil” is not recognized by SQLite. What SQLite understands is the equivalent of NSNull, and that’s what we provide converted to a NSData object.
        }
    }
    
    // SwiftyDB 提供两种操作方式：同步和异步
    func saveNote(shouldUpdate: Bool = false, completionHandler: (success: Bool) -> Void) {
        database.asyncAddObject(self, update: shouldUpdate) { (result) -> Void in
            if let error = result.error {
                print(error)
                completionHandler(success: false)
            }
            else {
                completionHandler(success: true)
            }
        }
    }
    
    // load notes form database.
    func loadAllNotes(completionHandler: (notes: [Note]!) -> Void) {
        database.asyncObjectsForType(Note.self) { (result) -> Void in
            if let notes = result.value {
                completionHandler(notes: notes)
            }
            
            if let error = result.error {
                print(error)
                completionHandler(notes: nil)
            }
        }
    }
    
    // retrieve just  a single note form dataBase.
    func loadSingleNoteWithID(id: Int, completionHandler: (note: Note!) -> Void) {
        database.asyncObjectsForType(Note.self, matchingFilter: Filter.equal("noteID", value: id)) { (result) -> Void in
            if let notes = result.value {
                let singleNote = notes[0]
                
                if singleNote.imagesData != nil {
                    singleNote.images = NSKeyedUnarchiver.unarchiveObjectWithData(singleNote.imagesData) as? [ImageDescriptor]
                }
                
                completionHandler(note: singleNote)
            }
            
            if let error = result.error {
                print(error)
                completionHandler(note: nil)
            }
        }
    }
    
    // delete note
    func deleteNote(completionHandler: (success: Bool) -> Void) {
        let filter = Filter.equal("noteID", value: noteID)
        
        database.asyncDeleteObjectsForType(Note.self, matchingFilter: filter) { (result) -> Void in
            if let deleteOK = result.value {
                completionHandler(success: deleteOK)
            }
            
            if let error = result.error {
                print(error)
                completionHandler(success: false)
            }
        }
    }
}

//a class can be archived (in other languages also known as serialized) if only all of its properties can be serialised too
class ImageDescriptor: NSObject, NSCoding {
    var frameData: NSData! // 这里不是存储CGRect
    var imageName: String!
    
    init(frameData: NSData!, imageName: String!) {
        super.init()
        self.frameData = frameData
        self.imageName = imageName
    }
    
    required init?(coder aDecoder: NSCoder) {
        frameData = aDecoder.decodeObjectForKey("frameData") as! NSData
        imageName = aDecoder.decodeObjectForKey("imageName") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(frameData, forKey: "frameData")
        aCoder.encodeObject(imageName, forKey: "imageName")
    }
}

