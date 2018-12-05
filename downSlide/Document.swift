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
    
    //var fw: FileWrapper = FileWrapper(
    
    var isUntitledDoc = true
    //v​a​r​ slides​:​ ​[NSView]​ ​=​ ​[​]
    // make all the slides here...
    // TODO: Use Slide Class? Any point in doing that?
    var slides: [NSView] = []
    
    
    
    
    var fileContent = "Nothing yet :("
    
    

    override init() {
        
        // Add your subclass-specific initialization here.
        super.init()
        
       
        
        
        
        
        
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
        slides = getSlidesFromContentString(rawString: fileContent, docUrl: self.fileURL!)
        Swift.print("after read slides.count", slides.count)
        //let s =
        
        let fw:FileWrapper
        
        do {
            fw = try fileWrapper(ofType: self.fileType!)
            //fileWrapper(dat)
        } catch {
            Swift.print("#### failed")
            //return results
        }
        
        Swift.print("### file read\n")
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        
        //self.fw = try self.fileWrapper(ofType: self.fileType!)
        
        //self.fileWrapper(data(ofType: <#T##String#>))
    }

    
    
    // called more often than expected, so we should run a diff on the reloading...
    // https://stackoverflow.com/questions/20586652/detect-overwritten-file-using-nsdocument
    
    override func presentedItemDidChange() {
        Swift.print("FILE WAS CHANGED")
       

        // move the slide updating to the main thread (since we cannot update UI elements on bg thread).
        // helps avoid weird bugs!!!
        DispatchQueue.main.async {
            self.getNewestSlidesFromContentAndNotify()
        }
 
        
    }
    
    // FIXME: Change name to something better...
    func getNewestSlidesFromContentAndNotify() {
        readDataFromFile(anURL: self.fileURL!)
        // what is this actually doing?!? Where is the content being updated?!?
        //readDataFromFile(anURL: URL(string: "file:///Users/jacharles/Dropbox/dev/mac_playground/downSlide/testing2.md")!)
        
        
        
        Swift.print("###self.fileURL", self.fileURL)
        
        
        if let vc = self.windowControllers[0].contentViewController as? NSSplitViewController {
            let thumb = vc.childViewControllers[0] as? ThumbViewController
            thumb?.slidesHaveUpdated()
            //return vc.textView.string.data(using: String.Encoding.utf8) ?? Data()
        }
        else {
            //return Data()
        }
    }
    
    //override func readFromData:ofType:error:
    
    // FIXME: Where do we put the parsing logic? Maybe make a slideParsing class? Yes I think so!!!
    
    
    func getFileContent() -> String {
        return self.fileContent
    }
    
    // pass in the url, and return the new content string
    // TODO: add logic for checking if the string has changed
    // TODO: add logic for checking lastModificationData so we aren't calling this unnecessarily often
    func readDataFromFile(anURL: URL) -> Data {
     
        let aHandle:FileHandle
        let fileContents:Data
        
        
        do {
            aHandle = try FileHandle(forReadingFrom: anURL)
            fileContents = aHandle.readDataToEndOfFile() as Data
            let newContent = (try String(data: fileContents, encoding: .utf8))!
            
            Swift.print("###newContent", newContent)
            fileContent = newContent
            slides = getSlidesFromContentString(rawString: fileContent, docUrl: self.fileURL!) // generate new slides
            return fileContents;
        } catch  {
            Swift.print("ERROR", error)
            
            // FIXME: move this to a better place...
            // FIXME: set it so I don't have to do this every time...
            //NSOpenPanel().selectFolder
            askForProjectFolderPermissions()
        }
        
        
            // fileHandleForReadingFromURL:anURL error:nil];
        
    
        //if (aHandle) {
        
        //}
    
        return Data()
        
    }
    

}


//https://stackoverflow.com/questions/28008262/detailed-instruction-on-use-of-nsopenpanel/28015428
// extension to give permissions to find images in the folder...
// FIXME: select default..
//extension NSOpenPanel {
//    var selectFolder: URL? {
//        // accessory view?
//        accessoryView = NSTextField(string: "ACCESSORYVIEW")
//
//
//        // default one to select...
//        directoryURL = URL(string:"/Users/jacharles/Dropbox/dev/")
//
//        title = "Select Folder for me..."
//        message = "Downslide needs access to your project folder, so we import images etc..."
//        nameFieldLabel = "this is the nameFieldLabel"
//        prompt = "Grant permission to read/write to this folder."
//        allowsMultipleSelection = false
//        canChooseDirectories = true
//        canChooseFiles = false
//        canCreateDirectories = true
//        //allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
//        return runModal() == .OK ? urls.first : nil
//    }
//}

