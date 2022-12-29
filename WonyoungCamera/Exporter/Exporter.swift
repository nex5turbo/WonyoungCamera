//
//  Exporter.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/10/31.
//

import Foundation
import UIKit
enum ExportType {
    case pdf
    case png
    case jpg
}
class Exporter {
    var renderer: ExportRenderer
    deinit {
        print("deinit exporter")
    }
    init() {
        renderer = ExportRenderer()
    }

    func exportAndGetResult(paths: [String], as type: ExportType, count: Int) -> (UIImage, NSData?, String?)? {
        // render image from renderer
        guard count == 12 || count == 20 || count == 30 else {
            return nil
        }

        guard let texture = renderer.render(paths: paths, imageCount: count) else {
            return nil
        }
        guard let image = textureToUIImage(texture: texture) else {
            return nil
        }
        var nsdata: NSData? = nil
        var url: String? = nil
        switch type {
        case .pdf:
            nsdata = asPdf(image: image)
        case .png:
            url = asPng(image: image)
        case .jpg:
            url = asJpg(image: image)
        }
        return (image, nsdata, url)
    }

    func asPdf(image: UIImage) -> NSData {
        guard let data = createPDF(image: image) else {
            abort()
            // shoul controll failed
        }
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let filePath = documentsPath.appending("\(getTimestampAsString()).pdf")
//        data.write(toFile: filePath, atomically: true)
        return data
    }

    func asPng(image: UIImage) -> String {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = "\(documentsDirectory)/\(getTimestampAsString()).png"
        print("debug4 \(filePath)")
        let imageData = image.jpegData(compressionQuality: 1.0)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        return filePath
    }

    func asJpg(image: UIImage) -> String {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = "\(documentsDirectory)/\(getTimestampAsString()).jpg"
        let imageData = image.pngData()
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        return filePath
    }

    func createPDF(image: UIImage) -> NSData? {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil)
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, image.size.width, image.size.height), nil)
        image.draw(in: CGRectMake(0, 0, image.size.width, image.size.height))
        UIGraphicsEndPDFContext()
        return pdfData
    }

    func getTimestampAsString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        return formatter.string(from: date)
    }
}
