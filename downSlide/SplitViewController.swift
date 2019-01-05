//
//  ViewController.swift
//  downSlide
//
//  Created by Charles, Jamis on 10/31/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

import Cocoa

// FIXME: Rename splitViewContrller? FIXME: do we need the last two?
class SplitViewController: NSSplitViewController, NSWindowDelegate {
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.becomeFirstResponder()
        
        
        // Do any additional setup after loading the view.
        
//        guard let thumbController = self.childViewControllers[0] as? DetailViewController else { return }
//        guard let detailController = self.childViewControllers[1] as? DetailViewController else { return }
//
//
//        // NOT WORKING
//        let con = thumbController.view.widthAnchor.constraint(lessThanOrEqualToConstant: 400.0)
//        con.isActive = true
//        con.priority = NSLayoutConstraint.Priority(rawValue: 1000)
//
//
//        // NOT WORKING
//        let split = thumbController.parent as! NSSplitViewController
//        split.splitView(split.splitView, constrainMinCoordinate: CGFloat(200), ofSubviewAt: 0)
//        print("SPLIT", split.splitView(minPossiblePositionOfDivider(at: 0))
        
//        split.view.splitView(thumbController, constrainMinCoordinate: CGFloat(100.0), ofSubviewAt: 0)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    // FIXME: is this even being used? Remove?!?
    @IBAction func zoomClicked(_ sender: NSSegmentedControl) {
        // parent split controller view...
        // this class is for splitViewController, so detailviewController is a child of this
        
        // if cannot assign detail, bail
        guard let detailController = self.childViewControllers[1] as? DetailViewController else { return }
        
        if sender.selectedSegment == 0 {
            detailController.zoomIn()
        }
        
        if sender.selectedSegment == 1 {
            detailController.resetZoom()
        }
        
        if sender.selectedSegment == 2 {
            detailController.zoomOut()
        }
        
    }
    

    // called when we resize thet split view
    // Called VERY often... figure out a debounce method...
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        guard let thumbController = self.childViewControllers[0] as? ThumbViewController else { return }
        
        thumbController.splitViewHasResized()
    }
}
