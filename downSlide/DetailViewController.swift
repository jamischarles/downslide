//
//  DetailViewController.swift
//  31_master-detail-w-slide-switching
//
//  Created by Charles, Jamis on 10/26/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

import Cocoa


class DetailViewController: NSViewController {
    
    var subView:NSView!
    
    @IBOutlet var scrollView: NSScrollView!
    
    @IBOutlet var mainView: NSView!
    @IBOutlet var clipView: NSClipView!
    
    override func viewDidLoad() {
        let someView = NSTextField(labelWithString: "Default Placeholder View") as NSView!
        super.viewDidLoad()
        // Do view setup here.
        
        
        
        scrollView.documentView = someView
        
        scrollView.magnification = 1.0 // default
        //clipView.addSubview(someView!)
//        subView = someView
    }
    
    // FIXME: make the swapping way more elegant...
    func swapView(newView:NSView) {
        // because we are using "replace" instead of addSubview() it doesn't keep just adding more sibling views that stack
        // on top of each other. It removes the prior one with the assumption that the detail page should only show 1 view
        // at a time...
//        clipView.replaceSubview(subView, with: newView)
        
        // prep clipping boundaries for new view about to be inserted
        let viewToShowNext = NSView(frame: NSMakeRect(0, 0, 1024.0, 768.0))
         // overflow = hidden
        
        viewToShowNext.addSubview(newView)
        
        
        scrollView.documentView = viewToShowNext
//        self.subView = newView
        
        // I assume it has to be in the View tree before I can apply these constraints...
        
        // set size of view...
        // Or bounds?
        mainView.setFrameSize(NSMakeSize(1024.0, 768.0)) // 4:3 Aspec Ratio (standard)
        mainView.setBoundsSize(NSMakeSize(1024.0, 768.0))
        
        newView.widthAnchor.constraint(greaterThanOrEqualToConstant: 1024).isActive = true
        newView.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
        
//        applySlideConstraints(slideView: subView as! NSStackView)
        
    }
    
    // constraints we want applied as soon as the detail slide changes...
    // for most of these we constrain the slide's NSStackView to the parent detail view and the window
    func applySlideConstraints(slideView:NSStackView) {
        
        
        // FIXME: Do we need to apply all the constraints and all these transformations when we show it only?
        
        // add these contraints after adding the stackview as a subview
        // make the stack view sit directly against all four edges
        slideView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        slideView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true // don't center it, and limit the width
        
        slideView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //slideView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // set the width of the stackview container to 800 so things aren't cut off...
        //slideView.widthAnchor.constraint(greaterThanOrEqualToConstant: 800).isActive = true
        
        // left/right padding 50%
        slideView.edgeInsets = NSEdgeInsets(top:200,left:NSWidth(view.bounds) / 2, bottom: 200,right:NSWidth(view.bounds) / 2)
    }
    
}


