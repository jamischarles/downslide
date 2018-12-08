//
//  ImageViewFromMD.swift
//  downSlide
//
//  Created by Charles, Jamis on 11/15/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

import Cocoa
import Foundation

class ImageViewFromMD: NSImageView {
    
   
    
    // similar to viewDidLoad
    override func awakeFromNib() {
        // Scaling : .scaleNone mandatory
       // if scaleAspectFill { self.imageScaling = .scaleNone }
    }

    
    override func draw(_ dirtyRect: NSRect) {
     
        
//        super.draw(dirtyRect)

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
        } else {
            
            // FIXME: should not happen on draw. gets called WAY WAY WAY too often
            
            // scale down the image so it doesn't take over the whole slide... (this can be default size...)
            // https://stackoverflow.com/questions/23002653/nsimageview-image-aspect-fill
            //self.imageScaling = .scaleAxesIndependently
//            self.imageScaling = .scaleProportionallyDown
//            self.frame = NSMakeRect(0, 0, 200, 200)
            //self.image = resizeImage(image: self.image!, maxSize: NSMakeSize(1024, 768))
        }
        
        
        // Draw AFTER resizing
        super.draw(dirtyRect)
        
        
    }
    
    // NOT using this code right now... it's dead code...
 
    // https://blog.alexseifert.com/2016/06/18/resize-an-nsimage-proportionately-in-swift/
    func resizeImage(image:NSImage, maxSize:NSSize) -> NSImage {
        var ratio:Float = 0.0
        let imageWidth = Float(image.size.width)
        let imageHeight = Float(image.size.height)
        let maxWidth = Float(maxSize.width)
        let maxHeight = Float(maxSize.height)
        
        // Get ratio (landscape or portrait)
        if (imageWidth > imageHeight) {
            // Landscape
            ratio = maxWidth / imageWidth;
        }
        else {
            // Portrait
            ratio = maxHeight / imageHeight;
        }
        
        // Calculate new size based on the ratio
        let newWidth = imageWidth * ratio
        let newHeight = imageHeight * ratio
        
        // Create a new NSSize object with the newly calculated size
        let newSize:NSSize = NSSize(width: Int(newWidth), height: Int(newHeight))
        
        // Cast the NSImage to a CGImage
        
        var imageRect:CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        
        // Create NSImage from the CGImage using the new size
        let imageWithNewSize = NSImage(cgImage: imageRef!, size: newSize)
        
        // Return the new image
        return imageWithNewSize
    }
    
}


