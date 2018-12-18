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


// center the content of the scrollview
// https://stackoverflow.com/questions/22072105/how-do-you-get-nsscrollview-to-center-the-document-view-in-10-9-and-later
class CenteredClipView:NSClipView{
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        
        var rect = super.constrainBoundsRect(proposedBounds)
        if let containerView = self.documentView {
            
            if (rect.size.width > containerView.frame.size.width) {
                rect.origin.x = (containerView.frame.width - rect.width) / 2
            }
            
            if(rect.size.height > containerView.frame.size.height) {
                rect.origin.y = (containerView.frame.height - rect.height) / 2
            }
        }
        
        return rect
    }
}

class DetailViewController: NSViewController, NSWindowDelegate {
    
    var currentZoom: CGFloat  = 1.0
    
    var subView:NSView!
    
    @IBOutlet var scrollView: NSScrollView!
    
    @IBOutlet var mainView: NSView!
    @IBOutlet var clipView: NSClipView!
    
    
    override func viewDidLoad() {
        let someView = NSTextField(labelWithString: "Default Placeholder View") as NSView!
        super.viewDidLoad()
        // Do view setup here.
        
        
        
        // set bg color for scrollview
//        https://stackoverflow.com/questions/42778317/how-to-color-the-overshoot-background-of-an-nscollectionview/42817222
        scrollView.contentView.backgroundColor = NSColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        scrollView.drawsBackground = true
        
        // set scrollView content
        scrollView.documentView = someView
        addDropShadow(view: someView!)
        
        scrollView.magnification = currentZoom // default
        //clipView.addSubview(someView!)
//        subView = someView
    }
    
    // FIXME: make the swapping way more elegant...
    func swapView(newView:NSView) {
        
        let stack = newView as! FlippedStackView
        
        
        // because we are using "replace" instead of addSubview() it doesn't keep just adding more sibling views that stack
        // on top of each other. It removes the prior one with the assumption that the detail page should only show 1 view
        // at a time...
//        clipView.replaceSubview(subView, with: stack)
        
        // prep clipping boundaries for new view about to be inserted
        let viewToShowNext = FlippedView(frame: NSMakeRect(0, 0, 1024.0, 768.0))
         // overflow = hidden
        
        viewToShowNext.addSubview(stack)
        
        viewToShowNext.wantsLayer = true
        viewToShowNext.layer?.backgroundColor = NSColor.red.cgColor
        
        
        
        scrollView.documentView = viewToShowNext
        
        
        addDropShadow(view: viewToShowNext)
//        self.subView = stack
        
        // I assume it has to be in the View tree before I can apply these constraints...
        
        // set size of view...
        // Or bounds?
        mainView.setFrameSize(NSMakeSize(1024.0, 768.0)) // 4:3 Aspec Ratio (standard)
        mainView.setBoundsSize(NSMakeSize(1024.0, 768.0))
        
        stack.widthAnchor.constraint(greaterThanOrEqualToConstant: 1024).isActive = true
        // this forces the content to change size to fit this constraint. Do NOT set nsstackview height
        // via constraints. It needs to be set via the contents...
//        stack.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
        
        // limit height to 768 (so slide clips thet stackView
        stack.heightAnchor.constraint(lessThanOrEqualToConstant: 768).isActive = true
        
//        applySlideConstraints(slideView: stack as! NSStackView, mainView: view)
        
        
        // manual constraints?
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: (self.view.superview?.topAnchor)!).isActive = true
        

//        stack.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
//        mainView.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
        
        // makes no diff? Can't tell...
//        stack.setFrameSize(NSMakeSize(1024.0, 768.0))
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        
        // causes clipping, but order still wrong
//        stack.setClippingResistancePriority(.required, for: .vertical)
        
        // right order, but stops clipping
//        stack.setClippingResistancePriority(.defaultHigh, for: .vertical)
        
//        stack.setContentCompressionResistancePriority(.required, for: .vertical) // no effect?
        
//        clipView.setFrameSize(NSMakeSize(1024.0, 768.0))
        
        
        // ensure that shrinking the stackView (if overflow) hides bottom items, not top items
        
//        var i = stack.arrangedSubviews.count
        
        /*
        var i = 1
        for view in stack.arrangedSubviews {
            stack.setVisibilityPriority(.init(Float(i)), for: view)
            i = i+1
        }
 */
        
        // this is how you can hide a stackview item...
//        stack.setVisibilityPriority(.notVisible, for: stack.arrangedSubviews[stack.arrangedSubviews.count-1])
        
        // doesn't seem to help force showing...
//        stack.setVisibilityPriority(.mustHold, for: stack.arrangedSubviews[0])
//        i = i+1
        
        //(_ priority: NSStackView.VisibilityPriority,for view: NSView)
        
        
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
    
    // https://stackoverflow.com/questions/32859617/how-to-display-shadow-for-nsview
    func addDropShadow(view: NSView) {
        view.wantsLayer = true
        view.superview?.wantsLayer = true
        view.wantsLayer = true
        view.shadow = NSShadow()
        view.layer?.backgroundColor = NSColor.red.cgColor
        view.layer?.cornerRadius = 5.0
        view.layer?.shadowOpacity = 1.0
//        view.layer?.shadowColor = CGColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        view.layer?.shadowColor = NSColor.black.cgColor
        view.layer?.shadowOffset = NSMakeSize(0, 0)
        view.layer?.shadowRadius = 10
    }
    
    func zoomIn() {
        scrollView.magnification = currentZoom + 0.25
        currentZoom = scrollView.magnification
    }
    
    func zoomOut() {
        scrollView.magnification = currentZoom - 0.25
        currentZoom = scrollView.magnification
    }
    
    func resetZoom() {
        scrollView.magnification = 1.0
        currentZoom = scrollView.magnification
    }

    
}






