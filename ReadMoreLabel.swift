//
//  ReadMoreLabel.swift
//  PaytmMoneyUIKit
//
//  Created by Shashank on 07/07/19.
//  Copyright © 2019 Paytm Money. All rights reserved.
//

import Foundation

public protocol ReadMoreLabelDelegate:class {
    func trailingTextTapped()
}

public final class ReadMoreLabel:PMLabel {
    
    public init(style: LabelStyleable,delegate:ReadMoreLabelDelegate?) {
        self.delegate = delegate
        super.init(style: style)
    }
    
    public weak var delegate:ReadMoreLabelDelegate?

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    public func addTrailingText(trailingText:String = "...",textToAppend:String,fontOfTextToAppend:UIFont,colorOfTextToAppend:PaytmMoneyColors) {
        let readMoreText = trailingText + textToAppend
        // dont do anything if its frame is not set
        guard self.frame.isEmpty == false else{
            return
        }
        
        guard let lengthForVisibleString = self.visibleTextLength(),let unwrappedText = self.text,unwrappedText.count > readMoreText.count else{
            return
        }
        var startIndex = unwrappedText.index(unwrappedText.startIndex, offsetBy: lengthForVisibleString)
        var range = startIndex..<unwrappedText.endIndex
        let strTrimmedWithoutReadMore = unwrappedText.replacingCharacters(in: range, with: "")
        startIndex = unwrappedText.index(unwrappedText.startIndex, offsetBy: strTrimmedWithoutReadMore.count - readMoreText.count)
        let endIndex = unwrappedText.index(startIndex, offsetBy: readMoreText.count)
        range = startIndex..<endIndex
        let strTrimmedWithReadMode = strTrimmedWithoutReadMore.replacingCharacters(in: range, with: "") + "..."
        let answerAttributed = NSMutableAttributedString(string: strTrimmedWithReadMode, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: textToAppend, attributes: [NSAttributedString.Key.font: fontOfTextToAppend, NSAttributedString.Key.foregroundColor: colorOfTextToAppend.uiColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
        // add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc func handleTap(tap:UITapGestureRecognizer) {
        guard let unwrappedText = self.text, let range = unwrappedText.range(of: "Read More") else{
            return
        }
        let nsRange = NSRange(location: range.lowerBound.utf16Offset(in: unwrappedText), length: range.upperBound.utf16Offset(in: unwrappedText) - range.lowerBound.utf16Offset(in: unwrappedText))
        guard self.didTapAttributedText(locationFromTapGesture: tap.location(in: self), range: nsRange) else{
            return
        }
        self.delegate?.trailingTextTapped()
    }
    
    
    private func visibleTextLength() -> Int? {
        guard let unwrappedText = self.text,let unwrappedFont = self.font,unwrappedText.isEmpty == false else {
            return nil
        }
        let lineBreakMode = NSLineBreakMode.byTruncatingTail
        let width = self.frame.size.width
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes:[NSAttributedString.Key:Any] = [NSAttributedString.Key.font:unwrappedFont]
        let attributedText = NSAttributedString(string: unwrappedText, attributes: attributes)
        let boundingRect = attributedText.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let totalNumberOfLines = Int(ceil(boundingRect.height/font.lineHeight))
        guard totalNumberOfLines > self.numberOfLines else{
            return unwrappedText.count
        }
        var index:String.Index? = unwrappedText.startIndex
        var prev:String.Index? = unwrappedText.startIndex
        let characterSet = CharacterSet.whitespacesAndNewlines
        repeat {
            prev = index
            guard let unwrappedIndex = index else{
                return nil
            }
            let startIndex = unwrappedText.index(unwrappedIndex, offsetBy: 1)
            let range = startIndex..<unwrappedText.endIndex
            if lineBreakMode == NSLineBreakMode.byCharWrapping {
                index = unwrappedText.index(after: unwrappedIndex)
            }else {
                let lowerBound = unwrappedText.rangeOfCharacter(from: characterSet, options: [], range: range)?.lowerBound
                index = lowerBound
            }
        }while ( isHeightGreaterThanLabelHeight(indexOne: index, indexTwo: unwrappedText.endIndex, text: unwrappedText, targetSize: size, attributes: attributes) )
        return prev?.utf16Offset(in: unwrappedText)
    }
    
    private func isHeightGreaterThanLabelHeight(indexOne:String.Index?,indexTwo:String.Index?,text:String,targetSize:CGSize,attributes:[NSAttributedString.Key:Any]) -> Bool {
        guard let unwrappedIndexOne = indexOne , let unwrappedIndexTwo = indexTwo else{
            return false
        }
        guard unwrappedIndexOne.utf16Offset(in: text) < unwrappedIndexTwo.utf16Offset(in: text) else{
           return false
        }
        let substring = String(text[...unwrappedIndexOne])
        let boundingRect = substring.boundingRect(with: targetSize, options: NSStringDrawingOptions.usesLineFragmentOrigin,attributes: attributes, context: nil)
        let totalNumberOfLines = Int(ceil(boundingRect.size.height/self.font.lineHeight))
        return totalNumberOfLines <= self.numberOfLines
    }
    
    private func didTapAttributedText(locationFromTapGesture:CGPoint,range:NSRange) -> Bool {
        // convertes unicode into readable characters and displays them
        let layoutManager = NSLayoutManager()
        // defines a rect region for layout out text and determines line breaks
        let textContainer = NSTextContainer(size: CGSize.zero)
        // a class that stores text to be observed for chages(begin editing etc)
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.size = self.bounds.size
        
        let rectOfLaidText = layoutManager.usedRect(for: textContainer)
        //if the text container has a veritical / horizontal offset we find it by subtracting the labels's width/height from the container's height , divide it by two as it is applied on two sides(doubt)
        let textContainerOffset = CGPoint(x: (self.frame.size.width - rectOfLaidText.size.width) * 0.5 - rectOfLaidText.origin.x, y: (self.frame.size.height - rectOfLaidText.size.height) * 0.5 - rectOfLaidText.origin.y)
        //and then subtract it from the origin to get the exact point.
        let locationOfTouchInTextContainer = CGPoint(x: locationFromTapGesture.x - textContainerOffset.x, y: locationFromTapGesture.y - textContainerOffset.y)
        let indexTappedCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexTappedCharacter, range)
    }
    
    public func revertToInitialState() {
        self.gestureRecognizers?.removeAll()
        self.text = nil
        self.isUserInteractionEnabled = false
    }
    
    deinit {
        self.revertToInitialState()
    }
    
    
}
