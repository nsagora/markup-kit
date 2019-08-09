import Foundation

public struct MarkupAttributes {

    var openingTag: String
    var closingTag: String
    var attributes: [NSAttributedString.Key: Any]
    
    public init(openingTag: String, closingTag: String, attributes: [NSAttributedString.Key: Any]) {
        self.openingTag = openingTag
        self.closingTag = closingTag
        self.attributes = attributes
    }
}

extension MarkupAttributes {

    var regex: NSRegularExpression {

        let openTag = NSRegularExpression.escapedPattern(for: openingTag)
        let closeTag = NSRegularExpression.escapedPattern(for: closingTag)
        let pattern = openTag + "(.*?)" + closeTag

        return try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
    }
}

public class MarkupEngine: NSObject {

    private var markupAttributes = [MarkupAttributes]() 

    public convenience init(_ markupAttributes: MarkupAttributes...) {
        self.init(markupAttributes: markupAttributes)
    }
    
    public init(markupAttributes: [MarkupAttributes]) {
        super.init()
        self.markupAttributes = markupAttributes
    }

    public func applyMarkup(onText text: String) -> NSAttributedString {
        let attributedText = NSAttributedString(string: text)
        return applyMarkup(onAttributedText: attributedText)
    }

    public func applyMarkup(onAttributedText attributedText: NSAttributedString) -> NSAttributedString {

        let attrString = NSMutableAttributedString(attributedString: attributedText)

        for markupData in markupAttributes {
            attrString.apply(markupData: markupData)
        }

        return attrString
    }
}

extension NSMutableAttributedString {

    internal func apply(markupData: MarkupAttributes) {

        let regex = markupData.regex
        while let result = regex.firstMatch(in: self.string, options: [], range: NSRange(location: 0, length: self.length)) {

            self.addAttributes(markupData.attributes, range: result.range)

            let groupValue = self.attributedSubstring(from: result.range(at: 1))
            self.replaceCharacters(in: result.range, with: groupValue)
        }
    }
}

extension MarkupEngine {
    
    static var markdown = MarkupEngine()
    static var markleft = MarkupEngine()
}
