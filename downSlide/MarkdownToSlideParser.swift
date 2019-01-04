//
//  MarkdownToSlideParser.swift
//  downSlide
//
//  Created by Charles, Jamis on 11/2/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

// Utils responsible for taking the md string and turning it into NSViews that can be rendered to the user

// NOT a class. This is a model. This file will only contain functionality. Not actual data. Will not be used to create objects

// TODO: make a "themes" folder, and store themes in there, including a default base stylesheet
// to be used in case there are no styles for certain things set by the user...
// TODO: make a model / class for making the text elements...
// h1() h2() h3(), where we pass in styles, and text
// TODO: document the hard rules, and allow soft failures for everything else
// TODO: Allow an error, or OUTPUT panel with output for the markdown... Or status updates. "There are errors"

import Foundation
import Cocoa // for NSView


// config for the whole file
// FIXME: change this to be more flexible!!!
struct GlobalConfig {
    var docUrl: URL // nsdocument file path for the md file that's open (needed to get relative image paths)
    var bgColor: NSColor // theme bgcolor
    //var color: NSColor // default text color
    var defaultStyles: NSMutableDictionary // default CSS obj for normal text
    var h1: NSMutableDictionary
    var h2: NSMutableDictionary
    var h3: NSMutableDictionary
    var li: NSMutableDictionary
    //var normalTextStyle: String // default CSS string for normal text
    // TODO: We'll have to figure out how to manage the cascade... Just do it in order, and ditch specifcity?
    // Easiest would be to use obj merge... LATER!
}

// mirrors a stylesheet
struct CSSObject : Codable {
    
}

struct AST {
    
}

//func CSSRule() -> NSMutableDictionary {
//
//}

// returns array of views
// FIXME: If there's any state that the slide needs to hold onto, then we should really use "Slide" objects from "Slide" class
func getSlidesFromContentString(rawString: String, docUrl: URL) -> [NSView] {
    let stringsBySlide = splitFilecontentIntoStringsBySlide(rawString)
    
    // extract global config for the document (theme, styles, etc)
    // FIXME: Must the config be at the top?
    let config = extractGlobalConfig(stringsBySlide[0], docUrl: docUrl) // FIXME: Just make docUrl a global in this file?
    
    
    var slides: [NSView] = []
    for string in stringsBySlide {
        slides.append(parseStringToSlideView(string, globalConfig: config))
    }
    
    return slides
}





// split the fileString into an array of strings by slide
// TODO: add outline mode
private func splitFilecontentIntoStringsBySlide(_ rawFileString: String) -> [String] {
    return rawFileString.components(separatedBy: "---\n")
}

// this is where the main magic is going to happen
// turn a slide string into views that can be rendered
private func parseStringToSlideView(_ str: String, globalConfig: GlobalConfig) -> NSView {
    //print("###########do something#############")
    //let view = NSView();
    
    
    // TOOD: this is where we'll make the important decisions
    // What is the style of the slide?
    // Slide BG Color?
    // Title font size
    // Q: Can we have different themes just be different functions that are called?
    // or at least for what kinds of slides within a theme...?
        // Q: How many types of slides should there be in a given theme? How should those be laid out?
        // If we can use the primary layout mechanism that would be ideal...
    
    //let title = str.components(separatedBy: "\n")[0] // just take first line for now...
    
    let blocks = makeASTForSlide(strForSlide: str)
    
    //var rawStr = str
    // strip out config
    // this mutates the string... Should I do that or something else?
    //rawStr.removingRegexMatches(pattern: "```\\w.*```", replaceWith: " ")
    // trim newlines from top/bottom of string
    //let trimmedStr = rawStr.trim()
    
    
    // categorize section as what kind of content it is
    // code block, config block, notes block, content str (like bullet, heading)
    
    // TODO: Can I basically make an AST of the slide, so I can then have some metadata for each block and know how to process each one?

    
    
    // views that'll be in the NSStackView
    var viewsArr: [NSView] = []
//    let stackView = NSStackView()
    
    // process all the blocks of types of content
    for block in blocks {
        
        // don't process config, notes blocks
        if block.type == "config" || block.type == "notes" {continue}
        
        // all the lines
        //let slideLines = trimmedStr.components(separatedBy: "\n")
        let slideLines = block.lines
        
        
        //viewsArr.append(imageView)
        
        for (i, line) in slideLines.enumerated() {
            // FIXME: reconcile the styles somewhere between global styles and overrides...
            // FIXME: I hate passing down the global config obj so deep :(
            
            // if line is an image, make an imageView instead... FIXME: Should this be here?
            if line.hasPrefix("![") {
//                stackView.addView(<#T##view: NSView##NSView#>, in: <#T##NSStackView.Gravity#>)
//                stackView.addArrangedSubview(makeImageFromMDString(content: line, globalConfig: globalConfig))
                viewsArr.append(makeImageFromMDString(content: line, globalConfig: globalConfig))
            } else {
//                stackView.addView(makeTextField(content: line, type: block.type, globalConfig: globalConfig), in: .top)
//                stackView.addArrangedSubview(makeTextField(content: line, type: block.type, globalConfig: globalConfig))
                viewsArr.append(makeTextField(content: line, type: block.type, globalConfig: globalConfig))
            }
            
            
            
            
            
            // FIXME: distinguish if it's an image or text content...
            // FIXME: quick and hacky just check for image type... We'll have to fix this later for other media types...
            //viewsArr.append(imageView)
            // make image
        }
        
    }
    
    // this method seems to respect the constraints better than by calling addArrangedView() or addSubView(), or addView()
    // we can probably make the other way work, but we need to apply the constraints differently there
    let stackView = NSStackView(views: viewsArr)
    
    
    let stack = FlippedStackView()
//    stack.setFrameSize(NSMakeSize(600, 600)) // this is usually overridden by other constraints.
    stack.orientation = .vertical
//    stack.alignment = .top
    stack.distribution = .fill
    stack.spacing = 8
    stackView.wantsLayer = true
    stack.layer?.backgroundColor = globalConfig.bgColor.cgColor
    
    for (i,view) in viewsArr.enumerated() {
        stack.addArrangedSubview(view)
        
        // change constraint priority
//        let priority = Float(viewsArr.count - i)
        let priority = Float(900 - i)
        
        
        for con in view.constraints {
            con.priority = .init(rawValue: priority)
        }
//        view.constraints[0].priority = .init(rawValue: priority)
//        view.constraints[1].priority = .init(rawValue: priority)
    }
    
//    stack.addArrangedSubview(viewsArr[1])
//    stack.addArrangedSubview(viewsArr[2])
    
    //stack.setHuggingPriority(.defaultLow, for: .vertical)
    //stack.setContentHuggingPriority(.defaultLow, for: .vertical)
    //stack.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//    stack.setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .vertical)
//    stack.setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .horizontal)
//    stack.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(1), for: .vertical)
    
//    viewsArr[0].setContentHuggingPriority(.defaultHigh, for: .vertical)
    
    
    for view in stack.arrangedSubviews {
//        view.setContentHuggingPriority(NSLayoutConstraint.Priority(10), for: .horizontal)
//        view.setContentHuggingPriority(NSLayoutConstraint.Priority(10), for: .vertical)
    }
    
    
    
    
    
//    viewsArr[0].setContentHuggingPriority(.fittingSizeCompression, for: .vertical)
//    viewsArr[0].setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    
//    let stackView = NSStackView()
//    stack.setViews(viewsArr, in: .top)
    
//    stackView.addView(viewsArr[0], in: .top)
//    stackView.addSubview(viewsArr[0], positioned: .below, relativeTo: stackView)

    
    
    // make them take up an equal amount of space (good for just a few, but not like the web, and not natural... provide this as an option?
//    stackView.distribution = .fillEqually
//    stackView.distribution = .fill // only big gap between first and subsequent...
    
    // make the views line up vertically
    stackView.orientation = .vertical
    stackView.distribution = .fillEqually
    stackView.alignment = .leading
    
    
    stackView.wantsLayer = true
    // set slide bg color
    //stackView.layer?.backgroundColor = bgColor.cgColor
    
    
    //return makeFormattedView(title: "Boom!", bgColor: globalConfig.bgColor)
    

    // set this to false so we can create our own Auto Layout constraints
    // this fixes the left rail breaking bonkers
    stack.translatesAutoresizingMaskIntoConstraints = false
    
//    return stackView
    return stack
    
    //return makeFormattedView(title: title, bgColor: globalConfig.bgColor)
    
    //let textField = NSTextField(string: str)
    
    //view.addSubview(textField)
    
    //let stackView = NSStackView(views: [textField])
    
    //return stackView
}


struct ASTNode {
    var rawContent: String
    var range: NSRange // the chars for the content
    var type: String // config, code, content
    var contentSubtype: String // "bullet, h1, h2, js"
}

// FIXME: make AST for whole doc?
// for now we'll just make one for each slide
// TODO Later: Use https://github.com/syntax-tree/mdast and follow that spec?
// https://github.com/apple/swift-cmark look at this <--
// https://remark.js.org/  (use these if we need special stuff we don't get from our quick and hacky way...
// returns an array of tuples
func makeASTForSlide(strForSlide str: String) -> [(type: String, lines: [String])] {
    
    // TODO: READ THIS, and think about what MD standards to adopt...
    // https://stackoverflow.blog/2009/10/15/markdown-one-year-later/
    // https://github.github.com/gfm/
    
    // TODO: make a struct for ast nodes...
    
    // config block
    
    // code block
    
    // content (1 line)? Can content be more than 1 line long? ie: Bullet list?!?
    // should a block of content be considered 1 block or many blocks? For now, let's break them into just the separate blocks... A content block will be a content block until it runs into another kind of block, like notes...
    
    
    // Q: How should I handle empty lines?!? Same as how html handles it? Or should we respect it? Lean towards respecting it...
    
    // LAZY approach. Anything that isn't in the special types, is of type "content"
//    var regex: NSRegularExpression
//    let pattern = ""
//    do {
//        // modified options to allow scanning multi-line strings
//        regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
//    } catch {
//        return results
//    }
//
//    let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
//
    
    // FIXME: this needs to be reworked so we ensure we categorize the entire string properly...
    // that means instead of regex we need to start searching at the beginning of a line, then parse it into the opening / closing tags using ranges...
    
    // FIXME: can we just use lines? Or do we need to use char ranges?!?
    // interesting things happen by lines...
    
    var blocks: [(type: String, lines: [String])] = []
    
    let lines = str.split(separator: "\n")
    
    //var isConfigBlock = false
    //var configBlock: [String] // array of strings
    
    var insideBlock: Bool = false
    // FIXME: Use while loop?
    // Q: What if we just capture categories and ranges first?
    
    var lineBuffer: [String] = []
    var currentBlockType: String = "" // when we open the block we can tag the type
    
    // process each line
    for (i, line) in lines.enumerated() {
        
        //use the lines to break things up into groups..
        if line.hasPrefix("```") { // FIXME: dist between config and code
            
            if insideBlock { // we've hit the end of a code/config block
                var type: String
                
                //lineBuffer.append(String(line))
                
                // end of a config/code block, so tag it and add it
                blocks.append((type: currentBlockType, lines: lineBuffer) )
                // clear the buffer, reset the array
                insideBlock = false
                lineBuffer.removeAll()
            } else { // START of code/config block
                // start of a code/config block, so flush the buffer and tag as content
                if lineBuffer.count > 0 {
                    blocks.append((type: "content", lines: lineBuffer) as! (type: String, lines: [String]))
                    lineBuffer.removeAll() // flush the lineBuffer?
                    
                }
                
                insideBlock = true
                //lineBuffer.append(String(line)) // add the current line after possible flush
                
                // categorize the block as code, notes, config (based on the 2nd line of the block)
                if lines[i+1].contains("config:theme") {
                    currentBlockType = "config"
                } else if lines[i].contains("```notes") {
                    currentBlockType = "notes"
                } else {
                    currentBlockType = "code"
                }
            }
  
        } else {
            // if not start/end block, then add the line whether content or config
            lineBuffer.append(String(line))
        }
        
    }
    
    // if we get to end, and there is still anything in the buffer, process that (like a trailing line of content)
    if lineBuffer.count > 0 {
        blocks.append((type: "content", lines: lineBuffer) as! (type: String, lines: [String]))
        lineBuffer.removeAll() // flush the lineBuffer?
    }
    
    //print("blocks", blocks)
    
    return blocks
    
    /*
    let config = str.capturedGroups(withRegex: "(```\\w+ ?\nconfig:theme.*?```)")
    // FIXME: just name it 'config.theme'?
    let configNode = ASTNode(rawContent: config[0].str, range: config[0].range, type: "config", contentSubtype: "theme")
    
    let codeBlock = str.capturedGroups(withRegex: "(```\\w+ ?\nconfig:theme.*?```)")
    // FIXME: just name it 'config.theme'?
    let codeNode = ASTNode(rawContent: codeBlock[0].str, range: codeBlock[0].range, type: "config", contentSubtype: "theme")
    
    // FIXME: make this work for cases where we have content, then more code...
    let contentStr = str[codeBlock[0].range.length
    //let contentNode =
    
    print(codeBlock)
 
 */
    // TUPLE:
    // - lines [0-4], lines: [start:4, end:9] (tuple)
    // rawContent (string)
    // type "config / code / content"
    // contentSubtype "bullet, h1, h2, js"
    
    
    // node will be of type tuple
    // arrray of nodes...
    // doc can be a collection / array of slides
    
}

// turn MD string into image we can insert
// FIXME: Need to get height/width and other config from the MD string, and from the global settings...
func makeImageFromMDString(content: String, globalConfig: GlobalConfig) -> NSImageView {
    // get filePath from string
    
    // FIXME: make this more flexible? Only allows for
    // extract filepath from this string
    // ![alt text](images/photo.jpg)  <-type of string
    let results = content.capturedGroups(withRegex: "!\\[.*]\\((\\S+)\\)")
    let filePath = results[0].str
    
    // expected to be relative to the NSDocument location...
    // get path to open md file, and remove the file, keep the folder.
    let docFilePath = globalConfig.docUrl.deletingLastPathComponent()
    
    // remove "file://" from beginning of docPath, so it'll work. FIXME: Find a method to do this?
    let docPath = docFilePath.absoluteString.replacingOccurrences(of: "file://", with: "")
    
    let imageView = ImageViewFromMD()
    imageView.frame = NSMakeRect(0, 0, 400, 400)
//    imageView.image = NSImage(contentsOfFile: "/Users/jacharles/Dropbox/dev/mac_playground/downSlide/cat-small-face.jpg")
    
    // FIXME: create more foolproof way of doing this. Like node has path joining methods
    
    
    
    // https://stackoverflow.com/questions/23002653/nsimageview-image-aspect-fill
//    imageView.layer = CALayer()
    
//    imageView.layer?.contentsGravity = kCAGravityResizeAspectFill
//    imageView.layer?.contents = NSImage(contentsOfFile: "\(docPath)\(filePath)")
//    imageView.wantsLayer = true
    
    //imageView.bounds
    

    // set slide bg color
    //stackView.layer?.backgroundColor = bgColor.cgColor
    imageView.layer?.backgroundColor = NSColor.brown.cgColor
    
    
    
    
    
    // set the image src
    let img = NSImage(contentsOfFile: "\(docPath)\(filePath)")
    
    
    
    if let image = NSImage(contentsOfFile: "\(docPath)\(filePath)"){
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        
        // does this even matter?
        // PROPORTIONS ARE SET HERE!!!!. The width
//        imageView.image = NSImage(cgImage: cgImage!, size: NSMakeSize(200, 400))
        imageView.image = image
        
        // FIXME: use this to proportinally size down...
        // This matters more than anything else... Including frame size for imageView
        // his has proven to be the most reliable mechanism for sizing I've found so far.
        // TODO: try to cache these later for better image perf in the file...
        // setting parent view with frame size helps for clipping, but not for resizing the image...
        imageView.image = resize(image: image, w: 200, h: 200)
    }
    
    
//    imageView.image = NSImage(contentsOfFile: "\(docPath)\(filePath)")
    
    imageView.image?.resizingMode = .tile
    // FIXME: figure out how to fix the size and resize
    imageView.imageScaling = .scaleProportionallyDown // no effect?
//    imageView.image?.size = NSMakeSize(200, 200)
//    imageView.setFrameSize(NSMakeSize(200,200))
//    imageView.sizeToFit() // no effec
    
    
    
    // this sizing matters a lot too... Q: How do I make them both work together?
    // this just seems to clip it... Can I just max this? And then use width/height to change the actual size?
    
    // THIS IS WHAT SETS IT!!!!
    // does height even do anything here?!?! proportions are taken from image, then  scaled proportionally...
    // APPEARS to weight towards the larger one... the other just goes along proportionally..
    
//    imageView.frame = NSRect(x: 300, y: 300, width: 300, height: 200) // matters a LOT
    
    //imageView.image = resize(image: imageView.image!, w: 200, h: 500)
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.setFrameSize(NSMakeSize(200, 200))
    imageView.frame = NSMakeRect(0, 0, 200, 200)
    
    let c1 = imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
    c1.isActive = true
    c1.priority = NSLayoutConstraint.Priority(rawValue: 1000.0)
    c1.identifier = "IMAGEVIEW-h"
    
    let c2 = imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)//.isActive = true
    c2.isActive = true
    c2.priority = NSLayoutConstraint.Priority(rawValue: 1000.0)
    c2.identifier = "IMAGEVIEW-w"
    
    
//    imageView.image.heightAnchor.constraint(lessThanOrEqualTo÷Constant: 200).isActive = true
//    imageView.image.widthAnchor.constraint(lessThanOrEqualToCo÷nstant: 200).isActive = true
    
    Swift.print("### imageView frame", imageView.frame)
    Swift.print("### image size", imageView.image?.size)
    
    
    return imageView
    
    // this is max size. imageView won't grow beyond this parent...
//    let v = NSView(frame: NSMakeRect(0, 0, 800, 800))
//    v.addSubview(imageView)
    
//    v.constraints
    
//    v.widthAnchor.constraint(greaterThanOrEqualToConstant: 1024).isActive = true
//    v.heightAnchor.constraint(greaterThanOrEqualToConstant: 768).isActive = true
    
//    return v
    
    
    
//    return imageView
}

func resize(image: NSImage, w: Int, h: Int) -> NSImage {
    var destSize = NSMakeSize(CGFloat(w), CGFloat(h))
    var newImage = NSImage(size: destSize)
    newImage.lockFocus()
    image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
    newImage.unlockFocus()
    newImage.size = destSize
    return newImage
}



// turns string into textField...
func makeTextField(content: String, type:String, globalConfig: GlobalConfig) ->  NSTextView {
    var style = getStringFromDict(cssObj: globalConfig.defaultStyles)
    // if H1, return textfield with H1 styles
    var html = "<span style=\"\(style)\">\(content)</span>"
    
    
    
    //
    if type == "code" {
        html = code(content: content, globalConfig: globalConfig)
    } else if content.hasPrefix("###") {
        html = h3(content: content, globalConfig: globalConfig)
    } else if content.hasPrefix("##") {
        html = h2(content: content, globalConfig: globalConfig)
    } else if content.hasPrefix("#") {
        // FIXME: inherit the global styles...
        html = h1(content: content, globalConfig: globalConfig)
    } else if content.hasPrefix("-") {
        html = li(content: content, globalConfig: globalConfig)
    } else {
        
    }
    
    
    
    // TODO: pass this in from the global styles? or from the inline styles...?
    //let styles = "text-align: justified; line-height: 155px; text-indent: 350px; color: #ffffff; color: rgb(106, 215, 152); font-size: 72px; font-family: Futura; font-weight: bold; text-transform: uppercase;"
    
    
    
    
    /*
    let data = Data(html.utf8)
     
    let NSAttrStr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
     
    let field = NSTextField(labelWithAttributedString: NSAttrStr!)
    field.wantsLayer = true // needed for z-order (like z-index) of the images vs textfields
    return field
 */
    
    
    let titleData = Data(html.utf8)
    
    
    
    // mutable so we can add paragraph styles...
    let NSAttrStr = try? NSMutableAttributedString(data: titleData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    
    
    // textView instead of textField. Bc it gives more control
    let textStorage:NSTextStorage = NSTextStorage(attributedString: NSAttrStr!)
    let manager:NSLayoutManager = NSLayoutManager()
    
    // FIXME: this seems to be the width that matters...
    
    // if this is too small, it'll clip the tex inside...
    let container:NSTextContainer = NSTextContainer(containerSize: NSMakeSize(800, 400))
    // tie it all together so text shows up
    textStorage.addLayoutManager(manager)
    manager.addTextContainer(container)
    
    // appears to have no effect? These sizes don't seem to matter...
    let windowFrame:NSRect = NSRect(x: 0, y: 0, width: 800, height: 200)
    let textView:NSTextView = NSTextView(frame: windowFrame, textContainer: container)
    //let lightBlue = NSColor(red:79/255, green:191/255, blue:203/255, alpha:1.000)
    textView.backgroundColor = globalConfig.bgColor
    
    textView.isEditable = false
    textView.alignment = .left
    
    // get size of textView content. This works!
    //        https://stackoverflow.com/questions/11237622/using-autolayout-with-expanding-nstextviews/14469815#14469815
    textView.layoutManager?.ensureLayout(for: container)
    
    
    let sz = textView.layoutManager?.usedRect(for: container).size
//    let sz = NSMakeSize(200, 200)
    
    let c1 = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: (sz?.height)!)
    c1.isActive = true
    c1.identifier = "\(content) height"
    // does this one even make a difference?
    let c2 = textView.widthAnchor.constraint(greaterThanOrEqualToConstant: ((sz?.width)! + 20))
    c2.isActive = true
    c2.identifier = "\(content) width"
    
    
    
    return textView
}

// pass in local styles, or global styles?
func h1(content: String, globalConfig: GlobalConfig) -> String {
    // local style vs override style. Maybe we can just combine them and let the engine override it?
    let defaultStyles = getStringFromDict(cssObj: globalConfig.defaultStyles)
    let tagStyles = getStringFromDict(cssObj: globalConfig.h1)
    let style = "\(defaultStyles) \(tagStyles)"
    
    // FIXME: Only replace this at beginning of line...
    let trimContent = content.replacingOccurrences(of: "#", with: "")
    return "<span style=\"\(style)\">\(trimContent)</span>"
}

func h2(content: String, globalConfig: GlobalConfig) -> String {
    // local style vs override style. Maybe we can just combine them and let the engine override it?
    let defaultStyles = getStringFromDict(cssObj: globalConfig.defaultStyles)
    let tagStyles = getStringFromDict(cssObj: globalConfig.h2)
    let style = "\(defaultStyles) \(tagStyles)"
    
    // FIXME: Only replace this at beginning of line...
    let trimContent = content.replacingOccurrences(of: "##", with: "")
    return "<span style=\"\(style)\">\(trimContent)</span>"
}

func h3(content: String, globalConfig: GlobalConfig) -> String {
    // local style vs override style. Maybe we can just combine them and let the engine override it?
    let defaultStyles = getStringFromDict(cssObj: globalConfig.defaultStyles)
    let tagStyles = getStringFromDict(cssObj: globalConfig.h3)
    let style = "\(defaultStyles) \(tagStyles)"
    
    // FIXME: Only replace this at beginning of line...
    let trimContent = content.replacingOccurrences(of: "###", with: "")
    return "<span style=\"\(style)\">\(trimContent)</span>"
}

// bullets
func li(content: String, globalConfig: GlobalConfig) -> String {
    let defaultStyles = getStringFromDict(cssObj: globalConfig.defaultStyles)
    let tagStyles = getStringFromDict(cssObj: globalConfig.li)
    let style = "\(defaultStyles) \(tagStyles)"
    
    // FIXME: Only replace this at beginning of line...
    let trimContent = content.replacingOccurrences(of: "-", with: "&#8226;")
    return "<li style=\"\(style)\">\(trimContent)</li>"
}

func img(content: String, globalConfig: GlobalConfig) -> NSImageView {
    let imageView = NSImageView()
    /* Set image property and replace name with your image file's name */
    imageView.image = NSImage(named: NSImage.Name(rawValue: "YOUR_IMAGE_FILE_NAME_HERE"))
    
    return imageView
}

func code(content: String, globalConfig: GlobalConfig) -> String {
    let defaultStyles = getStringFromDict(cssObj: globalConfig.defaultStyles)
    let tagStyles = getStringFromDict(cssObj: globalConfig.li)
    let style = "\(defaultStyles) \(tagStyles)"
    
    // FIXME: Only replace this at beginning of line...
    let trimContent = content.replacingOccurrences(of: "-", with: "&#8226;")
    return "<li style=\"\(style) color: #eee;\">\(trimContent)</li>"
 
}

// figure out the style inheritance for this element...
// figure out the proper string of styles for this element...
// can we just hack it by stringing them together
func inheritStyles() {
    
}

// TODO: add code for generating the thumbnails... Put this somewhere else?

// TODO: consider putting this somewhere else?
// TODO: move this to subClass or model, or slides.swift or separate class file or something...

// TODO: add default bg color...
// NOT BEING USED RIGHT NOW...
// FIXME: REMOVE...
func makeFormattedView(title: String, bgColor: NSColor) -> NSView {
    
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
//    stackView.distribution = .fillEqually
    
    
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
    // set slide bg color
    stackView.layer?.backgroundColor = bgColor.cgColor
    // stackView.layer?.backgroundColor = blue.cgColor
    
    
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

// converts a config string (from markdown) into a config object...
// FIXME: is there a better data structure I can use?
// FIXME: Use ASTs, or parse the css into an object or nsdictionary I can use...
// I don't want to write a bunch of regexes for this...
func extractGlobalConfig(_ rawStr: String, docUrl: URL) -> GlobalConfig {
    
    var isRgb = false
    
    // TODO: see if we can cut off the parts after closing ```
    // keep only the codeFence part
    let configStr = rawStr.components(separatedBy: "```")[1]
    

    let cssObj:NSMutableDictionary = parseCSSIntoDict(cssStr: configStr)
    
    // FIXME: how can we simplify this? use a struct?
    //let mainSlideRules =  cssObj[".background-slide"] as! NSMutableDictionary
    
    
    let defaultSlideRules = cssObj[".default-slide"] as! NSMutableDictionary
    // only meant for text
    let defaultTextRules = cssObj[".default-text"] as! NSMutableDictionary
    
    // FIXME: replace this with a safe getter that will return error messages to the editor...
    // then fallback to the base style sheet?
    let h1Rules = cssObj[".h1"] as! NSMutableDictionary
    let h2Rules = cssObj[".h2"] as! NSMutableDictionary
    let h3Rules = cssObj[".h3"] as! NSMutableDictionary
    
    let liRules = cssObj[".li"] as! NSMutableDictionary
    
    
    //let mainSlideRules =  cssObj[".normal-slide"] as! NSMutableDictionary
    //let normalTextRules = getStringFromDict(cssObj: cssObj[".normal-text"] as! NSMutableDictionary)
    
    let bgColor = defaultSlideRules["background-color"] as! String
    
    
    //let color = normalTextRules["color"] as! String
    
    
    
    
    // FIXME: make this match better
    /*
    let range = NSRange(location: 0, length: configStr.utf16.count)
    let regex = try! NSRegularExpression(pattern: "background-color: rgb")
    let isRgb = regex.firstMatch(in: configStr, options: [], range: range) != nil
 */

    
    // TODO: 1 function to convert both types... Just pass that from here...
    // FIXME: change this structure
    let config = GlobalConfig(docUrl: docUrl, bgColor: stringToNSColor(str: bgColor), defaultStyles: defaultTextRules, h1: h1Rules, h2: h2Rules, h3: h3Rules, li: liRules)
    
    return config
    
}

// ######################
// UTIL FUNCTIONS
// ######################

// CSS string -> NSDict of key value strings
func parseCSSIntoDict(cssStr: String) -> NSMutableDictionary {
    
    // split string into rules.
    // for each match, first group is a class-rule, 2nd group is the rule details between the braces {}
    let result = cssStr.capturedGroups(withRegex: "(\\..+?) ?\\{(.*?)\\}")
    //print("result", result)
    
    // FIXME: make this a struct?
    var CSSObj = NSMutableDictionary()
    
    for (i, item) in result.enumerated() {
        var cssSelector = "" // css selector
        var cssRules: NSMutableDictionary
        // if even number
        if i % 2 == 0 {
            cssSelector = item.str.trim()
            cssRules = parseCSSRules(ruleStr: result[i+1].str)
            CSSObj[cssSelector] = cssRules
        }
    }
    
    //print("CSSObj", CSSObj)

    return CSSObj
}

// returns the rules, not the selector
func getStringFromDict(cssObj: NSMutableDictionary) -> String {
    var str = ""
    for (key, value) in cssObj {
        str += "\(key):\(value);"
    }
    
    return str
}

// parses CSS rules into key value paired dictionary
// TODO: support commented out line "//"
// TODO: Support empty line...
// TODO: Don't crash on invalid CSS (give error of some sort on invalid css)
func parseCSSRules(ruleStr: String) -> NSMutableDictionary {
    // split into lines
    let lines = ruleStr.split(separator: "\n")
    var key = ""
    var val = ""
    
    var dict = NSMutableDictionary()
    
    // split into key values
    for line in lines {
        let result = line.split(separator: ":")
        // don't crash if line is empty
        if (result.count > 1) {
            key = String(result[0]).trim()
            val = String(result[1]).trim()
            // strip quotes (like on font families...
            val = val.replacingOccurrences(of: "\"", with: "")
            dict[key] = val
        }
    }
    // make dictionary
    
    //print("dict", dict)
    
    return dict
}


func stringToNSColor(str: String) -> NSColor{
    var isRgb = false
    
    if str.contains("rgb") {
        isRgb = true
    }
    
    if isRgb {
        let rgbGroups = str.capturedGroups(withRegex: "rgb\\((.*)\\);?")
        return rgbStringToNSColor(rgbStr: rgbGroups[0].str)
    } else {
        let hexGroups = str.capturedGroups(withRegex: "#(.*);?")
        return hexStringToNSColor(hex: hexGroups[0].str)
    }
}

// "1,22,39" -> NSColor
func rgbStringToNSColor(rgbStr: String) -> NSColor {
    let values = rgbStr.split(separator: ",")
    
    // parse from string to int
    let red = Int(String(values[0]).trim())
    let green = Int(String(values[1]).trim())
    let blue = Int(String(values[2]).trim())
    
    //print("rgb: \(red),\(green),\(blue)")
    
    // then parse to CGFloat
    return NSColor(red: CGFloat(red!)/255, green: CGFloat(green!)/255, blue: CGFloat(blue!)/255, alpha:1.000)
    //return NSColor(red: values[0]/255, green: values[1]/255, blue: values[2]/255, alpha:1.000)
    //return NSColor(red: Int(values[0])/255, green: Int(values[1])/255, blue: Int(values[2])/255, alpha:1.000)
}

// UTILS. FIXME: consider moving this out into something else?
// Stolen from https://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values
func hexStringToNSColor (hex:String) -> NSColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if (cString.hasSuffix(";")) { // strip ; from end... FIXME: find a better way to do that?
        cString = cString.replacingOccurrences(of: ";", with: "")
    }
    
    // Deal with 3 character Hex strings
    if cString.count == 3 {
        let redHex   = cString.first!
        let greenHex = cString[cString.index(after: cString.startIndex)] // FIXME: is this really the best way to get the 2nd value?!?!?!
        let blueHex  = cString.last!
        
        cString = "\(redHex)\(redHex)\(greenHex)\(greenHex)\(blueHex)\(blueHex)"
    }
    
    if ((cString.count) != 6) {
        return NSColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return NSColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}


// extend String with regex capture groups
// https://samwize.com/2016/07/21/how-to-capture-multiple-groups-in-a-regex-with-swift/
extension String {
    func capturedGroups(withRegex pattern: String) -> [(str: String, range: NSRange)] {
        // returns tuple with "str" and "range" key
        var results = [(str: String, range: NSRange)]()
        
        var regex: NSRegularExpression
        do {
            // modified options to allow scanning multi-line strings
            regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        } catch {
            return results
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        
        //guard let match = matches.first else { return results }
        
        // loop over ALL the matches, not just the first one (will work for multiple capture groups)
        for match in matches {

            let lastRangeIndex = match.numberOfRanges - 1
            guard lastRangeIndex >= 1 else { return results }
            
            for i in 1...lastRangeIndex {
                let capturedGroupIndex = match.range(at: i)
                let matchedString = (self as NSString).substring(with: capturedGroupIndex)
                results.append((str: matchedString, range: capturedGroupIndex))
            }
        }
        
        return results
    }
    // TRIM
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return
        }
    }
    
}

// needed so shrinking the stack view will cut off from the bottom instead of the top...
//https://hk.saowen.com/a/19d014fbccc2040fa50535081155b385c2d92d077b796ebd8100f3c28733e961
class FlippedStackView: NSStackView {
    override var isFlipped: Bool { return true }
}




