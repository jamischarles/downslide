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
    
 
    
    var fileContent = ""
    
    // make all the slides here...
    var slides: [NSView] = []
    
    // TODO: make this a struct? and have an array of slide scrcts?
    var slideThumbs: [NSImage] = []
    
    // http://wiresareobsolete.com/2010/03/awakefromnib/
    override func awakeFromNib() {
        
        print("### AWAKE FROM NIB")
   
        //self.collectionView
        // This only sort of works in grid view... but for width instead of height
        
        // DOES NOT WORK
        //        self.collectionView.enclosingScrollView?.bounds.size.width = 300
        //      self.collectionView.enclosingScrollView?.bounds.size.height = 300
        
        
    }
    
 
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
        print("document.slides", document.slides)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("### ViewDidLoad")
        //print("document content", document.getFileContent())
        // Do view setup here.
       
        slides.append(makeFormattedView(title: "We just changed tables to divs"))
        slides.append(makeFormattedView(title: "Sweet 2nd slide!"))
        slides.append(makeFormattedView(title: "Noice! 3rd slide!!!"))
        
        // generate thumbnails
        for slide in slides {
            slideThumbs.append(slide.image())
            //slideThumbs.append(slides[1].image())
        }
        
        
        //guard let splitVC = parent as? NSSplitViewController else { return }
        //let splitVC = parent as? NSSplitViewController
        
        
        print("#### FILEVIEWCONENT", fileContent)
        
        // NOT WORKING :(
        /*
        var document: Document {
            let oughtToBeDocument = self.view.window?.windowController?.document as? Document
            assert(oughtToBeDocument != nil, "Unable to find the document for this view controller.")
            return oughtToBeDocument!
        }*/
        
        
        
        
        //print("document content", document.getFileContent())
        
    }
    
    
    func changeFileContent(str: String) {
        self.fileContent = str
        print("#### self.fileContent", self.fileContent)
        
        
        
        view.updateLayer()
    }
    
    
    // TODO: rethink if we should create objects here, or create a model that can be shared by the document and this?
    // READ this to figure that out...
    // https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/DocBasedAppProgrammingGuideForOSX/Designing/Designing.html
    func populateStringFromFile(str: String) {
        print("str inside the fn", str)
    }
    
    
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
        
        
        
        
        
        // add constraints here?
        
        
        return slideItem
    }
    
    // WHEN SELECTION CHANGES swap out the view
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        print("item selected", indexPaths)
        guard let splitVC = parent as? NSSplitViewController else { return }
        if let detail = splitVC.childViewControllers[1] as? DetailViewController {
            //let item = indexPaths[0].item
            print("indexes", collectionView.item(at: 1))
            let item = collectionView.item(at: 1) as? SlideThumb
            
            // TODO: selecetd from outlet
            
            let i = indexPaths.first?.item
            print("i",i)
            //let newView = NSTextField(labelWithString: "new view Placeholder View") as NSView!
            
            detail.swapView(newView: slides[i!] as! NSView!)
            
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
    
    
    
    // TODO: move this to subClass or model, or slides.swift or separate class file or something...
    func makeFormattedView(title: String) -> NSView{
        
        
        //rgb: 106, 215, 152
        let green = NSColor(red:106/255, green:215/255, blue:152/255, alpha:1.000)
        
        // rgb(1, 22, 39);
        let blue = NSColor(red:1/255, green:22/255, blue:39/255, alpha:1.000)
        
        let brightRed = NSColor(srgbRed: 0.106, green: 0.215, blue: 0.152, alpha: 1.0)
        
        
        brightRed.setFill()
        
        //let titleFont = NSFont(name: "Futura", size: 72)
        let titleFont = NSFont(name: "Futura-Bold", size: 72) // bold
        
        let myAttribute: [NSAttributedStringKey: Any] = [.font: titleFont, .foregroundColor: green]
        
        
        let titleStr = NSMutableAttributedString(string: "\(title)".uppercased(), attributes: myAttribute)
        let title = NSTextField(labelWithAttributedString: titleStr)
        title.alignment = NSTextAlignment.left
        
        //title.setFont(NSFont(fontWithName:"Arial-BoldItalicMT" size:20])
        
        //title.font = NSFont(name: "Lucida Sans", size: 72)
        
        title.isBordered = true
        
        title.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
        //title.stringValue = "My awesome label"
        title.backgroundColor = .white
        title.isBezeled = false
        title.isEditable = false
        title.sizeToFit()
        
        //let int: Int32 = 10
        //title.preferredMaxLayoutWidth(CGFloat(int))
        
        // subtitle
        let subTitleAttrs: [NSAttributedStringKey: Any] = [.backgroundColor: NSColor.blue, NSAttributedStringKey.kern: 1]
        let subTitleStr = NSMutableAttributedString(string: "• Sub title", attributes: subTitleAttrs)
        let subTitle = NSTextField(labelWithAttributedString: subTitleStr)
        
        // bullet
        //let paragraphStyle = NSMutableParagraphStyle()
        //paragraphStyle.alignment = .left
        //paragraphStyle.firstLineHeadIndent = 5.0
        
        let bulletAttrs: [NSAttributedStringKey: Any] = [.font: NSFont.systemFont(ofSize: 50), NSAttributedStringKey.kern: 1]
        let bulletStr = NSMutableAttributedString(string: "• Typical lifecycle of a component ", attributes: bulletAttrs)
        let bullet = NSTextField(labelWithAttributedString: bulletStr)
        bullet.alignment = NSTextAlignment.left
        
        let bullet2Str = NSMutableAttributedString(string: "• How patterns can simplify", attributes: bulletAttrs)
        let bullet2 = NSTextField(labelWithAttributedString: bullet2Str)
        bullet2.alignment = NSTextAlignment.left
        
        
        
        // create horizontal rule
        let lineView = NSView(frame:NSRect(x:1, y:1, width:298, height:1))
        
        
        lineView.wantsLayer = true
        lineView.layer?.backgroundColor = NSColor.white.cgColor
        
        
        
        let box = NSBox(frame: NSRect(x:1, y:1, width:298, height:1))
        box.boxType = .custom
        box.alphaValue = 1
        box.borderColor = NSColor.red
        box.borderType = .lineBorder
        box.borderWidth = 1
        
        // WORKS text-indent: 350px; text-decoration: unedrline; color, bckg-c; text-align
        // DOES NOT: padding, margin, width, border  // Q: Can we polyfill those on the swift side? or provide a custom attribute for that?
        
        let styles = "text-align: justified; line-height: 155px; text-indent: 350px; color: #ffffff; color: rgb(106, 215, 152); font-size: 72px; font-family: Futura; font-weight: bold; text-transform: uppercase;"
        
        // FIXME: erase the other stuff up top...
        let htmlstring2 = """
        <h1 style="\(styles)">\(title)</h1>
        """
        
        
        let data = Data(htmlstring2.utf8)
        
        //return NSTextField(labelWithAttributedString: string1)
        //let field = NSTextField(NSAttributedString: string1)
        let str = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        // use your attributed string somehow
        let field = NSTextField(labelWithAttributedString: str!)
        
        
        
        
        // create a stack view from four text fields
        let stackView = NSStackView(views: [title, field])
        
        // make them take up an equal amount of space
        stackView.distribution = .fillEqually
        
        // make the views line up vertically
        stackView.orientation = .vertical
        
        // set this to false so we can create our own Auto Layout constraints
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        
        
        
        
        
        
        //view.addSubview(title)
        //view.addSubview(stackView)
        
        // left align the bullets. Consider just grouping those in a view?
        // must add these constraints after it's part of the view tree
        //bullet.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        //bullet2.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        // add bg color
        // Q: Use view instead?
        stackView.wantsLayer = true
        stackView.layer?.backgroundColor = blue.cgColor
        
        
        // FIXME: Do we need to apply all the constraints and all these transformations when we show it only?
        
        // add these contraints after adding the stackview as a subview
        // make the stack view sit directly against all four edges
        //stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        //stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true // don't center it, and limit the width
        
        //stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // set the width of the stackview container to 800 so things aren't cut off...
        //stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 800).isActive = true
        
        // left/right padding 50%
        //stackView.edgeInsets = NSEdgeInsets(top:200,left:NSWidth(view.bounds) / 2, bottom: 200,right:NSWidth(view.bounds) / 2)
        
        //stackView.setFrameSize(NSSize(width: 200, height: 200))
        //stackView.setBoundsSize(NSSize(width: 200, height: 200))
        
        return stackView
        
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
        print("request size")
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

