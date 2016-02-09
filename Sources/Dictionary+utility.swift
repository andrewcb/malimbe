/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */

// Utility methods on Dictionary

extension Dictionary {
    /** 
    Construct a dictionary from a sequence of (key,value) tuples.
    */
    init<S: SequenceType where S.Generator.Element == Element>(_ seq: S) {
        self.init()
        for (k,v) in seq {
            self[k] = v
        }
    }
}