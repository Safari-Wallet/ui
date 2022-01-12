// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

var pathArray = #file.components(separatedBy: "/")
pathArray.remove(at: pathArray.count - 2)

let rootPackage = try String(contentsOfFile: pathArray.joined(separator: "/"), encoding: String.Encoding.utf8)
let range = NSRange(location: 0, length: rootPackage.count)

func getPackageRegExp(requirement: String) -> NSRegularExpression {
    return try! NSRegularExpression(pattern: #"\.package\((?:name:\s*"(.*)",|)\s*url:\s*"(.*)",\s*.\#(requirement)\)"#)
}

extension Sequence {
    public func regexToDependency(_ transform: (String?, String, String) -> Package.Dependency) -> [Package.Dependency] {
        var result = [Package.Dependency]()

        for item in (self as! [NSTextCheckingResult]) {
            let nameRange = Range(item.range(at: 1), in: rootPackage)
            let name = nameRange != nil ? String(rootPackage[nameRange!]) : nil
            let url = String(rootPackage[Range(item.range(at: 2), in: rootPackage)!])
            let last = String(rootPackage[Range(item.range(at: 3), in: rootPackage)!])
            result.append(transform(name, url, last))
        }

        return result
    }
}

/// Parsing `upToNextMajor(from:)`
let upToNextMajorDependencies = getPackageRegExp(requirement: #"upToNextMajor\(from:\s*"(.*)"\)"#)
    .matches(in: rootPackage, range: range)
    .regexToDependency{ .package(name: $0, url: $1, .upToNextMajor(from: .init(stringLiteral: $2))) }

/// Parsing `upToNextMinor(from:)`
let upToNextMinorDependencies = getPackageRegExp(requirement: #"upToNextMinor\(from:\s*"(.*)"\)"#)
    .matches(in: rootPackage, range: range)
    .regexToDependency{ .package(name: $0, url: $1, .upToNextMinor(from: .init(stringLiteral: $2))) }

/// Parsing `revision(_:)`
let revisionDependencies = getPackageRegExp(requirement: #"revision\(\s*"(.*)"\)"#)
    .matches(in: rootPackage, range: range)
    .regexToDependency{ .package(name: $0, url: $1, .revision($2)) }

/// Parsing `exact(_:)`
let exactDependencies = getPackageRegExp(requirement: #"exact\(\s*"(.*)"\)"#)
    .matches(in: rootPackage, range: range)
    .regexToDependency{ .package(name: $0, url: $1, .exact(.init(stringLiteral: $2))) }

/// Parsing `branch(_:)`
let branchDependencies = getPackageRegExp(requirement: #"branch\(\s*"(.*)"\)"#)
    .matches(in: rootPackage, range: range)
    .regexToDependency{ .package(name: $0, url: $1, .branch($2)) }


let package = Package(
    name: "SafariWalletCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
    ],
    products: [
        .library(
            name: "SafariWalletCore",
            targets: ["SafariWalletCore"]),
    ],
    dependencies: upToNextMajorDependencies + upToNextMinorDependencies + revisionDependencies + exactDependencies + branchDependencies,
    targets: [
        .target(
            name: "SafariWalletCore",
            dependencies: ["MEWwalletKit", "SocketIO"],
            path: "Source"),
        .testTarget(
            name: "SafariWalletCoreTests",
            dependencies: ["SafariWalletCore", "MEWwalletKit"],
            path: "Tests"),
    ]
)
