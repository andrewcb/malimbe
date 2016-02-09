/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */

/** Determine the most probable MIME Content-Type for a pathname, from its suffix.
 - parameter name: The pathname
 - returns: the MIME type string; if none is found, this will be the default fallback type for binary data.
  */

func contentTypeForName(name: String) -> String {
    
    let contentTypes: [String:String] = [
        "ai" : "application/postscript",
        "aif" : "audio/aiff",
        "aifc" : "audio/aiff",
        "aiff" : "audio/aiff",
        "au" : "audio/x-au",
        "avi" : "video/avi",
        "bmp" : "image/bmp",
        "bz2" : "application/x-bzip2",
        "c" : "text/plain",
        "c++" : "text/plain",
        "cc" : "text/plain",
        "cpp" : "text/x-c",
        "css" : "text/css",
        "cxx" : "text/plain",
        "eps" : "application/postscript",
        "gif" : "image/gif",
        "gtar" : "application/x-gtar",
        "gz" : "application/x-gzip",
        "gzip" : "application/x-gzip",
        "h" : "text/plain",
        "hdf" : "application/x-hdf",
        "hh" : "text/plain",
        "htm" : "text/html",
        "html" : "text/html",
        "ico" : "image/x-icon",
        "java" : "text/plain",
        "jfif" : "image/jpeg",
        "jpeg" : "image/jpeg",
        "jpg" : "image/jpeg",
        "js" : "application/x-javascript",
        "m" : "text/plain",
        "m3u" : "audio/x-mpequrl",
        "mid" : "audio/midi",
        "midi" : "audio/midi",
        "mp2" : "audio/mpeg",
        "mp3" : "audio/mpeg3",
        "mpg" : "video/mpeg",
        "png" : "image/png",
        "ps" : "application/postscript",
        "shtml" : "text/html",
        "swift" : "text/plain",
        "tgz" : "application/gnutar",
        "tif" : "image/tiff",
        "tiff" : "image/tiff",
        "txt" : "text/plain",
        "wav" : "audio/wav",
        "zip" : "application/zip"
    ]

    let suffix = name.characters.split(".").last.map { String($0).lowercaseString }

    return suffix.flatMap { contentTypes[$0] } ?? "application/octet-stream"
}
