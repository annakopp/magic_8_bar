//
//  TouchBarController.swift
//  tab_bar
//
//  Created by Anna on 11/25/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Cocoa

fileprivate extension NSTouchBar.CustomizationIdentifier {
    
    static let helloWorldBar = NSTouchBar.CustomizationIdentifier("helloWorldBar")
}

fileprivate extension NSTouchBarItem.Identifier {
    static let colorTestBarItem = NSTouchBarItem.Identifier("colorTestBarItem")
}

struct Constants {
    static let touchBarWidth:CGFloat = 700.0
    static let backgroundColor = NSColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
}


class TouchBarController: NSWindowController, NSTouchBarDelegate, CAAnimationDelegate {
     let theView = NSView()
    var message = "SWIPE LEFT/RIGHT"
    override func windowDidLoad() {
           super.windowDidLoad()
        
    }

    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier =
            .helloWorldBar
        touchBar.defaultItemIdentifiers = [.colorTestBarItem]

        return touchBar
    }
    
    @objc func shake(sender: NSSlider) {
        print(sender.floatValue)
        self.message = "YES"
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let customViewItem = NSCustomTouchBarItem(identifier: identifier)
        switch identifier {
        case .colorTestBarItem:
            // let thing = CAShapeLayer()
            // thing.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            //let frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 1))
            //self.theView.frame = frame

            
            let c1 = NSLayoutConstraint(item: theView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: Constants.touchBarWidth)
        

            
            //let buttonView = NSButton(title: "Test", target: nil, action: nil)
            let sliderView = NSSlider()
            sliderView.translatesAutoresizingMaskIntoConstraints = false
            
            theView.translatesAutoresizingMaskIntoConstraints = false
     
            let messageText = NSTextField(labelWithString: self.message)
            messageText.translatesAutoresizingMaskIntoConstraints = false
           theView.addSubview(messageText)
            theView.addSubview(sliderView)
       
            let centerY = messageText.centerYAnchor.constraint(equalTo: theView.centerYAnchor)
            let centerX = messageText.centerXAnchor.constraint(equalTo: theView.centerXAnchor)
            
            sliderView.widthAnchor.constraint(equalTo: theView.widthAnchor).isActive = true
            let sliderCell = SecretSliderCell()
            sliderCell.target = self
            sliderCell.action = #selector(shake)

            sliderCell.maxValue = 0.5
            sliderView.cell = sliderCell
            
 
        
            NSLayoutConstraint.activate([
                centerY, centerX
            ])
            
            theView.addConstraints([c1])
            
            self.theView.wantsLayer = true
            self.theView.layer?.backgroundColor = NSColor.blue.cgColor
            customViewItem.view = self.theView
            
            return customViewItem
        default:
            return nil
        }
    }
}
