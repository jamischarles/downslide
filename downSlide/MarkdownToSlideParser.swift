//
//  MarkdownToSlideParser.swift
//  downSlide
//
//  Created by Charles, Jamis on 11/2/18.
//  Copyright © 2018 Charles, Jamis. All rights reserved.
//

// Utils responsible for taking the md string and turning it into NSViews that can be rendered to the user

// NOT a class. This is a model. This file will only contain functionality. Not actual data. Will not be used to create objects
import Foundation
import Cocoa // for NSView

// config for the whole file
struct GlobalConfig {
    var bgColor: NSColor // theme bgcolor
}

// returns array of views
// FIXME: If there's any state that the slide needs to hold onto, then we should really use "Slide" objects from "Slide" class
func getSlidesFromContentString(rawString: String) -> [NSView] {
    
    let stringsBySlide = splitFilecontentIntoStringsBySlide(rawString)
    
    // extract global config for the document (theme, styles, etc)
    // FIXME: Must the config be at the top?
    let config = extractGlobalConfig(stringsBySlide[0])
    
    
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
    
    let title = str.components(separatedBy: "\n")[0] // just take first line for now...
    
    return makeFormattedView(title: title, bgColor: globalConfig.bgColor)
    
    let textField = NSTextField(string: str)
    
    //view.addSubview(textField)
    
    let stackView = NSStackView(views: [textField])
    
    return stackView
}


// TODO: add code for generating the thumbnails... Put this somewhere else?

// TODO: consider putting this somewhere else?
// TODO: move this to subClass or model, or slides.swift or separate class file or something...

// TODO: add default bg color...
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
func extractGlobalConfig(_ rawStr: String) -> GlobalConfig {
    
    // TODO: see if we can cut off the parts after closing ```
    // keep only the codeFence part
    let configStr = rawStr.components(separatedBy: "```")[1]
    
    
    // TODO: search for hex vs rgb
    // doubleslach to escape ( and ). Weird...
    
    // FIXME: make this match better
    let range = NSRange(location: 0, length: configStr.utf16.count)
    let regex = try! NSRegularExpression(pattern: "background-color: rgb")
    let isRgb = regex.firstMatch(in: configStr, options: [], range: range) != nil
    
    
    
    if isRgb {
        let rgbGroups = configStr.capturedGroups(withRegex: "background-color: rgb\\((.*)\\);?")
        let config = GlobalConfig(bgColor: rgbStringToNSColor(rgbStr: rgbGroups[0]))
        print("Choose RGB", config)
        return config
        
    } else {
        let hexGroups = configStr.capturedGroups(withRegex: "background-color: #(.*);?")
        let config = GlobalConfig(bgColor: hexStringToNSColor(hex: hexGroups[0]))
        print("Choose HEX", config)
        return config
    }
    
}

// "1,22,39" -> NSColor
func rgbStringToNSColor(rgbStr: String) -> NSColor {
    let values = rgbStr.split(separator: ",")
    
    // parse from string to int
    let red = Int(String(values[0]))
    let green = Int(String(values[1]))
    let blue = Int(String(values[2]))
    
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
    
    // Deal with 3 character Hex strings
    if hex.count == 3 {
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
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        
        guard let match = matches.first else { return results }
        
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }
        
        return results
    }
}
