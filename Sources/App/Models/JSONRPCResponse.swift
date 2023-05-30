//
//  JSONRPCResponse.swift
//  
//
//  Created by Eugene Ned on 18.05.2023.
//

import Foundation
import Vapor

struct JSONRPCResponse: Codable, ResponseEncodable {
    func encodeResponse(for request: Vapor.Request) -> NIOCore.EventLoopFuture<Vapor.Response> {
        do {
            let data = try JSONEncoder().encode(self)
            let response = Response(status: .ok, body: .init(data: data))
            response.headers.replaceOrAdd(name: .contentType, value: "application/json")
            return request.eventLoop.makeSucceededFuture(response)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
    
    let jsonrpc: String
    let result: JSONRPCResult?
    let id: String?
}

struct JSONRPCError: Codable {
    let code: Int
    let message: String
}

enum JSONRPCResult: Codable {
    case success(Any)
    case failure(JSONRPCError)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let successValue = try container.decode(JSONAny.self, forKey: .result)
            self = .success(try successValue.getValue())
        } catch {
            let errorValue = try container.decode(JSONRPCError.self, forKey: .error)
            self = .failure(errorValue)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .success(let value):
            let jsonAnyValue = try JSONAny(value)
            try container.encode(jsonAnyValue, forKey: .result)
        case .failure(let error):
            try container.encode(error, forKey: .error)
        }
    }
    
    enum CodingKeys: CodingKey {
        case result
        case error
    }
}
