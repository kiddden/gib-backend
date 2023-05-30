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
        
        incidentsRoute.post("jsonrpc", use: handleJSONRPC)
    }
    
    private func create(req: Request) throws -> EventLoopFuture<Incident> { // For REST API
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
    
    private func getAll(req: Request) throws -> EventLoopFuture<[Incident]> {
        return Incident.query(on: req.db).all()
    }
    
    func handleJSONRPC(req: Request) throws -> EventLoopFuture<JSONRPCResponse> {
        let rpcReq = try req.content.decode(JSONRPCRequest.self)
        
        // Check if the required fields are present in the request
        guard rpcReq.jsonrpc == "2.0",
              let method = rpcReq.method,
              let id = rpcReq.id else {
            throw Abort(.badRequest)
        }
        
        // Call the appropriate function based on rpcReq.method
        switch method {
        case "create":
            let params = rpcReq.params
            
            guard let params = params,
                  let imageFile = params["imageFile"].wrappedValue as? File,
                  let latitude = params["latitude"] as? Double,
                  let longitude = params["longitude"] as? Double,
                  let comment = params["comment"] as? String else {
                let error = JSONRPCError(code: -32602, message: "Invalid params")
                let response = JSONRPCResponse(jsonrpc: "2.0", result: .failure(error), id: id)
                return req.eventLoop.makeSucceededFuture(response)
            }
            
            let incident = Incident(
                imageFile: imageFile.data,
                imageFilename: imageFile.filename,
                imageContentType: imageFile.contentType?.serialize() ?? "",
                latitude: latitude,
                longitude: longitude,
                comment: comment
            )

            return incident.save(on: req.db).map {
                JSONRPCResponse(jsonrpc: "2.0", result: .success("Created incident"), id: id)
            }
        case "getAll":
            return Incident.query(on: req.db).all().map { incidents in
                JSONRPCResponse(jsonrpc: "2.0", result: .success(incidents), id: id)
            }
            
        default:
            let error = JSONRPCError(code: -32601, message: "Method not found.")
            let response = JSONRPCResponse(jsonrpc: "2.0", result: .failure(error), id: id)
            return req.eventLoop.makeSucceededFuture(response)
        }
    }
}

