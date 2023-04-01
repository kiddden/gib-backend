//
//  File.swift
//  
//
//  Created by Eugene Ned on 01.04.2023.
//

import Fluent

struct CreateIncident: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("incidents")
            .id()
            .field("image_file", .data, .required)
            .field("image_filename", .string, .required)
            .field("image_content_type", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("comment", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("incidents").delete()
    }
}
