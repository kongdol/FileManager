//
//  Content.swift
//  FileManager
//
//  Created by yk on 2/24/25.
//

import UIKit

struct Content {
    let url: URL
    
    // 파일에서 읽어와서 저장
    var name: String {
        // do-catch문과 동일
        let values = try? url.resourceValues(forKeys: [.localizedNameKey])
        return values?.localizedName ?? "???"
    }

    var size: Int {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        return values?.fileSize ?? 0
    }
    
    var type: Type {
        let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
        return values?.isDirectory == true ? .directory : .file
    }
    // 아이클라우드에서 제외되었는지 확인
    var isExcludedFromBackup: Bool {
        let values = try? url.resourceValues(forKeys: [.isExcludedFromBackupKey])
        return values?.isExcludedFromBackup ?? false
        
    }
    
    // 아이콘이미지
    var image: UIImage? {
        switch type {
        case .directory:
            return UIImage(systemName: "folder")
        case .file:
            let ext = url.pathExtension
            
            switch ext {
            case "txt":
                return UIImage(systemName: "doc.text")
            case "jpg, png":
                return UIImage(systemName: "doc.richtext")
            default:
                return UIImage(systemName: "doc")
            }
        }
    }
}
