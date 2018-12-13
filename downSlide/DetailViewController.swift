//
//  DetailViewController.swift
//  31_master-detail-w-slide-switching
//
//  Created by Charles, Jamis on 10/26/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

import Cocoa

// needed because scrollView starts bottom left when zoomed out (lame. Expected to be top left).
// is this a nice way to define multiple classes in same file? Could be amazing...
// http://www.poweredbytim.co.uk/programming/nsscrollview-top-left-pinning-and-isflipped/
// https://stackoverflow.com/questions/11975434/nsscrollview-scrolltotop
class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

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
        let viewToShowNext = FlippedView(frame: NSMakeRect(0, 0, 1024.0, 768.0))
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
        // this forces the content to change size to fit this constraint. Do NOT set nsstackview height
        // via constraints. It needs to be set via the contents...
//        newView.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
        
//        applySlideConstraints(slideView: newView as! NSStackView, mainView: view)
        
        
        // manual constraints?
        newView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        newView.topAnchor.constraint(equalTo: (self.view.superview?.topAnchor)!).isActive = true
        

//        newView.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
//        mainView.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
        
        // makes no diff? Can't tell...
//        newView.setFrameSize(NSMakeSize(1024.0, 768.0))
        
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
    }
    
    // constraints we want applied as soon as the detail slide changes...
    // for most of these we constrain the slide's NSStackView to the parent detail view and the window
    // they have to be part of the view hierarchy tree in order to be applied correctly (in most cases)
    func applySlideConstraints(slideView:NSStackView, mainView: NSView) {
        
        
        
        slideView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        slideView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true // don't center it, and limit the width
        
        slideView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        //stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // set the width of the stackview container to 800 so things aren't cut off...
        slideView.widthAnchor.constraint(greaterThanOrEqualToConstant: 800).isActive = true
        slideView.heightAnchor.constraint(greaterThanOrEqualToConstant: 800).isActive = true
        
        /*
        
        
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
 
 */
 
    }
    
}


