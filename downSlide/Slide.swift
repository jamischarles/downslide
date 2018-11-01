//
//  Slide.swift
//  31_master-detail-w-slide-switching
//
//  Created by Charles, Jamis on 10/29/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

import Cocoa

class Slide: NSCollectionViewItem {
    
    let selectedBorderThickness: CGFloat = 3
    var index: IndexPath = [0,0]
    
    // should we init it here?
    var slideContent: NSView = NSView()
    var slideThumbnail: NSImage = NSImage()
    
    // TODO: store the slide content here, or have a separate thing for it?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.blue.cgColor
        
        
        // has no effect...
        //view.widthAnchor.constraint(greaterThanOrEqualToConstant: 800).isActive = true
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                view.layer?.borderWidth = selectedBorderThickness
            } else {
                view.layer?.borderWidth = 0
            }
            
            print("selected index", self.index)
        }
        
        
    }
    
    
    
}

