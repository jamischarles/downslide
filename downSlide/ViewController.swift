//
//  ViewController.swift
//  downSlide
//
//  Created by Charles, Jamis on 10/31/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

import Cocoa

class ViewController: NSSplitViewController, NSWindowDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
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

}
