//
//  TFYSwiftButton.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import Foundation

public class TFYSwiftButton: NSButton {

    var oldBackgroundColor : NSColor!
       //MARK:按钮图片的内边距
   @IBInspectable var verticalImagePadding: CGFloat = 0
   @IBInspectable var horizontalImagePadding: CGFloat = 0
           
    public override func draw(_ dirtyRect: NSRect) {
           
           let originalBounds = self.bounds
           defer { self.bounds = originalBounds }
           self.bounds = originalBounds.insetBy(
               dx: horizontalImagePadding,
               dy: verticalImagePadding
           )
           initButtonUiAction()

           let trackingArea = NSTrackingArea(
               rect: self.bounds,
               options: [.mouseEnteredAndExited, .activeAlways],
               owner: self,
               userInfo: nil)
           self.addTrackingArea(trackingArea)
           super.draw(dirtyRect)
       }
       
       func initButtonUiAction() {
           self.isBordered = false
           self.bezelStyle = .texturedSquare
       }
       
        public override var intrinsicContentSize: NSSize {
           var size = super.intrinsicContentSize
           size.width += self.horizontalImagePadding
           size.height += self.verticalImagePadding
           return size;
        }
           
           //MARK:设置鼠标移入的背景颜色
        public override func mouseEntered(with event: NSEvent) {
           let cell : NSButtonCell = self.cell! as! NSButtonCell
           cell.backgroundColor = NSColor.black
        }

           //MARK:设置鼠标移出的被禁颜色
        public override func mouseExited(with event: NSEvent) {
           let cell : NSButtonCell = self.cell as! NSButtonCell
           cell.backgroundColor = oldBackgroundColor
        }
}

public class TFYSwiftButtonCell : NSButtonCell {

    @IBInspectable var imagePaddingLeft   : CGFloat = 0
    @IBInspectable var imagePaddingTop    : CGFloat = 0
    @IBInspectable var textPaddingLeft   : CGFloat = 0
    @IBInspectable var textPaddingTop    : CGFloat = 0

    public override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {

        let newFrame = NSRect.init(
            origin: .init(x: frame.minX + imagePaddingLeft, y: frame.minY + imagePaddingTop),
            size: frame.size)

        super.drawImage(image, withFrame: newFrame, in: controlView)
    }

    public override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
         let newFrame = NSRect.init(
                   origin: .init(x: frame.minX + textPaddingLeft, y: frame.minY + textPaddingTop),
                   size: frame.size)
        super.drawTitle(title, withFrame: newFrame, in: controlView)
        return newFrame
    }
    

}

extension TFYSwiftButton {
    
    //MARK:设置按钮的字体颜色
    var titleTextColor : NSColor {
        get {
            let attrTitle = self.attributedTitle
            return attrTitle.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as! NSColor
        }
        
        set(newColor) {
            let attrTitle = NSMutableAttributedString(attributedString: self.attributedTitle)
            let titleRange = NSMakeRange(0, self.title.count)
            
            attrTitle.addAttributes([NSAttributedString.Key.foregroundColor: newColor], range: titleRange)
            self.attributedTitle = attrTitle
        }
    }
    
    //MARK:设置按钮的背景颜色
    var backgroundColor : NSColor {

        get {
            return oldBackgroundColor
        }
        
        set(newColor) {
            oldBackgroundColor = newColor
            self.wantsLayer = true
            self.layer?.backgroundColor = newColor.cgColor
        }
    }

}
