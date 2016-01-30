import PackageDescription

let package = Package(
    name: "aserver",
    dependencies: [
        .Package(url: "https://github.com/johnno1962/NSLinux.git", majorVersion: 1),
    ]
)