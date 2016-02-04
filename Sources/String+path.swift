/* POSIX path manipulations */

extension String {
    /** return the base name of a file  */
    var pathBaseName: String {
        return self.characters.split("/").last.map { String($0) } ?? self
    }

    /** Return the directory part of a pathname if there is one, or nil if not; 
        i.e., "/etc/passwd".pathDirectoryName yields "/etc", whereas
        "passwd".pathDirectoryName yields nil */
    var pathDirectoryName: String? {
        let dirComponents = self.characters.split("/").dropLast(1)
        if dirComponents.count > 0 {
            return dirComponents.map { String($0) }.joinWithSeparator("/") 
        } else {
            return nil
        }
    }
}