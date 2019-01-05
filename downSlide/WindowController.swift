//
//  WindowController.swift
//  downSlide
//
//  Created by Charles, Jamis on 1/4/19.
//  Copyright © 2019 Charles, Jamis. All rights reserved.
//

import Cocoa

// for the split window... not the normal one...
class WindowController: NSWindowController {
    
    var isPresenting = false
    
    var splitViewController: SplitViewController! // fixes no init errs

    override func windowDidLoad() {
        splitViewController = self.contentViewController as! SplitViewController
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // swallows events. Doesn't the beep :(
//        NSEvent.addLocalMonitorForEvents(matching: .keyUp) { (aEvent) -> NSEvent? in self.keyDown(with: aEvent)
//            return nil
//        }
        
    }
    
    
    
    // https://stackoverflow.com/questions/28158964/detecting-key-press-event-in-swift
    override func keyUp(with event: NSEvent){
        
        // FIXME: squelch the sound
        
        if isPresenting && event.keyCode == 53 {
//            guard let thumb = splitViewController.childViewControllers[0] as? ThumbViewController else { return }
            
            print("WINDOW ESCAPE")
            togglePresentationMode(self)
            // FIXME: consider only restoring selection if too sluggish
//            thumb.updateLeftRailImages() // will reload left rail, and restore selectiton
            
        } else {
            print("WINDOW FALL THROUGH")
        }
        
        super.keyUp(with: event) // FIXME: What does this do?
        
        
    }
    
    // hides top bar and left bar...
    @IBAction func togglePresentationMode(_ sender: Any) {
        self.window?.toggleToolbarShown(self) // hide toolbar
        splitViewController.toggleSidebar(self) // hide left thumbnail rail
        //        self.view.window?.titleVisibility = .hidden
        isPresenting = !isPresenting
    }

}
