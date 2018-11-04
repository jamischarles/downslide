//
//  Document.swift
//  downSlide
//
//  Created by Charles, Jamis on 10/31/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

// This is basically the master window controller
// it accesses the file, then creates a new window, and the main viewController from the storyboard
//

import Cocoa

class Document: NSDocument {
    
    var isUntitledDoc = true
    //v​a​r​ slides​:​ ​[NSView]​ ​=​ ​[​]
    // make all the slides here...
    // TODO: Use Slide Class? Any point in doing that?
    var slides: [NSView] = []
    
    
    var fileContent = "Nothing yet :("
    
    

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        let docWindow = "Document Window Controller"
        let defaultStartWindow = "Default Start Window Controller"
        
        var windowToUse = docWindow
        
        // load a different window if no file has been loaded...
        if isUntitledDoc == true {
            windowToUse = defaultStartWindow
        }
        
        Swift.print("### MAKING WINDOW CONTROLLER")
        
        Swift.print("isUntitleDoc", isUntitledDoc)
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(windowToUse)) as! NSWindowController
        self.addWindowController(windowController)
        
        // create reference to the textView inside the window we just created by opening the new file...
//        let vc = windowController.contentViewController as! NSSplitViewController
//        //vc.splitViewItems[0] = "testing 123" // assign dummy text for now, so we can change it later when content is read in...
//        
//        let thumb = vc.childViewControllers[0] as? ThumbViewController
//        
//        // SO HACKY, but for now we can reach in...
//        thumb?.changeFileContent(str: "IT WORKED SO HACkY BUT YES IT WORKED")
//        
 
        // Q: Why do we have to assign anything now?
    
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        
//        if let vc = self.windowControllers[0].contentViewController as? ViewController {
//            return vc.textView.string.data(using: String.Encoding.utf8) ?? Data()
//        }
//        else {
//            return Data()
//        }
        
        
        //Swift.print("file read")
        
        //return Data()
        
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        isUntitledDoc = false
        Swift.print("#### READING FILE")
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        
//        let splitController = self.windowControllers[0].contentViewController as? NSSplitViewController
//
//        if let vc = splitController?.childViewControllers[0] as? ThumbViewController {
//
//                       vc.populateStringFromFile(str: "string from file")
//                    }
//                    else {
//                        //return Data()
//                    }
        
        // TODO: move this to separate file?
        fileContent = (try String(data: data, encoding: .utf8))!
        slides = getSlidesFromContentString(rawString: fileContent)
        Swift.print("after read slides.count", slides.count)
        //let s =
        
        Swift.print("### file read\n")
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    
    // FIXME: Where do we put the parsing logic? Maybe make a slideParsing class? Yes I think so!!!
    
    
    func getFileContent() -> String {
        return self.fileContent
    }

}

