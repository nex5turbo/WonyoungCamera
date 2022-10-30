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

    func export(paths: [String], as type: ExportType, count: Int) {
        // render image from renderer
        guard count == 12 || count == 24 || count == 40 else {
            return
        }

        guard let texture = renderer.render(paths: paths, imageCount: count) else {
            abort()
        }
        guard let image = textureToUIImage(texture: texture) else {
            abort()
        }
        switch type {
        case .pdf:
            asPdf(image: image)
        case .png:
            asPng(image: image)
        case .jpg:
            asJpg(image: image)
        }
    }

    func asPdf(image: UIImage) {
        guard let data = createPDF(image: image) else {
            abort()
            // shoul controll failed
        }
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath = documentsPath.appending("\(getTimestampAsString()).pdf")
        data.write(toFile: filePath, atomically: true)
    }

    func asPng(image: UIImage) {
        ImageManager.instance.saveImage(image: image)
    }

    func asJpg(image: UIImage) {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = "\(documentsDirectory)/\(getTimestampAsString()).jpg"
        let imageData = image.jpegData(compressionQuality: 1.0)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
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
