extension String {
	private func hexvalue(c: Character) -> Int? {
		let table = "0123456789ABCDEF0123456789abcdef".characters
		return table.indexOf(c).map { table.startIndex.distanceTo($0) & 0x0f }
	}

	func urldecode() -> String {
		var gen = self.characters.generate()
		var result: String = ""

		var ch: Character? = gen.next()

		while let ch0 = ch {
			if ch0 == "%" {
				let c1: Character? = gen.next(), c2: Character?=gen.next()
				if let d1 = (c1.flatMap { hexvalue($0) }), let d2 = (c2.flatMap {hexvalue($0) }) {
					result.append(Character(UnicodeScalar(d1<<4 | d2)))
				} else {
					result.append(ch0)
					if let ch1 = c1 { 
						result.append(ch1)
						if let ch2 = c2 {
							result.append(ch2)
						}
					}
				}
			} else if ch0 == "+" {
				result.append(Character(" "))
			} else {
				result.append(ch0)
			}

			ch = gen.next()
		}
		return result
	}
}
