//
//  Json.swift
//  Json
//
//  Created by Bernardo Breder on 09/01/17.
//
//

import Foundation

#if SWIFT_PACKAGE
    import Array
    import Literal
    import IndexLiteral
#endif
    
public class Json: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral,ExpressibleByBooleanLiteral, ExpressibleByFloatLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByNilLiteral {
    
    public internal(set) var value: Any
    
    public internal(set) var type: JsonType
    
    public convenience init() {
        self.init(type: .null, value: NSNull())
    }
    
    public convenience init(_ value: String) {
        self.init(type: .string, value: value)
    }
    
    public convenience init(_ value: Bool) {
        self.init(type: .bool, value: value)
    }
    
    public convenience init(_ value: Int) {
        self.init(type: .int, value: value)
    }
    
    public convenience init(_ value: Float) {
        self.init(type: .double, value: Double(value))
    }
    
    public convenience init(_ value: Double) {
        self.init(type: .double, value: value)
    }
    
    public convenience init(_ value: [Any]) {
        let value = ArrayJson(array: value.map{try? Json($0)}.filter{$0 != nil}.map{$0!})
        self.init(type: .array, value: value)
    }
    
    public convenience init(_ value: [String: Any]) {
        var dic: [String: Json] = [:]
        for entry in value {
            if let json = try? Json(entry.value) {
                dic[entry.key] = json
            }
        }
        self.init(type: .dictionary, value: DictionaryJson(dic: dic))
    }
    
    public convenience init(_ value: Literal) {
        switch value.type {
        case .string:
            self.init(value.string!)
        case .int:
            self.init(value.int!)
        case .double:
            self.init(value.int!)
        case .bool:
            self.init(value.bool!)
        }
    }
    
    public convenience init(_ value: Any) throws {
        switch value {
        case let json as Json:
            self.init(type: json.type, value: json.value)
        case let number as Int:
            self.init(number)
        case let number as Float:
            self.init(number)
        case let number as Double:
            self.init(number)
        case let bool as Bool:
            self.init(bool)
        case let string as String:
            self.init(string)
        case _ as NSNull:
            self.init()
        case let array as [Any]:
            self.init(array)
        case let dictionary as [String : Any]:
            self.init(dictionary)
        default:
            throw JsonError.jsonValue
        }
    }
    
    public convenience init(data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else { throw JsonError.dataToString }
        if string.hasPrefix("[") || string.hasPrefix("{") {
            try self.init(JSONSerialization.jsonObject(with: data, options: .allowFragments))
        } else if let bool = Bool(string) {
            self.init(bool)
        } else if let int = Int(string) {
            self.init(int)
        } else if let double = Double(string) {
            self.init(double)
        } else {
            self.init(string.substring(with: string.index(after: string.startIndex) ..< string.index(before: string.endIndex)))
        }
    }
    
    internal init(type: JsonType, value: Any) {
        self.type = type
        self.value = value
    }
    
    public required convenience init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public required convenience init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public required convenience init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public required convenience init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
    
    public required convenience init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
    
    public required convenience init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
    
    public required convenience init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
    
    public required convenience init(dictionaryLiteral elements: (String, Any)...) {
        let array = elements
        self.init(dictionaryLiteral: array)
    }
    
    public convenience init(dictionaryLiteral elements: [(String, Any)]) {
        let jsonFromDictionaryLiteral: ([String : Any]) -> Json = { dictionary in
            let initializeElement = Array(dictionary.keys).flatMap { key -> (String, Any)? in
                if let value = dictionary[key] {
                    return (key, value)
                }
                return nil
            }
            return Json(dictionaryLiteral: initializeElement)
        }
        var dict = [String : Any](minimumCapacity: elements.count)
        for element in elements {
            let elementToSet: Any?
            if let json = element.1 as? Json {
                elementToSet = json.value
            } else if let jsonArray = element.1 as? [Json] {
                elementToSet = Json(jsonArray.map{$0.value}).value
            } else if let dictionary = element.1 as? [String : Any] {
                elementToSet = jsonFromDictionaryLiteral(dictionary).value
            } else if let dictArray = element.1 as? [[String : Any]] {
                let jsonArray = dictArray.map { jsonFromDictionaryLiteral($0) }
                elementToSet = Json(jsonArray.map{$0.value}).value
            } else {
                elementToSet = element.1
            }
            dict[element.0] = elementToSet
        }
        self.init(dict)
    }
    
    public required convenience init(nilLiteral: ()) {
        self.init()
    }
    
}

extension Json {
    
    public var rawArrayValue: ArrayJson? {
        guard type == .array else { return nil }
        return value as? ArrayJson
    }
    
    public var rawDictionaryValue: DictionaryJson? {
        guard type == .dictionary else { return nil }
        return value as? DictionaryJson
    }
    
    public var rawBoolValue: Bool? {
        guard type == .bool else { return nil }
        return value as? Bool
    }
    
    public var rawStringValue: String? {
        guard type == .string else { return nil }
        return value as? String
    }
    
    public var rawIntValue: Int? {
        guard type == .int else { return nil }
        return value as? Int
    }
    
    public var rawDoubleValue: Double? {
        guard type == .double else { return nil }
        return value as? Double
    }
    
    public var rawValue: CustomStringConvertible {
        switch self.type {
        case .array:
            return rawArrayValue!.rawValue
        case .dictionary:
            return rawDictionaryValue!.rawValue
        case .string:
            return rawStringValue!
        case .int:
            return rawIntValue!
        case .double:
            return rawDoubleValue!
        case .bool:
            return rawBoolValue!
        case .null:
            return NSNull()
        }
    }
    
}

extension Json {
    
    public subscript(index: Int) -> Json {
        get {
            guard self.type == .array else { return Json() }
            guard let array = rawArrayValue else { return Json() }
            guard index >= 0 && index < array.count else { return Json() }
            return array[index]
        }
        set {
            guard self.type == .array else { return }
            guard let array = rawArrayValue else { return }
            while index >= array.count { array.append(Json()) }
            guard index >= 0 && index < array.count else { return }
            if newValue.empty { array.remove(index: index) }
            else { array[index] = newValue }
        }
    }
    
    public subscript(key: String) -> Json {
        get {
            guard self.type == .dictionary else { return Json() }
            guard let dic = rawDictionaryValue else { return Json() }
            return dic[key] ?? Json()
        }
        set {
            guard self.type == .dictionary else { return }
            guard let dic = rawDictionaryValue else { return }
            if newValue.empty { dic.remove(key: key) }
            else { dic[key] = newValue }
        }
    }
    
    public subscript(array: [IndexLiteral]) -> Json {
        get {
            var aux = self
            for item in array {
                item.literal(string: {aux = aux[$0]}, int: {aux = aux[$0]})
            }
            return aux
        }
        set {
            var aux: Json = self
            for i in 0 ..< array.count - 1 {
                let item: IndexLiteral = array[i]
                let next: Json = aux[item]
                if next.empty {
                    let value: Json = array[i+1].literal(string: {_ -> Json in Json([:])}, int: {_ -> Json in Json([])})
                    aux[item] = value
                    aux = value
                } else { aux = next }
            }
            if let last = array.last { aux[last] = newValue }
        }
    }
    
    public subscript(literal: IndexLiteral) -> Json {
        get {
            return literal.literal(string: {
                _ = dicOrSet
                return self[$0]
            }, int: {
                _ = arrayOrSet
                return self[$0]})
        }
        set {
            return literal.literal(string: {
                _ = dicOrSet
                self[$0] = newValue
            }, int: {
                _ = arrayOrSet
                self[$0] = newValue
            })
        }
    }
    
    @discardableResult
    internal func set(type: JsonType, value: Any) -> Self {
        self.type = type
        self.value = value
        return self
    }
    
}

extension Json {
    
    public func jsonToString() throws -> String {
        let raw = rawValue
        switch type {
        case .array, .dictionary:
            let data: Data = try JSONSerialization.data(withJSONObject: raw, options: .prettyPrinted)
            guard let string = String(data: data, encoding: .utf8) else { throw JsonError.stringToData }
            return string
        case .string:
            return "\"" + rawStringValue! + "\""
        default:
            return raw.description
        }
    }
    
    public func jsonToInlineString(sorted: Bool = false) -> String {
        switch type {
        case .array:
            return rawArrayValue!.jsonToInlineString(sorted: sorted)
        case .dictionary:
            return rawDictionaryValue!.jsonToInlineString(sorted: sorted)
        case .null:
            return "null"
        case .string:
            return "\"" + rawStringValue! + "\""
        case .int:
            return rawIntValue!.description
        case .double:
            return rawDoubleValue!.description
        case .bool:
            return rawBoolValue!.description
        }
    }
    
    public func data() throws -> Data {
        let raw = rawValue
        switch type {
        case .array, .dictionary:
            return try JSONSerialization.data(withJSONObject: raw, options: .prettyPrinted)
        case .string:
            let string = "\"" + rawStringValue! + "\""
            guard let data = string.data(using: .utf8) else { throw JsonError.stringToData }
            return data
        default:
            guard let data = raw.description.data(using: .utf8) else { throw JsonError.stringToData }
            return data
        }
    }

}

extension Json {
    
    public convenience init?(encoded: String) {
        guard let decoded = Json.decode(encoded: encoded, offsetBy: encoded.startIndex) else { return nil }
        guard let data = decoded.data(using: .utf8) else { return nil }
        do { try self.init(data: data) } catch { return nil }
    }
    
    public class func decode(encoded: String, offsetBy: String.Index) -> String? {
        let magic = "Json[".characters
        guard encoded.substring(from: offsetBy).hasPrefix("Json[") else { return nil }
        guard let range = encoded.range(of: "]=") else { return nil }
        guard let index = encoded.index(offsetBy, offsetBy: magic.count, limitedBy: encoded.endIndex) else { return nil }
        guard let length = Int(encoded.substring(with: index ..< range.lowerBound)) else { return nil }
        guard let endContentIndex = encoded.index(range.upperBound, offsetBy: length, limitedBy: encoded.endIndex) else { return nil }
        return encoded.substring(with: range.upperBound ..< endContentIndex)
    }
    
    public func encode() throws -> String {
        let string = try jsonToString()
        return "Json[" + String(string.characters.count) + "]=" + string
    }
    
}

extension Json {
    
    public var exists: Bool {
        switch type {
        case .null:
            return false
        default:
            return true
        }
    }
    
    public var empty: Bool {
        switch type {
        case .null:
            return true
        default:
            return false
        }
    }
    
    public func clear() {
        set(type: .null, value: NSNull())
    }
    
}

extension Json {
    
    public func clone() -> Json {
        switch type {
        case .array:
            let value = rawArrayValue!.clone()
            let json = Json(type: .array, value: value)
            return json
        case .dictionary:
            let value = rawDictionaryValue!.clone()
            let json = Json(type: .dictionary, value: value)
            return json
        default:
            return Json(type: type, value: value)
        }
    }
    
}

extension Json {
    
    public var literal: Literal? {
        get {
            switch type {
            case .string:
                return Literal(rawStringValue!)
            case .int:
                return Literal(rawIntValue!)
            case .double:
                return Literal(rawDoubleValue!)
            case .bool:
                return Literal(rawBoolValue!)
            default:
                return nil
            }
        } set {
            if let hasNewValue = newValue {
                switch hasNewValue.type {
                case .string:
                    set(type: .string, value: hasNewValue.string!)
                case .int:
                    set(type: .int, value: hasNewValue.int!)
                case .double:
                    set(type: .double, value: hasNewValue.double!)
                case .bool:
                    set(type: .bool, value: hasNewValue.bool!)
                }
            } else {
                set(type: .null, value: NSNull())
            }
        }
    }
    
    public var string: String? {
        get { return rawStringValue }
        set {
            guard type == .string else { return }
            set(type: newValue == nil ? .null : .string, value: newValue == nil ? NSNull() : newValue!)
        }
    }
    
    public var int: Int? {
        get { return rawIntValue }
        set {
            guard type == .int else { return }
            set(type: newValue == nil ? .null : .int, value: newValue == nil ? NSNull() : newValue!)
        }
    }
    
    public var double: Double? {
        get { return rawDoubleValue }
        set {
            guard type == .double else { return }
            set(type: newValue == nil ? .null : .double, value: newValue == nil ? NSNull() : newValue!)
        }
    }
    
    public var bool: Bool? {
        get { return rawBoolValue }
        set {
            guard type == .bool else { return }
            set(type: newValue == nil ? .null : .bool, value: newValue == nil ? NSNull() : newValue! ? 1 : 0)
        }
    }
    
    public var array: ArrayJson? {
        get { return rawArrayValue }
        set {
            guard type == .array else { return }
            set(type: newValue == nil ? .null : .array, value: newValue == nil ? NSNull() : newValue!)
        }
    }
    
    public var arrayAsString: [String] {
        return (rawArrayValue ?? ArrayJson(array: [])).array.map({$0.string}).filter{$0 != nil}.map{$0!}
    }
    
    public var arrayAsInt: [Int] {
        return (rawArrayValue ?? ArrayJson(array: [])).array.map({$0.int}).filter{$0 != nil}.map{$0!}
    }
    
    public var arrayAsDouble: [Double] {
        return (rawArrayValue ?? ArrayJson(array: [])).array.map({$0.double}).filter{$0 != nil}.map{$0!}
    }
    
    public var arrayAsBool: [Bool] {
        return (rawArrayValue ?? ArrayJson(array: [])).array.map({$0.bool}).filter{$0 != nil}.map{$0!}
    }
    
    public var dic: DictionaryJson? {
        get { return rawDictionaryValue }
        set {
            guard type == .dictionary else { return }
            set(type: newValue == nil ? .null : .dictionary, value: newValue == nil ? NSNull() : newValue!)
        }
    }
    
}

extension Json {
    
    public var dicOrSet: DictionaryJson {
        if type != .dictionary { set(type: .dictionary, value: DictionaryJson()) }
        return rawDictionaryValue!
    }
    
    public var arrayOrSet: ArrayJson {
        if type != .array { set(type: .array, value: ArrayJson()) }
        return rawArrayValue!
    }
    
}

extension Json {
    
    @discardableResult
    public func clearNil() -> Self {
        switch self.type {
        case .array:
            rawArrayValue!.clearNil()
        case .dictionary:
            rawDictionaryValue!.clearNil()
        default:
            return self
        }
        return self
    }
    
}

extension Json {
    
    @discardableResult
    public func string(_ f: (String) -> Void) -> Self {
        if let string = self.string {
            f(string)
        }
        return self
    }
    
    @discardableResult
    public func int(_ f: (Int) -> Void) -> Self {
        if let int = self.int {
            f(int)
        }
        return self
    }
    
    @discardableResult
    public func double(_ f: (Double) -> Void) -> Self {
        if let double = self.double {
            f(double)
        }
        return self
    }
    
    @discardableResult
    public func bool(_ f: (Bool) -> Void) -> Self {
        if let bool = self.bool {
            f(bool)
        }
        return self
    }
    
    @discardableResult
    public func array(_ f: (ArrayJson) -> Void) -> Self {
        if let array = self.array {
            f(array)
        }
        return self
    }
    
    @discardableResult
    public func dic(_ f: (DictionaryJson) -> Void) -> Self {
        if let dic = self.dic {
            f(dic)
        }
        return self
    }
    
    @discardableResult
    public func stringRet<T>(_ f: (String) -> T) -> T? {
        if let string = self.string {
            return f(string)
        }
        return nil
    }
    
    @discardableResult
    public func intRet<T>(_ f: (Int) -> T) -> T? {
        if let int = self.int {
            return f(int)
        }
        return nil
    }
    
    @discardableResult
    public func doubleRet<T>(_ f: (Double) -> T) -> T? {
        if let double = self.double {
            return f(double)
        }
        return nil
    }
    
    @discardableResult
    public func boolRet<T>(_ f: (Bool) -> T) -> T? {
        if let bool = self.bool {
            return f(bool)
        }
        return nil
    }
    
    @discardableResult
    public func arrayRet<T>(_ f: (ArrayJson) -> T) -> T? {
        if let array = self.array {
            return f(array)
        }
        return nil
    }
    
    @discardableResult
    public func dicRet<T>(_ f: (DictionaryJson) -> T) -> T? {
        if let dic = self.dic {
            return f(dic)
        }
        return nil
    }
    
}

extension Json: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return (try? jsonToString()) ?? ""
    }
    
    public var debugDescription: String { return description }
    
}

extension Json: Equatable {
    
    public static func ==(lhs: Json, rhs: Json) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.int, .int):
            return lhs.rawIntValue == rhs.rawIntValue
        case (.double, .double):
            return lhs.rawDoubleValue == rhs.rawDoubleValue
        case (.bool, .bool):
            return lhs.rawBoolValue == rhs.rawBoolValue
        case (.string, .string):
            return lhs.rawStringValue == rhs.rawStringValue
        case (.array, .array):
            return lhs.rawArrayValue!.array == rhs.rawArrayValue!.array
        case (.dictionary, .dictionary):
            return lhs.rawDictionaryValue!.dic == rhs.rawDictionaryValue!.dic
        case (.null, .null):
            return true
        default:
            return false
        }
    }
    
}

public enum JsonType {
    case int
    case double
    case bool
    case string
    case array
    case dictionary
    case null
}

public enum JsonError: Error {
    case jsonValue
    case jsonToString
    case stringToData
    case dataToString
    case stringToJson
}
