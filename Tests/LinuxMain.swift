//
//  JsonTests.swift
//  Json
//
//  Created by Bernardo Breder.
//
//

import XCTest
@testable import JsonTests

extension ArrayJsonTests {

	static var allTests : [(String, (ArrayJsonTests) -> () throws -> Void)] {
		return [
			("testCleanNil", testCleanNil),
		]
	}

}

extension JsonTests {

	static var allTests : [(String, (JsonTests) -> () throws -> Void)] {
		return [
			("testArray", testArray),
			("testArrayAs", testArrayAs),
			("testClone", testClone),
			("testCompare", testCompare),
			("testCreateArray", testCreateArray),
			("testCreateDic", testCreateDic),
			("testCreateInline", testCreateInline),
			("testData", testData),
			("testDicAssign", testDicAssign),
			("testDicInt", testDicInt),
			("testDicNil", testDicNil),
			("testDicString", testDicString),
			("testDictionary", testDictionary),
			("testEncode", testEncode),
			("testExample", testExample),
			("testJsonInline", testJsonInline),
			("testLiteral", testLiteral),
		]
	}

}

XCTMain([
	testCase(ArrayJsonTests.allTests),
	testCase(JsonTests.allTests),
])

