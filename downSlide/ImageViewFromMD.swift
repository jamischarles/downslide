//
//  ImageViewFromMD.swift
//  downSlide
//
//  Created by Charles, Jamis on 11/15/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

import Cocoa

class ImageViewFromMD: NSImageView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        // override what is drawn
        
        // FALLBACK IMAGE!!!!
        // Q:? can we just draw a square box?
        
        // all we need is size, since somewhere else we set the imageView bg to red and size.
        // w/o this, it doesn't show.
        let fallbackImage = NSImage(size: NSMakeSize( 300, 300 ))
        
        if self.image == nil {
            
            //self.image = NSImage(named: NSImage.Name(rawValue: "patreon.png"))
            self.image = fallbackImage
        }
    }
    
}


