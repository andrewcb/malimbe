import PackageDescription

let package = Package(
    name: "testserver",
    dependencies: [
        .Package(url: "https://github.com/johnno1962/NSLinux.git", majorVersion: 1),
    ]
)