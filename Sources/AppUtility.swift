/* Utility functions for use in configuring apps.
*/

/** Return the path of a file adjacent to the app executable. 
    Note: this will not work if chdir() has been called since the
    app was launched and the app launch path is relative.
*/

public func appRelativePath(path:String) -> String {
    let argv0 = Process.arguments[0]

    if let appPath = argv0.pathDirectoryName {
        return "\(appPath)/\(path)"
    } else {
        return path
    }
}