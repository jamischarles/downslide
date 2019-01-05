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
import Foundation

class ThumbViewController: NSViewController, NSSplitViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: NSCollectionView!
    
    // placeholder closure so we can change it in viewDidLoad for debounced fn
    var splitViewHasResized = { print ("Told you I return nothing")}
    
    
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
    
    /**
     Wraps a function in a new function that will throttle the execution to once in every `delay` seconds.
     
     - Parameter delay: A `TimeInterval` specifying the number of seconds that needst to pass between each execution of `action`.
     - Parameter queue: The queue to perform the action on. Defaults to the main queue.
     - Parameter action: A function to throttle.
     
     - Returns: A new function that will only call `action` once every `delay` seconds, regardless of how often it is called.
     */
    func throttle(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
        var currentWorkItem: DispatchWorkItem?
        var lastFire: TimeInterval = 0
        return {
            guard currentWorkItem == nil else { return }
            currentWorkItem = DispatchWorkItem {
                action()
                lastFire = Date().timeIntervalSinceReferenceDate
                currentWorkItem = nil
            }
            delay.hasPassed(since: lastFire) ? queue.async(execute: currentWorkItem!) : queue.asyncAfter(deadline: .now() + delay, execute: currentWorkItem!)
        }
    }
    

    // proper time to access the data in document... !!!! YES!!!
    //
    override func viewWillAppear() {
        // FIXME: check if we have permissions already... (needed to load images, and other folder assets)
        loadSavedFolderAccessPermissions() // we'll need to check here and see if we have to ask for perms again
        //        askForProjectFolderPermissions()
        //        saveFolderAccessPermissions()
        
       updateLeftRailImages()
    }
    
    func slidesHaveUpdated() {
        updateLeftRailImages()
    }
    
    // on inital load and any time file changes, update left rail thumbs
    func updateLeftRailImages() {
        
        guard let splitVC = parent as? NSSplitViewController else { return }
        guard let detail = splitVC.childViewControllers[1] as? DetailViewController else { return }
        
        // select the folder for image rights
        // FIXME: lazy load this later...
        //NSOpenPanel().selectFolder

        slides = document.slides
        
        // wipe out slide thumbs
        slideThumbs = []
    
        // generate thumbnails
        for slide in slides {
            let viewToSnap: NSView = detail.generateDetailSlide(newView: slide)
            
            
            // reverse flip coordinate system (FIXME: figure out some manual ways to do this...)
            // coordinate system is messed up somehow...
            let oldStack = viewToSnap.subviews[0] as! NSStackView
            let stack = FlippedStackView()
            
            // manually copy over the views so they don't get removed from origin place
            for view in oldStack.arrangedSubviews {
                let archivedView = NSKeyedArchiver.archivedData(withRootObject: view)
                let myViewCopy = NSKeyedUnarchiver.unarchiveObject(with: archivedView)
                stack.addArrangedSubview(myViewCopy as! NSView)
            }
            
            
            let viewToShowNext = FlippedView(frame: NSMakeRect(0, 0, 1024.0, 768.0))
            viewToShowNext.addSubview(viewToSnap)
            
            slideThumbs.append(stack.image())
        }
        
        // reload sidear data
        collectionView.reloadData()
        
        
        // ONLY USED for refreshes (update selected slide, reload selecion etc)
        
        
        // FIXME BUG: change the scroll position to be dynamic to the prior selection
        // https://stackoverflow.com/questions/35207364/how-do-i-programmatically-select-an-object-and-have-that-object-show-as-selecte
        
        // reset selection in sidebar. Causing bugs right now...
        // TODO: fixme
        
        
        // if no slide is selected trying to get the selection back...
        if currentSelectedThumbs == nil {
            currentSelectedThumbs = [[0, 0]] // select first slide if none selected (when app first loads)
//            return
        }
        
        collectionView.selectItems(at: currentSelectedThumbs, scrollPosition: NSCollectionView.ScrollPosition.top)
        
        // reload the currently displayed slide (if any? Maybe just force current selection)
        let currentSlideIndex = currentSelectedThumbs.first?.item // get currently selected index
    
        if let detail = splitVC.childViewControllers[1] as? DetailViewController {
            detail.swapView(newView: slides[currentSlideIndex!] as NSView)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: make this WAY WAY more efficient so it doesn't result in huge (but short) CPU spikes...
        self.splitViewHasResized = throttle(delay: 0.1, queue: DispatchQueue.global(qos: .background), action: refreshThumbsAfterResize)
        
        
        // https://stackoverflow.com/questions/11262080/nssplitview-and-autolayout
//        self.view.widthAnchor.constraint(equalToConstant: 400).isActive = true
//        CONSTRAIN the left rail
        self.view.widthAnchor.constraint(lessThanOrEqualToConstant: 600).isActive = true
        
    }
    
//    var closureName: () -> nil = throttle(delay: 0.4, queue: DispatchQueue.global(qos: .background), action: splitViewHasResized2)
    
    
    
    // called from ViewController.swift
    // FIXME: MUST BE DEBOUNCED...
    func refreshThumbsAfterResize() {
//        https://willowtreeapps.com/ideas/dynamic-sizing-for-horizontal-uicollectionviews
//        flowLayout.invalidateLayout()
        
//         Swift.print("RESIZE####")
        // run the refresh on the main thread
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        

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
        slideItem.view.layer?.backgroundColor = NSColor.brown.cgColor
        
        slideItem.index = indexPath
        let i = indexPath.item
        
        
        // slideItem.slideContent = slides[i] // we aren't using this...
        slideItem.imageView?.image = slideThumbs[i] // set image thumbnail
        slideItem.imageView?.alignment = .right
        slideItem.imageView?.imageAlignment = .alignTopLeft
        
        
//        print("### CYCLE collectionView")
        
        
        
        // add constraints here?
        
        
        return slideItem
    }
    
    // dynamically size collectionView items
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        Swift.print("SIZING####")
        //return CGSize(width: collectionView.frame.height / 6 * 5, height: collectionView.frame.height / 6 * 5)
        let width = collectionView.frame.width / 6 * 5 // FIXME: not ideal
        let height = width / (4/3) // keep 4:3 aspect ratio. 4/3 - 1.333333
        return CGSize(width: width, height: height)
        
//        Swift.print("collectionView.frame", collectionView.frame)
        
//        let width = 1024.0 / 10
//        let height = 768.0 / 10
        
//        return CGSize(width: width, height: height)
        
        
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
     func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayoutsizeForItemAt indexPath: IndexPath
     ) -> NSSize {
     // Here we're telling that we want our cell width to
     // be equal to our collection view width
     // and height equals to 70
     // return CGSize(width: collectionView.bounds.width, height: 70)
        print("### SET SIZE")
     // THIS FN is not being called...
        return CGSize(width: 400, height: 400)
     }
 
 */
    
    
    
    
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
        self.frame = NSRect(x: 0, y: 0, width: 1024, height: 768) // THIS becomes the bounds...
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
    
    // BACKUP. We don't really need this. Hold on to itt for now for the other image processing stuff...
    func image2() -> NSImage {
        //self.draw(NSRect(x: 0, y: 0, width: 600, height: 600))
        
        let width2:CGFloat = 1024.0
        let height2:CGFloat = 768.0
        
//        let bm = NSBitmapImageRep(focusedViewRect: NSRect(x: 0, y: 0, width: 600, height: 600))
        
//        self.bitmapImageRepForCachingDisplayInRect
        let bm = self.bitmapImageRepForCachingDisplay(in: NSRect(x: 0, y: 0, width: width2, height: height2))
        
        self.cacheDisplay(in: NSRect(x: 0, y: 0, width: width2, height: height2), to: bm!)
        
        
//
//        bm?.pixelsWide = Int(width2 / 7.0)
//        bm?.pixelsHigh = Int(height2 / 7.0)
       
        

        
        let bma = NSImage()
        bma.addRepresentation(bm!)
        //
        
        
        let name2 = "test.png"
//        let folder = NSTemporaryDirectory()
                let folder = "/Users/jacharles/Dropbox/dev/downslide_examples/jack_franklin"
//        let folder2 = "/Users/jacharles/Dropbox/dev/mac_playground/downSlide/downSlide"
        let url = URL(fileURLWithPath: folder).appendingPathComponent(name2)
        
        // save to file
//      https://stackoverflow.com/questions/3038820/how-to-save-a-nsimage-as-a-new-file
        let tiffRepresentation = bm?.tiffRepresentation
        let data = tiffRepresentation
        let rep = NSBitmapImageRep(data: data!)
        let imgData = rep?.representation(using: .png, properties: [.compressionFactor : NSNumber(floatLiteral: 1.0)]) //else {
                
//                Swift.print("\(self.self) Error Function '\(#function)' Line: \(#line) No tiff rep found for image writing to \(url)")
                
        
        
        do {
            try imgData?.write(to: url)
        }catch let error {
            Swift.print("\(self.self) Error Function '\(#function)' Line: \(#line) \(error.localizedDescription)")
            askForProjectFolderPermissions() // FIXME: check for proper err
        }
        
        Swift.print("img LOCATION:", url)
        
        return bma
        
//        width = [bm pixelsWide];
        
//        height = [bm pixelsHigh];
//
//        CGDataProviderRef provider = CGDataProviderCreateWithData( bm, [bm bitmapData], rowBytes * height, BitmapReleaseCallback );
//        CGColorSpaceRef colorspace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );
//        CGBitmapInfo    bitsInfo = kCGImageAlphaPremultipliedLast;
//
//        CGImageRef img = CGImageCreate( width, height, 8, 32, rowBytes, colorspace, bitsInfo, provider, NULL, NO, kCGRenderingIntentDefault );
//
//        CGDataProviderRelease( provider );
//        CGColorSpaceRelease( colorspace );
//
//        return img;

        
        
        
        
        
        
        
        // TOOD: read this more...
        // https://stackoverflow.com/questions/4516191/rendering-nsview-containing-some-calayers-to-an-nsimage
        let i = NSImage(size: self.frame.size)
//        let i = NSImage(size: self.frame.size, flipped: false, drawingHandler: noop)
        
        
        i.lockFocus()
        
        if self.lockFocusIfCanDraw(in: NSGraphicsContext.current!) {
            
        
            self.displayIgnoringOpacity(self.frame, in: NSGraphicsContext.current!)
            //[view displayRectIgnoringOpacity:[view frame] inContext:[NSGraphicsContext currentContext]];
        
            self.unlockFocus()
        }
        
        i.unlockFocus()
        
        // FIXME: test this out better...?
        let d: NSData = i.tiffRepresentation! as NSData
//        d.write(toFile: "/Users/jacharles/Dropbox/dev/mac_playground/downSlide/test.tiff", atomically: false)
//        let url = URL(fileURLWithPath: "/Users/jacharles/Dropbox/dev/downslide_examples/jack_franklin/test.tiff", isDirectory: false)
        
        
        
        
        let name = "test.tiff"
//        let folder = NSTemporaryDirectory()
//        let folder = "/Users/jacharles/Dropbox/dev/downslide_examples/jack_franklin"
        let folder3 = "/Users/jacharles/Dropbox/dev/mac_playground/downSlide/downSlide"
        let url3 = URL(fileURLWithPath: folder3).appendingPathComponent(name)
        
        
        Swift.print("URL", url3)
        
        do {
            try d.write(to: url3, atomically: false)
            
        } catch {
            print("Error info: \(error)")
            askForProjectFolderPermissions()
        }
        
        
//        d.write(toFile: "/Users/jacharles/Dropbox/dev/downslide_examples/jack_franklin/test.tiff", atomically: true)
        
        
        
        
        
        /*
        NSData * d = [i TIFFRepresentation];
        [d writeToFile:@"/path/to/my/test.tiff" atomically:YES];
        [i release];
 */
        
        
//        CGWindowListCreateImage(<#T##screenBounds: CGRect##CGRect#>, <#T##listOption: CGWindowListOption##CGWindowListOption#>, <#T##windowID: CGWindowID##CGWindowID#>, <#T##imageOption: CGWindowImageOption##CGWindowImageOption#>)
        
        
//        CGImageRef cgimg = CGWindowListCreateImage(CGRectZero, kCGWindowListOptionIncludingWindow, [theWindow windowNumber], kCGWindowImageDefault)
       
        
        // this resets the first slide view... interesting... because the new constraints haven't been applied yet...
        // https://stackoverflow.com/questions/36732958/how-to-move-or-resize-an-nsview-by-setting-the-frame-property
        // needed bc bounds are zero since it hasn't been rendered into the window yet...
        
        // FIXME: this should be set to the size of the slide (Use a constant size...)
        let width3:CGFloat = 1024.0
        let height3:CGFloat = 768.0
        
        
        
//        https://stackoverflow.com/questions/23626526/how-to-convert-pdf-to-nsimage-and-change-the-dpi
//        https://www.hackingwithswift.com/example-code/core-graphics/how-to-render-a-pdf-to-an-image
        let pdfData = self.dataWithPDF(inside: NSRect(x: 0, y: 0, width: width3, height: height3))
        
        
//        CGWindowListCreateImage(pdfData, <#CGWindowListOption#>)
        
        let im = NSPDFImageRep(data: pdfData)
        
        im?.pixelsWide = Int(width3 / 7.0)
        im?.pixelsHigh = Int(height3 / 7.0)
        
        
//        let im = NSImage(size: im?.size, flipped: false, drawingHandler: <#T##(NSRect) -> Bool#>)
//        NSImage * image = [[NSImage alloc] initWithSize:[imageRep size]];
//        [image addRepresentation: imageRep];
        
        
        
        
//        self.frame = NSRect(x: 0, y: 0, width: width, height: height) // THIS becomes the bounds...
//        self.setFrameSize(NSMakeSize(width, height))

        
        //self.translatesAutoresizingMaskIntoConstraints = true // this forces the constraints to be reset, but it's not strictly needed for our purposes. Mainly we need the frame to change so that bounds isn't 0!
        
//        self.setNeedsDisplay(NSRect(x: 0, y: 0, width: 200, height: 200))
        
       
        
        
        
        
//        self resize(withOldSuperviewSize: NSSize)
        
        
        self.display()
        
        /*
         self.display()
         self.setBoundsSize(NSSize(width: 200, height: 200))
         self.setFrameSize(NSSize(width: 200, height: 200))
         */
        
        //self.layer = CALayer(); self.wantsLayer = true
        
        
        
//        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
//        cacheDisplay(in: bounds, to: imageRepresentation)
//        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
//
        
//
//        let ima = NSImage()
//        ima.addRepresentation(im!)
//
//        return ima
//
        
        
        
        
        
        return NSImage(data: d as Data)!
        
    }
    

    
    
    func noop(rect:CGRect) -> Bool {
        return false
    }
    
}

// CHANGE DEFAULT SIZE for CollectionViewItem
// SET THUMBNAIL SIZE!!!!
// http://wavvel.com/posts/swift/macos/full-width-ns-collection-view-item/
//extension ThumbViewController: NSCollectionViewDelegateFlowLayout {
//    func collectionView(
//        _ collectionView: NSCollectionView,
//        layout collectionViewLayout: NSCollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//        ) -> NSSize {
//        print("request size")
        // Here we're telling that we want our cell width to
        // be equal to our collection view width
        // and height equals to 70
        // return CGSize(width: collectionView.bounds.width, height: 70)
        
        // FIXME: Use a method that is called when the dimensions change of the parent?
        //return CGSize(width: NSWidth(view.bounds), height: NSWidth(view.bounds))
        
        
        /*
        let width = 1024.0 / 10
        let height = 768.0 / 10
        
        return CGSize(width: width, height: height)
 */
    //}
    
    // [self.collectionView setMaxItemSize:NSZeroSize];
//}


// FIXME: Move this to utils folder/file/class or "Debouncer.swift" file?
// debounce that we need for the resize event
// https://stackoverflow.com/questions/27116684/how-can-i-debounce-a-method-call
//https://github.com/webadnan/swift-debouncer
class Debouncer: NSObject {
    var callback: (() -> ())
    var delay: Double
    weak var timer: Timer?
    
    init(delay: Double, callback: @escaping (() -> ())) {
        self.delay = delay
        self.callback = callback
    }
    
    func call() {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
        timer = nextTimer
    }
    
    @objc func fireNow() {
        self.callback()
    }
}




extension TimeInterval {
    
    /**
     Checks if `since` has passed since `self`.
     
     - Parameter since: The duration of time that needs to have passed for this function to return `true`.
     - Returns: `true` if `since` has passed since now.
     */
    func hasPassed(since: TimeInterval) -> Bool {
        return Date().timeIntervalSinceReferenceDate - self > since
    }
    
}



