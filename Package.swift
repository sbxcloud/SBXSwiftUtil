import PackageDescription

let package = Package(
    name: "SBXSwiftUtil",
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git", majorVersion: 3)
    ]
)
