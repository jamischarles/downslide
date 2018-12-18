//
//  ThumbViewController.swift
//  31_master-detail-w-slide-switching
//
//  Created by Charles, Jamis on 10/26/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

// For now, all the magic will happen here, then we'll copy it over...
// TODO: keep reading the Chapters in the book on SafariBooks. It'll tell me more about master/detail

import Cocoa

class ThumbViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    @IBOutlet var collectionView: NSCollectionView!
    
    
    
    // make all the slides here...
    var slides: [NSView] = []
    
    // TODO: make this a struct? and have an array of slide scrcts?
    var slideThumbs: [NSImage] = []
    
    // keep track of currently selected thumb so we can re-select it after reload due to file change
    var currentSelectedThumbs: Set<IndexPath>! // will only be one, but it's a set of selection
    

    
 
    // Hacky way to access the file data for now...
    // LATER: use bindings and fancy ways to do this. for now this hacky way works fine
    var document: Document {
        let oughtToBeDocument = view.window?.windowController?.document as? Document
        assert(oughtToBeDocument != nil, "Unable to find the document for this view controller.")
        return oughtToBeDocument!
    }
    
    // proper time to access the data in document... !!!! YES!!!
    //
    override func viewWillAppear() {
        
        // select the folder for image rights
        // FIXME: lazy load this later...
        //NSOpenPanel().selectFolder
        
        // FIXME: check if we have permissions already...
        loadSavedFolderAccessPermissions() // we'll need to check here and see if we have to ask for perms again
//        askForProjectFolderPermissions()
//        saveFolderAccessPermissions()
        
//        print("### VIEW WILL APPEAR")
//        print("document.slides", document.slides)
//        print("document.slides.count", document.slides.count)
//        print("document.fileContent", document.fileContent)
        slides = document.slides
        
        /*
        slides.append(makeFormattedView(title: "We just changed tables to divs"))
        slides.append(makeFormattedView(title: "Sweet 2nd slide!"))
        slides.append(makeFormattedView(title: "Noice! 3rd slide!!!"))
 */
        
        // generate thumbnails
        
        for slide in slides {
            slideThumbs.append(slide.image())
            //slideThumbs.append(slides[1].image())
        }
        
        // reload sidear data
        collectionView.reloadData()
    }
    
    func slidesHaveUpdated() {
        slides = document.slides
        
        // wipe out slide thumbs
        slideThumbs = []
        
        
        for slide in slides {
            slideThumbs.append(slide.image())
            //slideThumbs.append(slides[1].image())
        }
        
        // reload sidebar data
        collectionView.reloadData()
        
        // reload the currently active master slide (reload the same index)
        // TODO: get current active from controllerViewItem?
        
        /*
        guard let splitVC = self.parent as? NSSplitViewController else { return }
        if let detail = splitVC.childViewControllers[1] as? DetailViewController {
            detail.swapView(newView: slides[2] as NSView!)
        }
         */
        // FIXME BUG: change the scroll position to be dynamic to the prior selection
        // https://stackoverflow.com/questions/35207364/how-do-i-programmatically-select-an-object-and-have-that-object-show-as-selecte
        
        // reset selection in sidebar. Causing bugs right now...
        // TODO: fixme
        
        
        // if no slide is selected trying to get the selection back...
        // FIXME: SHould we just default to first slide?
        if currentSelectedThumbs == nil {
            return
        }
        
        collectionView.selectItems(at: currentSelectedThumbs, scrollPosition: NSCollectionView.ScrollPosition.top)
        
        //return
        // reload the currently displayed slide (if any? Maybe just force current selection)
        let currentSlideIndex = currentSelectedThumbs.first?.item // get currently selected index
        guard let splitVC = self.parent as? NSSplitViewController else { return }
        if let detail = splitVC.childViewControllers[1] as? DetailViewController {
            detail.swapView(newView: slides[currentSlideIndex!] as NSView)
        }
        
    }
    
    
    
    
    override func viewDidLoad() {
//        print("### ViewDidLoad")
        super.viewDidLoad()
//        print("### ViewDidLoad")
        
        
        
        //print("document content", document.getFileContent())
        // Do view setup here.
       
        /*
        slides.append(makeFormattedView(title: "We just changed tables to divs"))
        slides.append(makeFormattedView(title: "Sweet 2nd slide!"))
        slides.append(makeFormattedView(title: "Noice! 3rd slide!!!"))
 */
        
        

        
        //guard let splitVC = parent as? NSSplitViewController else { return }
        //let splitVC = parent as? NSSplitViewController
        
    
        
        // NOT WORKING :(
        /*
        var document: Document {
            let oughtToBeDocument = self.view.window?.windowController?.document as? Document
            assert(oughtToBeDocument != nil, "Unable to find the document for this view controller.")
            return oughtToBeDocument!
        }*/
        
        
        
        
        //print("document content", document.getFileContent())
        
    }
    

    // TODO: rethink if we should create objects here, or create a model that can be shared by the document and this?
    // READ this to figure that out...
    // https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/DocBasedAppProgrammingGuideForOSX/Designing/Designing.html
//    func populateStringFromFile(str: String) {
//        print("str inside the fn", str)
//    }
    
    
    // Q: How many rows?
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    // TODO: name it slidePhoto?
    // assign EACH collectionViewItem
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("SlideThumb"), for: indexPath)
        guard let slideItem = item as? SlideThumb else { return item }
        
        slideItem.view.wantsLayer = true
        slideItem.view.layer?.backgroundColor = NSColor.red.cgColor
        
        slideItem.index = indexPath
        let i = indexPath.item
        
        
        // slideItem.slideContent = slides[i] // we aren't using this...
        slideItem.imageView?.image = slideThumbs[i] // set image thumbnail
        
        
//        print("### CYCLE collectionView")
        
        
        
        // add constraints here?
        
        
        return slideItem
    }
    
    // WHEN SELECTION CHANGES swap out the view
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
//        print("item selected", indexPaths)
        guard let splitVC = parent as? NSSplitViewController else { return }
        if let detail = splitVC.childViewControllers[1] as? DetailViewController {
            //let item = indexPaths[0].item
//            print("indexes", collectionView.item(at: 1))
            let item = collectionView.item(at: 1) as? SlideThumb
            
            // TODO: selecetd from outlet
            
            let i = indexPaths.first?.item
//            print("i",i)
            //let newView = NSTextField(labelWithString: "new view Placeholder View") as NSView!
            
            detail.swapView(newView: slides[i!] as! NSView!)
            
            // save current selection indexPath (only need first, since we only allow 1 selection)
            currentSelectedThumbs = indexPaths
        }
    }
    
    // SET SIZE for collection view item
    /*
     func collectionView(
     _ collectionView: NSCollectionView,
     layout collectionViewLayout: NSCollectionViewLayout,
     sizeForItemAt indexPath: IndexPath
     ) -> NSSize {
     // Here we're telling that we want our cell width to
     // be equal to our collection view width
     // and height equals to 70
     // return CGSize(width: collectionView.bounds.width, height: 70)
     print("SET SIZE")
     // THIS FN is not being called...
     return CGSize(width: 400, height: 400)
     }*/
    
    
    
    
    
    func makeImageFromView() {
        
    }
    
    
    
    
    
}

extension NSView {
    
    /// Get `NSImage` representation of the view.
    ///
    /// - Returns: `NSImage` of view
    
    func image() -> NSImage {
        //self.draw(NSRect(x: 0, y: 0, width: 600, height: 600))
        
        // this resets the first slide view... interesting... because the new constraints haven't been applied yet...
        // https://stackoverflow.com/questions/36732958/how-to-move-or-resize-an-nsview-by-setting-the-frame-property
        // needed bc bounds are zero since it hasn't been rendered into the window yet...
        
        // FIXME: this should be set to the size of the slide (Use a constant size...)
        self.frame = NSRect(x: 0, y: 0, width: 1200, height: 1200) // THIS becomes the bounds...
        //self.translatesAutoresizingMaskIntoConstraints = true // this forces the constraints to be reset, but it's not strictly needed for our purposes. Mainly we need the frame to change so that bounds isn't 0!
        
        //self.setNeedsDisplay(NSRect(x: 0, y: 0, width: 200, height: 200))
        
        //self.display()
        
        /*
         self.display()
         self.setBoundsSize(NSSize(width: 200, height: 200))
         self.setFrameSize(NSSize(width: 200, height: 200))
         */
        
        //self.layer = CALayer(); self.wantsLayer = true
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
        
        
    }
    
}

// CHANGE DEFAULT SIZE for CollectionViewItem
// http://wavvel.com/posts/swift/macos/full-width-ns-collection-view-item/
extension ThumbViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: NSCollectionView,
        layout collectionViewLayout: NSCollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> NSSize {
//        print("request size")
        // Here we're telling that we want our cell width to
        // be equal to our collection view width
        // and height equals to 70
        // return CGSize(width: collectionView.bounds.width, height: 70)
        
        // FIXME: Use a method that is called when the dimensions change of the parent?
        //return CGSize(width: NSWidth(view.bounds), height: NSWidth(view.bounds))
        return CGSize(width: 150, height: 150)
    }
    
    // [self.collectionView setMaxItemSize:NSZeroSize];
}

