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
    
    var currentZoom: CGFloat  = 0.25
    
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
       
        let viewToShowNext = generateDetailSlide(newView: newView)
//        let stack = viewToShowNext.subviews[0]
        scrollView.documentView = viewToShowNext
        
        
        
        
        addDropShadow(view: viewToShowNext)
        
        let stack = viewToShowNext.subviews[0] as! NSStackView
        
//        for (i,view) in stack.arrangedSubviews.enumerated() {
        
//            let length = stack.arrangedSubviews.count
//            let priority = Float(length - i) // highest priority for lowest items
            
//            for con in view.constraints {
//                con.priority = .init(rawValue: priority)
//            }
            
//        }
        
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
        slideView.widthAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
        slideView.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
        
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
    
    var originY: CGFloat = 0
    
    // constraints applied in here, will be used for detail, and for thumbnail for greater accuracy...
    func generateDetailSlide(newView:NSView) -> FlippedStackView {
        
        let rawStack = newView as! FlippedStackView
        rawStack.identifier = NSUserInterfaceItemIdentifier(rawValue: "RAWSTACK###")

//        rawStack.setFrameSize(NSMakeSize(200, 400)) // sets thumb window, but has no effect on detail constraint
        // ### THIS IS WHERE THE IMPORTANT STUFF IS HAPPENING
//        rawStack.heightAnchor.constraint(equalToConstant: 300.0).isActive = true
//        rawStack.widthAnchor.constraint(equalToConstant: 500.0).isActive = true
        
//        rawStack.heightAnchor.constraint(lessThanOrEqualToConstant: 1300.0).isActive = true
//        rawStack.widthAnchor.constraint(lessThanOrEqualToConstant: 1500.0).isActive = true
        
        
        // When it gets too big, the constraintst freak out...
        
        
        // this changes things, not sure if good or bad... bad bc it changes thumb from slide...
//        rawStack.setClippingResistancePriority(.fittingSizeCompression, for: .vertical)
//        rawStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        if (rawStack.frame.size.height > 768) {
            rawStack.heightAnchor.constraint(lessThanOrEqualToConstant: 768).isActive = true
        }
        
        rawStack.widthAnchor.constraint(lessThanOrEqualToConstant: 1024).isActive = true
        

//        rawStack.needsLayout = true
//        rawStack.display()
        Swift.print("needsLayout", rawStack.layoutGuides)
        
        for (i,view) in rawStack.arrangedSubviews.enumerated() {
//            Swift.print("### Frame", view.frame)
//            Swift.print("### Bounds", view.bounds)
//            view.widthAnchor.constraint(equalToConstant: 700.0)
            let length = rawStack.arrangedSubviews.count
            let priority = Float(length - i) // highest priority for lowest items
            // hide any beyond 4
        
//            view.setContentCompressionResistancePriority(.init(rawValue: priority * 1000), for: .vertical)
//            view.exerciseAmbiguityInLayout() // try this?!?
//            Swift.print("##constraint##", view.constraints)
//            view.constraints[0].priority = .init(rawValue: priority)
//            view.constraints[1].priority = .init(rawValue: priority)
//            Swift.print("priority", priority)
//            rawStack.setVisibilityPriority(.init(rawValue: priority), for: view)
            
            
        }

//        rawStack.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
//        rawStack.detachesHiddenViews = false
        Swift.print("detached", rawStack.detachedViews)
//        rawStack.setClippingResistancePriority(.init(rawValue: 1.0), for: .vertical)
        Swift.print("clippingResistance", rawStack.clippingResistancePriority(for: .vertical))
        
//                rawStack.layout()
//                rawStack.updateConstraints()
        rawStack.layoutSubtreeIfNeeded() // THIS is the magic property... Causing height to be calculated properly, and thus Y frameOrigin as well... tough tough tough
        
        let v = FlippedStackView(frame: NSMakeRect(0, 0, 1024.0, 768.0))
        v.addSubview(rawStack)
        
        
        

//        v.translatesAutoresizingMaskIntoConstraints = true
//        rawStack.translatesAutoresizingMaskIntoConstraints = true
//        v.heightAnchor.constraint(lessThanOrEqualToConstant: 768).isActive = true
//
        
        rawStack.wantsLayer = true
//        v.layer?.masksToBounds = true
        
        return v
        
        let stack = NSStackView()
        
        
        for view in rawStack.arrangedSubviews {
            stack.addArrangedSubview(view)
            // Q: Is this an intrinsic size issue bc it hasn't been rendered to screen yet?
//            view.setFrameOrigin(NSMakePoint(0, originY))
//            originY = originY + 200
            
        }
        
        
        // because we are using "replace" instead of addSubview() it doesn't keep just adding more sibling views that stack
        // on top of each other. It removes the prior one with the assumption that the detail page should only show 1 view
        // at a time...
        //        clipView.replaceSubview(subView, with: stack)
        
        // prep clipping boundaries for new view about to be inserted
        let viewToShowNext = FlippedView(frame: NSMakeRect(0, 0, 1024.0, 768.0))
        viewToShowNext.identifier = NSUserInterfaceItemIdentifier(rawValue: "viewToShowNext###")
        // overflow = hidden
        
        
        
        
        viewToShowNext.addSubview(stack)
        
        viewToShowNext.wantsLayer = true
        viewToShowNext.layer?.backgroundColor = NSColor.red.cgColor
        
        // PRINT the dimensions
        Swift.print("### Frame", viewToShowNext.frame)
        Swift.print("### Bounds", viewToShowNext.bounds)
        
        
        // ADD constraints?
        viewToShowNext.heightAnchor.constraint(equalToConstant: 700.0)
        stack.constraintsAffectingLayout(for: .vertical)
        viewToShowNext.translatesAutoresizingMaskIntoConstraints = false
        viewToShowNext.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        
        stack.frame = NSMakeRect(0, 0, 1024.0, 768.0)
        stack.bounds = NSMakeRect(0, 0, 1024.0, 768.0)
        Swift.print("### Stack Frame", stack.frame)
        Swift.print("### Stack Bounds", stack.bounds)
        
        Swift.print("## stack subviews", stack.arrangedSubviews)
        
//        return viewToShowNext
        
    }

    
}






