//
//  DictionaryJson.swift
//  Json
//
//  Created by Bernardo Breder on 09/01/17.
//
//

import Foundation

public class DictionaryJson {
    
    var dic: [String: Json]
    
    public init() {
        self.dic = [:]
    }
    
    public init(dic: [String: Json]) {
        self.dic = dic
    }
    
    public init(array: [(key: String, value: Json)]) {
        self.dic = [String: Json](minimumCapacity: array.count)
        for item in array {
            if !item.value.empty {
                dic[item.key] = item.value
            }
        }
    }
    
    public subscript(_ key: String) -> Json? {
        get { return dic[key] }
        set { dic[key] = newValue }
    }
    
    public var count: Int {
        return dic.count
    }
    
    public var keys: [String] {
        return dic.keys.map({$0})
    }
    
    public var intValues: [String: Int]? {
        return typedValues(function: { key, value in value.int })
    }
    
    public var doubleValues: [String: Double]? {
        return typedValues(function: { key, value in value.double })
    }
    
    public var stringValues: [String: String]? {
        return typedValues(function: { key, value in value.string })
    }
    
    public func typedValues<T>(function: (String, Json) -> T?) -> [String: T] {
        var result: [String: T] = [String: T](minimumCapacity: dic.count)
        for item in dic {
            if let value = function(item.key, item.value) {
                result[item.key] = value
            }
        }
        return result
    }
    
    @discardableResult
    public func remove(key: String) -> Self {
        dic.removeValue(forKey: key)
        return self
    }
    
    @discardableResult
    public func clearNil() -> Self {
        for entry in dic {
            let value = entry.value
            value.clearNil()
            if value.dic?.empty ?? false || value.array?.empty ?? false { value.clear() }
            if value.empty { dic.removeValue(forKey: entry.key) }
        }
        return self
    }
    
    public var empty: Bool {
        return dic.count == 0
    }
    
    @discardableResult
    public func clear() -> Self {
        dic.removeAll(keepingCapacity: false)
        return self
    }
    
    public var native: [String: Json] {
        return dic
    }
    
}

extension DictionaryJson {
    
    public func jsonToInlineString(sorted: Bool = false) -> String {
        if dic.isEmpty { return "{}" }
        let array: [(key: String, value: Json)]
        if sorted {
            let arraySorted = dic.sorted(by: { a, b in
                if let _ = a.value.dic {
                    if let _ = b.value.dic { return a.key <= b.key }
                    else if let _ = b.value.array { return false }
                    else { return false }
                } else if let _ = a.value.array {
                    if let _ = b.value.dic { return true }
                    else if let _ = b.value.array { return a.key <= b.key }
                    else { return false }
                } else {
                    if let _ = b.value.dic { return true }
                    else if let _ = b.value.array { return true }
                    else { return a.key <= b.key }
                }
            })
            array = arraySorted.map { e in (e.key, e.value) }
        } else {
            array = dic.map {($0.0, $0.1)}
        }
        let jsonArray: [(key: String, value: CustomStringConvertible)] = array.map { (item) -> (String, CustomStringConvertible) in
            let key = "\"" + item.key + "\""
            switch item.value.type {
            case .array, .dictionary, .string:
                return (key, item.value.jsonToInlineString(sorted: sorted))
            default:
                return (key, item.value.rawValue)
            }
        }
        var result = "{ "
        for i in 0 ..< jsonArray.count {
            if i != 0 { result += ", " }
            let item = jsonArray[i]
            result += item.0 + ": " + item.1.description
        }
        result += " }"
        return result
    }
    
}

extension DictionaryJson {
    
    public func clone() -> DictionaryJson {
        return DictionaryJson(array: dic.map{($0, $1.clone())})
    }
    
}

extension DictionaryJson {
    
    public var rawValue: [String: Any] {
        var result: [String: Any] = [String: Any](minimumCapacity: dic.count)
        for entry in native {
            if !entry.value.empty {
                result[entry.key] = entry.value.rawValue
            }
        }
        return result
    }
    
}

extension DictionaryJson: CustomStringConvertible {
    
    public var description: String {
        return native.description
    }
    
}
