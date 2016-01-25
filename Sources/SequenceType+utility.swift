extension SequenceType {
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