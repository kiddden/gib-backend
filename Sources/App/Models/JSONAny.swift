//
//  JSONAny.swift
//  
//
//  Created by Eugene Ned on 30.05.2023.
//

import Foundation
import Vapor

struct JSONAny: Codable {
    private var value: Any
    
    init(_ value: Any) throws {
        if let number = value as? NSNumber {
            self.value = number
        } else if let string = value as? String {
            self.value = string
        } else if let bool = value as? Bool {
            self.value = bool
        } else if let incident = value as? Incident {
            self.value = incident
        } else if let incidents = value as? [Incident] {
            self.value = incidents
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Invalid JSON value"))
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let incident = try? container.decode(Incident.self) {
            value = incident
        } else if let incidents = try? container.decode([Incident].self) {
            value = incidents
        } else if let file = try? container.decode(File.self) {
            value = file
        } else {
            throw DecodingError.typeMismatch(Any.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode JSON value"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let incident = value as? Incident {
            try container.encode(incident)
        } else if let incidents = value as? [Incident] {
            try container.encode(incidents)
        } else {
            let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Failed to encode JSON value")
            throw EncodingError.invalidValue(value, context)
        }
    }
    
    func getValue<T>() throws -> T {
        guard let typedValue = value as? T else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: [], debugDescription: "Failed to get typed value from JSONAny"))
        }
        return typedValue
    }
}
