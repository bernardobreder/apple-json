//
//  Package.swift
//  Json
//
//

import PackageDescription

let package = Package(
	name: "Json",
	targets: [
		Target(name: "Json", dependencies: ["Array", "IndexLiteral", "Literal"]),
		Target(name: "Array", dependencies: []),
		Target(name: "IndexLiteral", dependencies: []),
		Target(name: "Literal", dependencies: []),
	]
)

