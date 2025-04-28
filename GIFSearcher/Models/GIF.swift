//
//  GIF.swift
//  GIFSearcher
//
//  Created by Maksim Li on 28/04/2025.
//

import Foundation

struct GIF: Codable {
    let id: String
    let title: String
    let images: Images
    
    struct Images: Codable {
        let original: ImageInfo
        let fixedWidth: ImageInfo
        let preview: ImageInfo
        
        enum CodingKeys: String, CodingKey {
            case original
            case fixedWidth = "fixed_width"
            case preview = "preview_gif"
        }
    }
    
    struct ImageInfo: Codable {
        let url: String
        let width: String
        let height: String
        
        enum CodingKeys: String, CodingKey {
            case url
            case width
            case height
        }
    }
}
