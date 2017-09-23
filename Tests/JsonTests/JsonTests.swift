//
//  ArrayJsonTests.swift
//  Json
//
//  Created by Bernardo Breder on 09/01/17.
//
//

import XCTest
import Foundation
@testable import Json

class JsonTests: XCTestCase {
    
    func testCreateDic() throws {
        let json = Json([:])
        json[["a", "b", "c"]] = "d"
        json[["a", "b", "d"]] = 1
        json["a"]["b"]["e"] = 1.2
        json["a"]["b"]["f"] = true
        json["a"]["b"]["g"] = ["a", true, 1.3]
        XCTAssertEqual("d", json["a"]["b"]["c"].string)
        XCTAssertEqual(1, json["a"]["b"]["d"].int)
        XCTAssertEqual(1.2, json["a"]["b"]["e"].double)
        XCTAssertEqual(true, json["a"]["b"]["f"].bool)
        XCTAssertEqual("a", json["a"]["b"]["g"][0].string)
        XCTAssertEqual(true, json["a"]["b"]["g"][1].bool)
        XCTAssertEqual(1.3, json["a"]["b"]["g"][2].double)
    }
    
    func testArrayAs() throws {
        XCTAssertEqual(["a"], Json(["a", 1]).arrayAsString)
        XCTAssertEqual([1], Json(["a", 1]).arrayAsInt)
        XCTAssertEqual([true], Json(["a", true]).arrayAsBool)
    }
    
    func testData() throws {
        XCTAssertEqual(Json(1), try Json(data: Json(1).data()))
        XCTAssertEqual(Json(1.2), try Json(data: Json(1.2).data()))
        XCTAssertEqual(Json("abc"), try Json(data: Json("abc").data()))
        XCTAssertEqual(Json(true), try Json(data: Json(true).data()))
    }
    
    func testCreateArray() throws {
        let json = Json([:])
        json[["a", 0, "b"]] = "c"
        json[["a", 1, "d"]] = "e"
        XCTAssertEqual("c", json["a"][0]["b"].string)
        XCTAssertEqual("e", json["a"][1]["d"].string)
    }
    
    func testCompare() throws {
        let a = try Json(["id": 1]).rawDictionaryValue!
        let b = try Json(["id": 1]).rawDictionaryValue!
        XCTAssertTrue(a["id"]! == b["id"]!)
        XCTAssertTrue(NSMutableArray(array: [1, "a"]) == NSMutableArray(array: [1, "a"]))
        XCTAssertTrue(Json("a") == Json("a"))
        XCTAssertTrue(Json(1) == Json(1))
        XCTAssertTrue(Json(1.2) == Json(1.2))
        XCTAssertTrue(Json(true) == Json(true))
        XCTAssertTrue(Json([1, "a"]) == Json([1, "a"]))
        XCTAssertTrue(try Json(["id": 1]) == Json(["id": 1]))
    }
    
    func testArray() throws {
        var json = Json([1, "a", 3])
        var data = try json.data()
        json = try Json(data: data)
        XCTAssertEqual(1, json[0].int)
        XCTAssertEqual("a", json[1].string)
        XCTAssertEqual(3, json[2].int)
        json[3] = "b"
        XCTAssertEqual("b", json[3].string)
        data = try json.jsonToString().data(using: .utf8)!
        json = try Json(data: data)
        XCTAssertEqual("b", json[3].string)
    }
    
    func testDictionary() throws {
        var json = try Json(["id": 1])
        var data = try json.data()
        json = try Json(data: data)
        XCTAssertEqual(1, json["id"].int)
        json["name"] = Json("test")
        XCTAssertEqual("test", json["name"].string)
        data = try json.jsonToString().data(using: .utf8)!
        json = try Json(data: data)
        XCTAssertEqual("test", json["name"].string)
    }
    
    func testClone() throws {
        let left = Json(
            ["id": 1, "name": "Teste", "phones": [1234, 5678], "friends": [
                ["id": 2, "name": "friend1"], ["id": 3, "name": "friend2"]]
            ]
        )
        
        let center = left
        XCTAssertEqual(left, center)
        center["id"] = 2
        XCTAssertEqual(left, center)
        
        let right = left.clone()
        XCTAssertEqual(left, right)
        right["id"] = 3
        XCTAssertNotEqual(left, right)
    }
    
    func testExample() throws {
        let myjson = Json(
            ["id": 1, "name": "Teste", "phones": [1234, 5678], "friends": [
                ["id": 2, "name": "friend1"], ["id": 3, "name": "friend2"]]
            ]
        )
        let data = try myjson.jsonToString().data(using: .utf8)!
        let json = try Json(data: data)
        XCTAssertEqual(1, json["id"].int)
        XCTAssertEqual("Teste", json["name"].string)
        XCTAssertEqual(1234, json["phones"][0].int)
        XCTAssertEqual(2, json["friends"][0]["id"].int)
        XCTAssertEqual("friend1", json["friends"][0]["name"].string)
        XCTAssertTrue(json[0]["user"]["entities"]["url"]["urls"][0]["url"].empty)
        XCTAssertTrue(json[999999]["wrong_key"]["wrong_name"].empty)
    }
    
    func testDicInt() throws {
        XCTAssertEqual(try Json(["a": 1, "c": 3]).data(), try Json(Json(["a": 1, "b": "2", "c": 3]).dic?.intValues as Any).data())
        XCTAssertEqual(try Json(["a": 1, "c": 3]).data(), try Json(Json(data: Json(["a": 1, "b": "2", "c": 3]).data()).dic?.intValues as Any).data())
    }
    
    func testDicString() throws {
        XCTAssertEqual(try Json(["b": "2"]).data(), try Json(Json(["a": 1, "b": "2", "c": 3]).dic?.stringValues as Any).data())
        XCTAssertEqual(try Json(["b": "2"]).data(), try Json(Json(data: Json(["a": 1, "b": "2", "c": 3]).data()).dic?.stringValues as Any).data())
    }
    
    func testDicAssign() throws {
        let json = Json([:])
        json["a"] = [:]
        json["a"]["b"] = "aa"
        json["a"]["b"] = nil
        json["a"] = nil
        XCTAssertEqual(try Json([:]).jsonToString(), try json.jsonToString())
    }
    
    func testCreateInline() throws {
        let left = Json([:]), right = Json([:])
        left[["a", 0, "c"]] = "d"
        right["a"] = []
        right["a"][0] = [:]
        right["a"][0]["c"] = "d"
        XCTAssertEqual(try left.jsonToString(), try right.jsonToString())
    }
    
    func testDicNil() throws {
        XCTAssertEqual(try Json(["a": 1]).jsonToString(), try Json(["a": 1, "b": NSNull()]).jsonToString())
    }
    
    func testEncode() throws {
        XCTAssertEqual(try Json(["a": 1]), try Json(encoded: Json(["a": 1]).encode()))
        XCTAssertEqual(try Json([1]), try Json(encoded: Json([1]).encode()))
        XCTAssertEqual(Json(1), try Json(encoded: Json(1).encode()))
        XCTAssertEqual(Json("abc"), try Json(encoded: Json("abc").encode()))
    }
    
    func testJsonInline() throws {
        XCTAssertEqual("1", Json(1).jsonToInlineString())
        XCTAssertEqual("\"abc\"", Json("abc").jsonToInlineString())
        XCTAssertEqual("true", Json(true).jsonToInlineString())
        XCTAssertEqual("false", Json(false).jsonToInlineString())
        XCTAssertEqual("1.2", Json(1.2).jsonToInlineString())
        XCTAssertEqual("-10.234", Json(-10.234).jsonToInlineString())
        XCTAssertEqual("-0.234", Json(-0.234).jsonToInlineString())
        XCTAssertEqual("[]", Json([]).jsonToInlineString())
        XCTAssertEqual("{}", Json([:]).jsonToInlineString())
        XCTAssertEqual("[1]", try Json([1]).jsonToInlineString())
        XCTAssertEqual("[1, 2]", try Json([1,2]).jsonToInlineString())
        XCTAssertEqual("[1, 2, \"a\"]", Json([1,2,"a"]).jsonToInlineString())
        XCTAssertEqual("{ \"a\": 1 }", try Json(["a": 1]).jsonToInlineString())
        XCTAssertEqual("{ \"a\": 1, \"b\": \"c\" }", Json(["a": 1, "b": "c"]).jsonToInlineString(sorted: true))
        XCTAssertEqual("{ \"a\": 1, \"b\": \"c\", \"d\": { \"e\": { \"f\": 1 } } }", Json(["a": 1, "b": "c", "d": ["e": ["f": 1]]]).jsonToInlineString(sorted: true))
    }
    
    func testLiteral() throws {
        XCTAssertEqual(1, Json(1).literal)
        XCTAssertNotEqual("1", Json(1).literal)
        XCTAssertNotEqual(1.2, Json(1).literal)
        XCTAssertNotEqual(true, Json(1).literal)
        
        XCTAssertEqual(1.2, Json(1.2).literal)
        XCTAssertNotEqual("1", Json(1.2).literal)
        XCTAssertNotEqual(1, Json(1.2).literal)
        XCTAssertNotEqual(true, Json(1.2).literal)
        
        XCTAssertEqual("1", Json("1").literal)
        XCTAssertNotEqual(1, Json("1").literal)
        XCTAssertNotEqual(1.2, Json("1").literal)
        XCTAssertNotEqual(true, Json("1").literal)
        
        XCTAssertEqual(true, Json(true).literal)
        XCTAssertNotEqual("1", Json(true).literal)
        XCTAssertNotEqual(1.2, Json(true).literal)
        XCTAssertNotEqual(1, Json(true).literal)
        
        let a = Json(1)
        a.literal = nil
        XCTAssertNil(a[1].literal)
        
        a.literal = 1
        XCTAssertEqual(1, a.literal)
        
        a.literal = 1.2
        XCTAssertEqual(1.2, a.literal)
        
        a.literal = "abc"
        XCTAssertEqual("abc", a.literal)
        
        a.literal = true
        XCTAssertEqual(true, a.literal)
    }
    
}
