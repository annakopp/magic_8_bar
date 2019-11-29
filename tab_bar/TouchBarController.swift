//
//  TouchBarController.swift
//  tab_bar
//
//  Created by Anna on 11/25/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

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

enum Answers: String, CaseIterable {
    case ItIsCertain = "It is certain."
    case ItIsDecidedlySo = "It is decidedly so."
    case WithoutADoubt = "Without a doubt."
    case YesDefinitely = "Yes, definitely."
    case YouMayRelyOnIt =  "You may rely on it."
    case AsISeeItYes = "As I see it, yes."
    case MostLikely = "Most likley."
    case OutlookGood = "Outlook good."
    case Yes = "Yes."
    case SignsPointToYes = "Signs point to yes."
    case ReplyHazyTryAgain = "Reply hazy try again."
    case AskAgainLater =  "Ask again later."
    case BetterNotTellYouNow = "Better not tell you now."
    case CannotPredictNow =  "Cannot predict now."
    case ConcentrateAndAskAgain = "Concentrate and ask again."
    case DontCountOnIt = "Don't count on it."
    case MyReplyIsNo =  "My reply is no."
    case MySourcesSayNo = "My sources say no."
    case OutlookNotSoGood = "Outlook not so good."
    case VeryDoubtful = "Very doubtful."
}


class TouchBarController: NSWindowController, NSTouchBarDelegate, CAAnimationDelegate {
    let theView = NSView()
    let sliderView = NSSlider()
    let messageText = NSTextField(labelWithString: "")
    let message = BehaviorRelay<String>(value: "🎱 SWIPE LEFT <-> RIGHT TO SHAKE")
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
        self.message.accept(Answers.allCases.randomElement()!.rawValue)
    }
    
    func startListeningToSlider() {
        sliderView.rx.value.observeOn(MainScheduler.instance).scan(0, accumulator: { (accum, next) -> Double in
             let total = accum + next
             return total
         }).takeWhile { (total) -> Bool in
             return total < 8
        }.subscribe(onNext: {total in
            self.messageText.alphaValue = CGFloat((1 - total/8))
            print(CGFloat((1 - total/8)))
            print(total)
        },onCompleted: {
            print("done?")
        }, onDisposed: {
            print("disposed?")
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 1.0
                self.messageText.animator().alphaValue = 1
                self.message.accept("🎱")
            }) {
                self.message.accept(Answers.allCases.randomElement()!.rawValue)
                self.messageText.animator().alphaValue = 1
                self.startListeningToSlider()
            }
            
        })
             
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

            
            sliderView.translatesAutoresizingMaskIntoConstraints = false
            
            theView.translatesAutoresizingMaskIntoConstraints = false
     
           
            
            
            _ = self.message.observeOn(MainScheduler.instance).subscribe { (event) in
                guard let msg: String = event.element else { return }
                self.messageText.stringValue = msg.uppercased()
            }

            
            messageText.translatesAutoresizingMaskIntoConstraints = false
           theView.addSubview(messageText)
            theView.addSubview(sliderView)
       
            let centerY = messageText.centerYAnchor.constraint(equalTo: theView.centerYAnchor)
            let centerX = messageText.centerXAnchor.constraint(equalTo: theView.centerXAnchor)
            
            sliderView.widthAnchor.constraint(equalTo: theView.widthAnchor).isActive = true
            let sliderCell = SecretSliderCell()
            sliderCell.target = self
            sliderCell.minValue = -1
            sliderCell.maxValue = 1
            sliderView.cell = sliderCell
            
            startListeningToSlider()

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
