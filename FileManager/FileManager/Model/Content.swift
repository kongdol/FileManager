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
        return ""
    }

    var size: Int {
        return 0
    }
    
    var type: Type {
        return .file
    }
    // 아이클라우드에서 제외되었는지 확인
    var isExcludedFromBackup: Bool {
        return false
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
