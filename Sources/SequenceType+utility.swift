/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */


extension SequenceType {
    /** return the number of items in the sequence matching a predicate.
     - parameter predicate: A function called with each item, determining whether the item is to be counted.*/
    public func count(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Int {
        var result = 0
        for item in self {
            if try predicate(item) { 
                result += 1
            }
        }
        return result
    }
}