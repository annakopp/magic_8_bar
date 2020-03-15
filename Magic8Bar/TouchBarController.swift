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
    
    static let magicTouchBar = NSTouchBar.CustomizationIdentifier("magicTouchBar")
}

fileprivate extension NSTouchBarItem.Identifier {
    static let magicTouchBarItem = NSTouchBarItem.Identifier("magicTouchBarItem")
}

struct Constants {
    static let touchBarWidth:CGFloat = 700.0
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
    let messageTextView = NSTextField(labelWithString: "")
    let message = BehaviorRelay<String>(value: "🎱 SWIPE LEFT <-> RIGHT TO SHAKE")
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier =
            .magicTouchBar
        touchBar.defaultItemIdentifiers = [.magicTouchBarItem]

        return touchBar
    }
    
    fileprivate func startListeningToSlider() {
        sliderView.rx.value.observeOn(MainScheduler.instance).scan(0, accumulator: { (accum, next) -> Double in
             let total = accum + next
             return total
         }).takeWhile { (total) -> Bool in
             return total < 8
        }.subscribe(onNext: {total in
            self.messageTextView.alphaValue = CGFloat((1 - total/8))
        },onCompleted: {
            print("done?")
        }, onDisposed: {
            print("disposed?")
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 1.0
                self.messageTextView.animator().alphaValue = 1
                self.message.accept("🎱")
            }) {
                self.message.accept(Answers.allCases.randomElement()!.rawValue)
                self.messageTextView.animator().alphaValue = 1
                self.startListeningToSlider()
            }
        })
    }
    
    fileprivate func setUpSliderCell() {
        let sliderCell = SecretSliderCell()
        sliderCell.target = self
        sliderCell.minValue = -1
        sliderCell.maxValue = 1
        sliderView.cell = sliderCell
    }
    
    fileprivate func setUpViews() {
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        theView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        
        theView.addSubview(messageTextView)
        theView.addSubview(sliderView)
        
        let c1 = NSLayoutConstraint(item: theView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: Constants.touchBarWidth)

        let centerY = messageTextView.centerYAnchor.constraint(equalTo: theView.centerYAnchor)
        let centerX = messageTextView.centerXAnchor.constraint(equalTo: theView.centerXAnchor)
               
        sliderView.widthAnchor.constraint(equalTo: theView.widthAnchor).isActive = true
        
        NSLayoutConstraint.activate([
             centerY, centerX
         ])
         
        theView.addConstraints([c1])
    
        setUpSliderCell()
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let customViewItem = NSCustomTouchBarItem(identifier: identifier)
        switch identifier {
        case .magicTouchBarItem:
            setUpViews()
            
            self.message.observeOn(MainScheduler.instance).subscribe { (event) in
                guard let msg: String = event.element else { return }
                self.messageTextView.stringValue = msg.uppercased()
            }
            
            startListeningToSlider()
            
            self.theView.wantsLayer = true
            self.theView.layer?.backgroundColor = NSColor.blue.cgColor
            customViewItem.view = self.theView
            
            return customViewItem
        default:
            return nil
        }
    }
}
