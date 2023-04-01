//
//  File.swift
//  
//
//  Created by Eugene Ned on 01.04.2023.
//

import Vapor

struct IncidentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let incidentsRoute = routes.grouped("incidents")
        incidentsRoute.post(use: create)
        incidentsRoute.get(use: getAll)
    }

    func create(req: Request) throws -> EventLoopFuture<Incident> {
        let upload = try req.content.decode(FileUpload.self)
        let incident = Incident(
            imageFile: upload.imageFile.data,
            imageFilename: upload.imageFile.filename,
            imageContentType: upload.imageFile.contentType?.serialize() ?? "",
            latitude: upload.latitude,
            longitude: upload.longitude,
            comment: upload.comment
        )
        return incident.save(on: req.db).map { incident }
    }

    func getAll(req: Request) throws -> EventLoopFuture<[Incident]> {
        return Incident.query(on: req.db).all()
    }
}

