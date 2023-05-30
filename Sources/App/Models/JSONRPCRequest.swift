//
//  JSONRPCRequest.swift
//  
//
//  Created by Eugene Ned on 18.05.2023.
//

import Foundation
import Vapor

struct JSONRPCRequest: Codable {
    let jsonrpc: String
    let method: String?
    let params: [String: Any]?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case method
        case params
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        method = try container.decodeIfPresent(String.self, forKey: .method)
        let tmpParams = try container.decodeIfPresent([String: JSONAny].self, forKey: .params)
        params = try tmpParams?.mapValues {
            try $0.getValue()
        }
        id = try container.decodeIfPresent(String.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encodeIfPresent(method, forKey: .method)
        let tmpParams = try params?.mapValues { try JSONAny($0) }
        try container.encode(tmpParams, forKey: .params)
        try container.encodeIfPresent(id, forKey: .id)
    }
}
