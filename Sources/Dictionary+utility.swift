extension Dictionary {
	init<S: SequenceType where S.Generator.Element == Element>(_ seq: S) {
		self.init()
		for (k,v) in seq {
			self[k] = v
		}
	}
}