//
//  ImageManager.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/09/27.
//

import Foundation
import SwiftUI
struct AlbumItem: Hashable {
    var image: UIImage?
    var path: String
}
class ImageManager {
    static let instance = ImageManager()
    private init() {}
    private let APP_FOLDER_NAME: String = "YoungsCamera"
    private func createMyCollageDir(myCollageDirPath: URL) {
        guard !FileManager.default.fileExists(atPath: myCollageDirPath.path) else { return }

        do {
            try FileManager.default.createDirectory(
                atPath: myCollageDirPath.path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            print("hello \(error.localizedDescription)")
        }
    }

    private func getDocumentDir() -> URL? {
        guard let documentDir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("getDocumentDir() error: There is no document directory!")
            return nil
        }

        return documentDir
    }
    private var timestamp: String {
        return "\(NSDate().timeIntervalSince1970)"
    }
    func saveImage(image: UIImage) {
        do {
            guard let documentDir = getDocumentDir() else { return }

            let myCollageDirPath = documentDir.appendingPathComponent(APP_FOLDER_NAME)
            createMyCollageDir(myCollageDirPath: myCollageDirPath)
            guard let data = image.pngData() else {
                return
            }
            guard let targetImage = UIImage(data: data) else {
                return
            }

            let dataPath = myCollageDirPath.appendingPathComponent("\(timestamp)_youngs.png")
            try data.write(to: dataPath)
            
            UIImageWriteToSavedPhotosAlbum(targetImage, nil, nil, nil)
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
        }
    }
    func delete(at: String) {
        guard let url = URL(string: at) else { return }
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("Error: \(error)")
        }
    }
    func loadImageUrls() -> [String] {
        guard let documentDir = getDocumentDir() else { return [] }

        let myCollageDirPath = documentDir.appendingPathComponent(APP_FOLDER_NAME)
        createMyCollageDir(myCollageDirPath: myCollageDirPath)
        let sortedUrls = try? FileManager.default.contentsOfDirectory(
            at: myCollageDirPath,
            includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        )
        .sorted(by: {
            if let date1 = try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
               let date2 = try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate {
                return date1 > date2
            }
            return false
        })
        guard let sortedUrls = sortedUrls else { return [] }
        return sortedUrls.map {
            return $0.absoluteString
        }
    }
    func loadImages() -> [AlbumItem] {
        guard let documentDir = getDocumentDir() else { return [] }

        let myCollageDirPath = documentDir.appendingPathComponent(APP_FOLDER_NAME)
        createMyCollageDir(myCollageDirPath: myCollageDirPath)
        let sortedUrls = try? FileManager.default.contentsOfDirectory(
            at: myCollageDirPath,
            includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        )
            .sorted(by: {
                if let date1 = try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                   let date2 = try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate {
                    return date1 < date2
                }
                return false
            })
        guard let sortedUrls = sortedUrls else { return [] }
        return sortedUrls.map {
            return AlbumItem(image: UIImage(contentsOfFile: $0.path), path: $0.path)
        }
    }
}

func textureToUIImage(texture: MTLTexture) -> UIImage? {
    guard let cgImage = convertToCGImage(texture: texture) else {
        return nil
    }
    let uiImage = UIImage(cgImage: cgImage)
    return uiImage
}
func convertToCGImage(texture: MTLTexture) -> CGImage? {
    let options: [CIImageOption: Any] = [
        .colorSpace: CGColorSpaceCreateDeviceRGB()
    ]
    guard let ciImage = CIImage(mtlTexture: texture, options: options) else {
        fatalError("No ciImage")
    }
    guard let cgImage = convertToCGImage(ciImage: ciImage.oriented(.downMirrored)) else {
        fatalError("No cgImage")
    }
    return cgImage
}
func convertToCGImage(ciImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
        return cgImage
    }
    return nil
}
