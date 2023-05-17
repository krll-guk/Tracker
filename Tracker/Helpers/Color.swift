import UIKit

enum Color {
    static let colorSelectionArray = (1...18).map({ UIColor(named: String($0)) })
    
    static let black = UIColor(named: "Black")
    static let white = UIColor(named: "White")
    
    static let gray = UIColor(named: "Gray")
    static let lightGray = UIColor(named: "Light Gray")
    
    static let background = UIColor(named: "Background")
    
    static let red = UIColor(named: "Red")
    static let blue = UIColor(named: "Blue")
}
