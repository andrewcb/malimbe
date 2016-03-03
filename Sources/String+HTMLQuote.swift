/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */

extension String {
    /** Escape all the HTML special characters (i.e., </>) in the string. */
    var HTMLQuote: String {
        var result: String = ""

        for ch in self.characters {
            switch(ch) {
                case "<": result.appendContentsOf("&lt;")
                case ">": result.appendContentsOf("&gt;")
                default: result.append(ch)
            }
        }
        return result
    }
}