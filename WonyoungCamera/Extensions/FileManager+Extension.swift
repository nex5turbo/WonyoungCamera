//
//  FileManager+Extension.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2022/12/29.
//

import Foundation

extension FileManager {
    func getDocumentDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    func getFilesAtDocument() -> [String] {
        guard let urls = try? FileManager.default.contentsOfDirectory(atPath: getDocumentDirectory().path) else {
            return []
        }
        var returnUrl: [String] = []
        urls.forEach { fileName in
            print(fileName)
            if fileName.contains("png") || fileName.contains("jpeg") || fileName.contains("pdf") {
                returnUrl.append("file://" + FileManager.default.getDocumentDirectory().appendingPathComponent(fileName).path)
            }
        }
        return returnUrl
    }
}
