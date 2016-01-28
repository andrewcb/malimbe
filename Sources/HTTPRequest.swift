

struct HTTPRequest {
	let method: String
	let path: String
	let headers: [String:String]
	let queryArgs: [String:String]

	init(method: String, rawPath: String, headers: [String:String]) {
		self.method = method
		self.headers = headers

		let splitpath = rawPath.split("?", maxSplit:1)
		self.path = splitpath[0]
		if splitpath.count > 1 {
			// TODO: create String.urldecode
			let argtuples = splitpath[1].split("&", maxSplit: Int.max).map { $0.split("=", maxSplit:1) }.flatMap { 
				($0.count > 1 ) ? ($0[0].urldecode(), $0[1].urldecode()) : nil
			}
			self.queryArgs = [String:String](argtuples)
		} else {
			self.queryArgs = [:]
		}
	}
}