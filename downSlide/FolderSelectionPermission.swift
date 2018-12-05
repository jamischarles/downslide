//
//  FolderSelectionPermission.swift
//  downSlide
//
// Handles file access permissions for the project folder that the currently opened markdown file is in.
// This is needed primarily to access assets like images in the md file... (so we can access them, and continue
// using the sandbox app model).

// pulled mostly from https://stackoverflow.com/questions/47902995/read-and-write-permission-for-user-selected-folder-in-mac-os-app
//


// READING:
// https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/EnablingAppSandbox.html
// Ch on App Sandbox in Big Ranch Nerd book

//  Created by Charles, Jamis on 11/15/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

import Foundation
import Cocoa

var bookmarks = [URL: Data]()

// prompts user for folder selection popup
//https://stackoverflow.com/questions/47902995/read-and-write-permission-for-user-selected-folder-in-mac-os-app
func askForProjectFolderPermissions(){
    
    let panel = NSOpenPanel()
    // accessory view?
    panel.accessoryView = NSTextField(string: "ACCESSORYVIEW")
    
    
    // default one to select...
    panel.directoryURL = URL(string:"/Users/jacharles/Dropbox/dev/")
    
    panel.title = "Select Folder for me..."
    panel.message = "Downslide needs access to your project folder, so we import images etc..."
    panel.nameFieldLabel = "this is the nameFieldLabel"
    panel.prompt = "Grant permission to read/write to this folder."
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.canCreateDirectories = true
    //allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
    
    
    let result = panel.runModal()
    
    if result ==  .OK {
        if result.rawValue == NSApplication.ModalResponse.OK.rawValue
        {
            let url = panel.url
            storeFolderInBookmark(url: url!)
        }
    }
        
    
    
    
    
    //return panel.url!
}

// this should help restore permissions from previous session...? (bookmarks)
func loadSavedFolderAccessPermissions(){
    let path = getBookmarkPath()
    bookmarks = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! [URL: Data]
    for bookmark in bookmarks {
        restoreBookmark(bookmark)
    }
}

// save the user folder access premissions that were granted...
func saveFolderAccessPermissions() {
    let path = getBookmarkPath()
    NSKeyedArchiver.archiveRootObject(bookmarks, toFile: path)
}

// ############################
// PRIVATE FNs
// ############################
private func storeFolderInBookmark(url: URL){
    do {
        let data = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        bookmarks[url] = data
    } catch {
        Swift.print ("Error storing bookmarks")
    }
}

private func getBookmarkPath() -> String {
    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    url = url.appendingPathComponent("Bookmarks.dict")
    return url.path
}



private func restoreBookmark(_ bookmark: (key: URL, value: Data)){
    let restoredUrl: URL?
    var isStale = false
    
    Swift.print ("Restoring \(bookmark.key)")
    do{
        restoredUrl = try URL.init(resolvingBookmarkData: bookmark.value, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
    } catch {
        Swift.print ("Error restoring bookmarks")
        restoredUrl = nil
    }
    
    if let url = restoredUrl {
        if isStale {
            Swift.print ("URL is stale")
        } else {
            if !url.startAccessingSecurityScopedResource() {
                Swift.print ("Couldn't access: \(url.path)")
            }
        }
    }
    
}

