import UIKit

extension UILabel {
    func addInterlineSpacing(spacingValue: CGFloat) {
        guard let textString = text else { return }
        
        let attributedString = NSMutableAttributedString(string: textString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacingValue
        
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        attributedText = attributedString
    }
}
