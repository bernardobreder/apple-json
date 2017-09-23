//
//  ArrayJsonTests.swift
//  Json
//
//  Created by Bernardo Breder on 09/01/17.
//
//

import XCTest
import Foundation
@testable import Literal
@testable import Json

class ArrayJsonTests: XCTestCase {
    
    func testCleanNil() {
        XCTAssertEqual(Json([1, "a", 2]), Json([1, Json(), "a", Json(), 2]).clearNil())
        XCTAssertEqual([1, "a", 2].description, Json([1, "a", 2]).arrayOrSet.native.map({$0.rawValue}).description)
        XCTAssertEqual([Json]().description, Json([:]).arrayOrSet.native.description)
        XCTAssertEqual(try Json([1, 2]), Json([1, "a", 2]).array({ $0.remove(index: 1) }))
        XCTAssertEqual(Json([]), Json([1, "a", 2]).array({$0.clear()}).clearNil())
        XCTAssertEqual(Json([]), Json([]))
        XCTAssertEqual(try Json([1]), try Json([1]))
    }
    
}
