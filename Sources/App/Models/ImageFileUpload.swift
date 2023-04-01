//
//  File.swift
//  
//
//  Created by Eugene Ned on 01.04.2023.
//

import Vapor
import MultipartKit

struct FileUpload: Content {
    var imageFile: File
    var latitude: Double
    var longitude: Double
    var comment: String
}
