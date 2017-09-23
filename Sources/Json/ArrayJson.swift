//
//  ArrayJson.swift
//  Json
//
//  Created by Bernardo Breder on 08/01/17.
//
//

import Foundation

#if SWIFT_PACKAGE
    import Array
#endif

public class ArrayJson {
    
    var array: [Json]
    
    public convenience init() {
        self.init(array: [])
    }
    
    public init(array: [Json]) {
        self.array = array
    }
    
    public subscript(_ index: Int) -> Json {
        get { return array[index] }
        set { array[index] = newValue }
    }
    
    public var count: Int {
        return array.count
    }
    
    public var empty: Bool {
        return array.count == 0
    }
    
    @discardableResult
    public func clear() -> Self {
        array.removeAll()
        return self
    }
    
    @discardableResult
    public func append(_ json: Json) -> Self {
        array.append(json)
        return self
    }
    
    @discardableResult
    public func insert(_ json: Json, at: Int) -> Self {
        array.insert(json, at: at)
        return self
    }
    
    @discardableResult
    public func remove(index: Int) -> Self {
        array.remove(at: index)
        return self
    }
    
    @discardableResult
    public func remove(condition: (Int, Json) -> Bool) -> Self {
        array.remove(condition: condition, breakFirst: true)
        return self
    }
    
    @discardableResult
    public func removeAll(condition: (Int, Json) -> Bool) -> Self {
        array.remove(condition: condition, breakFirst: false)
        return self
    }
    
    @discardableResult
    public func update(condition: (Int, Json) -> Bool, update: (Int, Json) -> Json) -> Self {
        array.update(condition: condition, update: update, breakFirst: true)
        return self
    }
    
    @discardableResult
    public func updateAll(condition: (Int, Json) -> Bool, update: (Int, Json) -> Json) -> Self {
        array.update(condition: condition, update: update, breakFirst: false)
        return self
    }
    
    @discardableResult
    public func clearNil() -> Self {
        for index in (0 ..< array.count).reversed() {
            let item = array[index]
            item.clearNil()
            if item.empty || item.array?.empty ?? false || item.dic?.empty ?? false { array.remove(at: index) }
        }
        return self
    }
    
    @discardableResult
    public func sort(by: (Json, Json) -> Bool) -> Self {
        array.sort(by: by)
        return self
    }
    
    public var native: [Json] {
        return array
    }
    
}

extension ArrayJson {
    
    public func jsonToInlineString(sorted: Bool = false) -> String {
        if array.isEmpty { return "[]" }
        return array.map({ (item) -> Any in
            switch item.type {
            case .array, .dictionary:
                return item.jsonToInlineString(sorted: sorted)
            default:
                return item.rawValue
            }
        }).description
    }
    
}

extension ArrayJson {
    
    public func clone() -> ArrayJson {
        return ArrayJson(array: array.map{$0.clone()})
    }
    
}

extension ArrayJson {
    
    public var rawValue: [Any] {
        return array.map {$0.rawValue}
    }
    
}

extension ArrayJson: CustomStringConvertible {
    
    public var description: String {
        return array.description
    }
    
}
