//
//  ReadMoreLabel.swift
//
//  Created by Shashank on 07/07/19.
//

import Foundation

public protocol ReadMoreLabelDelegate:class {
    func trailingTextTapped()
}

public final class ReadMoreLabel:PMLabel {
    
    override public var text: String? {
        willSet(newValue){
            self.originalText = newValue
        }
    }
    
    private var originalText:String?
    private var trailingText = "Read More"
    
    public init(style: LabelStyleable,delegate:ReadMoreLabelDelegate?) {
        self.delegate = delegate
        super.init(style: style)
        // add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = false
    }
    
    public weak var delegate:ReadMoreLabelDelegate?
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public func addTrailingText(trailingText:String = "...",textToAppend:String,fontOfTextToAppend:UIFont,colorOfTextToAppend:UIColor) {
        let readMoreText = trailingText + textToAppend
        // dont do anything if its frame is not set
        guard self.frame != CGRect.zero, self.text?.isEmpty == false else{
            return
        }
        self.trailingText = textToAppend
        self.originalText = self.text
        let errorPadding = 2
        // first get the string that can be displayed in the required number of lines
        guard self.numberOfLines != 0, let lengthForVisibleString = self.visibleTextLength()  ,let unwrappedText = self.text ,(lengthForVisibleString < unwrappedText.count), (lengthForVisibleString < unwrappedText.count) , unwrappedText.count > (readMoreText.count + errorPadding) else{
            return
        }
        var startIndex = unwrappedText.index(unwrappedText.startIndex, offsetBy: lengthForVisibleString)
        var range = startIndex..<unwrappedText.endIndex
        // string without read more text that can be displayed
        let strTrimmedWithoutReadMore = unwrappedText.replacingCharacters(in: range, with: "")
        startIndex = unwrappedText.index(unwrappedText.startIndex, offsetBy: strTrimmedWithoutReadMore.count - readMoreText.count - errorPadding)
        let endIndex = unwrappedText.index(startIndex, offsetBy: readMoreText.count + errorPadding)
        range = startIndex..<endIndex
        // string with characters trimmed for read more string
        let strTrimmedWithReadMode = strTrimmedWithoutReadMore.replacingCharacters(in: range, with: "") + "..."
        let answerAttributed = NSMutableAttributedString(string: strTrimmedWithReadMode, attributes: [NSAttributedString.Key.font: self.font])
        // add read more attribtuted string
        let readMoreAttributed = NSMutableAttributedString(string: textToAppend, attributes: [NSAttributedString.Key.font: fontOfTextToAppend, NSAttributedString.Key.foregroundColor: colorOfTextToAppend])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
        self.isUserInteractionEnabled = true
        
    }
    
    @objc func handleTap(tap:UITapGestureRecognizer) {
        guard let unwrappedText = self.text, let range = unwrappedText.range(of: self.trailingText) else{
            return
        }
        let nsRange = NSRange(location: range.lowerBound.utf16Offset(in: unwrappedText), length: range.upperBound.utf16Offset(in: unwrappedText) - range.lowerBound.utf16Offset(in: unwrappedText))
        guard self.didTapAttributedText(locationFromTapGesture: tap.location(in: self), range: nsRange) else{
            return
        }
        self.text = originalText
        self.delegate?.trailingTextTapped()
    }
    
    // returns the last index of the string that can be added
    private func visibleTextLength() -> Int? {
        guard let unwrappedText = self.text,let unwrappedFont = self.font,unwrappedText.isEmpty == false else {
            return nil
        }
        let lineBreakMode = NSLineBreakMode.byTruncatingTail
        let width = self.frame.size.width
        // determine the target size as in how much can fit
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes:[NSAttributedString.Key:Any] = [NSAttributedString.Key.font:unwrappedFont]
        let attributedText = NSAttributedString(string: unwrappedText, attributes: attributes)
        
        let boundingRect = attributedText.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        // compute number of lines based on the target size and see if it is fitting in the reqd number of lines or not
        let totalNumberOfLines = Int(ceil(boundingRect.height/font.lineHeight))
        guard totalNumberOfLines > self.numberOfLines else{
            return unwrappedText.count
        }
        var index:String.Index? = unwrappedText.startIndex
        var prev:String.Index? = unwrappedText.startIndex
        let characterSet = CharacterSet.whitespacesAndNewlines
        // iterate through the string and for each word check if it can be added to the reqd size of the string or not
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
    
    
    // links -
    // https://developer.apple.com/documentation/uikit/nstextcontainer
    // https://developer.apple.com/documentation/uikit/nslayoutmanager
    // https://developer.apple.com/documentation/uikit/nstextstorage
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
