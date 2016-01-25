
extension String {
	func split(separator: Character, maxSplit: Int) -> [String] {
		return self.characters.split(separator, maxSplit: maxSplit, allowEmptySlices: false).map { String($0) }
	}

	func splitExactly(separator: Character, numSplit: Int) -> [String]? {
		if (self.characters.count { $0 == separator }) != numSplit { return nil }
		let r = self.split(separator, maxSplit: numSplit)
		assert(r.count == numSplit + 1)
		return r
	}

	func trim(filter: Character->Bool) -> String {
		let chars = self.characters
		var start = chars.indices.startIndex
		var end = chars.indices.endIndex

		while (start < end && !filter(chars[start])) { start = start.successor() }

		while (start < end && !filter(chars[end.predecessor()])) { end = end.predecessor() }

		return String(chars[Range(start:start, end:end)])
	}
}