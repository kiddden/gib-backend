//
//  File.swift
//  
//
//  Created by Eugene Ned on 01.04.2023.
//

import Fluent
import Vapor

final class Incident: Model, Content {
    static let schema = "incidents"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "image_file")
    var imageFile: ByteBuffer

    @Field(key: "image_filename")
    var imageFilename: String

    @Field(key: "image_content_type")
    var imageContentType: String

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    @Field(key: "comment")
    var comment: String

    init() {}

    init(imageFile: ByteBuffer, imageFilename: String, imageContentType: String, latitude: Double, longitude: Double, comment: String) {
        self.imageFile = imageFile
        self.imageFilename = imageFilename
        self.imageContentType = imageContentType
        self.latitude = latitude
        self.longitude = longitude
        self.comment = comment
    }
}

extension ByteBuffer: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.getData(at: self.readerIndex, length: self.readableBytes))
    }
}

extension ByteBuffer: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        self = ByteBuffer(data: data)
    }
}
