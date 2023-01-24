//
//  CodableColor.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/24.
//

import SwiftUI
import Foundation

extension UIColor {

    public convenience init?(hex: String) {
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            self.init(hex: hexColor)
            return
        }

        if hex.count == 6 {
            self.init(hex: "\(hex)ff")
            return
        }

        let red, green, blue, alpha: CGFloat
        if hex.count == 8 {
            let scanner = Scanner(string: hex)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                alpha = CGFloat(hexNumber & 0x000000ff) / 255

                self.init(red: red, green: green, blue: blue, alpha: alpha)
                return
            }
        }
        return nil
    }

    var toColor: CodableColor {
        return CodableColor(uiColor: self)
    }

    func image() -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(cgColor)
        context.fill(rect)

        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return img
    }
}

// MARK: - Color
struct CodableColor: Codable {
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    var color: SwiftUI.Color {
        return SwiftUI.Color(red: Double(red), green: Double(green), blue: Double(blue)).opacity(Double(alpha))
    }

    init(uiColor: UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }

    /** parse hex string. white if error */
    init(hex: String) {
        (UIColor.init(hex: hex) ?? UIColor.white).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }

    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        red = (try? values.decode(CGFloat.self, forKey: .red)) ?? Self.defaultColor.red
        green = (try? values.decode(CGFloat.self, forKey: .green)) ?? Self.defaultColor.green
        blue = (try? values.decode(CGFloat.self, forKey: .blue)) ?? Self.defaultColor.blue
        alpha = (try? values.decode(CGFloat.self, forKey: .alpha)) ?? Self.defaultColor.alpha
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if red != Self.defaultColor.red {
            try container.encode(red, forKey: .red)
        }
        if blue != Self.defaultColor.blue {
            try container.encode(blue, forKey: .blue)
        }
        if green != Self.defaultColor.green {
            try container.encode(green, forKey: .green)
        }
        if alpha != Self.defaultColor.alpha {
            try container.encode(alpha, forKey: .alpha)
        }
    }

    static let defaultColor: CodableColor = CodableColor(hex: "#FFFFFFFF")
}

extension CodableColor: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(red)
        hasher.combine(green)
        hasher.combine(blue)
        hasher.combine(alpha)
    }
}

// extension SwiftUI.Color {
//    public static let gray87 = SwiftUI.Color(red: 87/255, green: 87/255, blue: 87/255)
//    public static let gray106 = SwiftUI.Color(red: 106/255, green: 106/255, blue: 106/255)
//    public static let gray131 = SwiftUI.Color(red: 131/255, green: 131/255, blue: 131/255)
//    public static let gray153 = SwiftUI.Color(red: 153/255, green: 153/255, blue: 153/255)
//    public static let gray175 = SwiftUI.Color(red: 175/255, green: 175/255, blue: 175/255)
//    public static let gray242 = SwiftUI.Color(red: 242/255, green: 242/255, blue: 242/255)
//
//    public static let gray175Adaptive = SwiftUI.Color("gray175")
//    public static let gray242Adaptive = SwiftUI.Color("gray242")
//    public static let gray87Adaptive = SwiftUI.Color("gray87")
//
//    public static let systemBackground = SwiftUI.Color(.systemBackground)
//    public static let snapBlue = SwiftUI.Color(red: 88/255, green: 172/255, blue: 255/255)
//    public static let snapYellow = SwiftUI.Color(red: 255/255, green: 255/255, blue: 88/255)
//
//    public static let purchaseButtonColor = { () -> SwiftUI.Color in
//        if RemoteConfiguration.sharedInstance.isPurchaseBtnBlue {
//            return SwiftUI.Color(red: 21/255, green: 122/255, blue: 252/255)
//        } else {
//            return SwiftUI.Color(red: 175/255, green: 82/255, blue: 222/255)
//        }
//    }
//
//    static var gradient: Array<SwiftUI.Color> {
//        return [
//            SwiftUI.Color(red: 0/255, green: 0/255, blue: 0/255),
//            SwiftUI.Color(red: 84/255, green: 84/255, blue: 84/255)
//        ]
//    }
// }
