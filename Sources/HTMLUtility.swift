/*extension Dictionary { // remove this when done
  
    init<S: SequenceType where S.Generator.Element == Element>(_ seq: S) {
        self.init()
        for (k,v) in seq {
            self[k] = v
        }
    }
}*/
// Utility methods for HTML

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

/** The HTMLRenderable protocol, used for objects (including tags) which produce HTML markup */
public protocol HTMLRenderable {
    var asHTML: String { get }
}

/* By default, a string will be escaped when rendered as HTML. */

extension String : HTMLRenderable {
    public var asHTML: String { return self.HTMLQuote }
}


extension Array : HTMLRenderable {
    /* Unfortunately, Swift as of 2.2 does not allow protocol-conformance 
    extensions to be constrained by subtype, so rather than this being illegal 
    for arrays of non-HTMLRenderable types, it simply will skip the invalid types. 
    Hopefully future versions of Swift will fix this. 
    */
    public var asHTML: String { return self.flatMap { ($0 as? HTMLRenderable)?.asHTML }.joinWithSeparator(" ") }
}

public struct HTMLTag: HTMLRenderable {
    let tag: String
    let attr: [String:String]
    let content: HTMLRenderable?

    public init(tag:String, attr: [String:String] = [:], content:HTMLRenderable? = nil) {
        self.tag = tag
        self.attr = attr
        self.content = content
    }

    init(tag:String, attrList: [(String, String?)], content:HTMLRenderable? = nil) {
        let presentParams: [(String,String)] = attrList.flatMap { (a, b) in b.map { (a, $0) } }
        let paramDict: [String:String] = [String:String](presentParams)
        self.init(tag: tag, attr: paramDict, content: content)
    }

    public var asHTML: String {
        let paramStr = self.attr.isEmpty ? "" : (" " + self.attr.map { "\($0.0)=\"\($0.1)\"" }.joinWithSeparator(" "))
        if let content = self.content {
            return "<\(self.tag)\(paramStr)>\(content.asHTML)</\(self.tag)>"
        } else {
            return "<\(self.tag)\(paramStr)/>"

        }
    }

    // Convenience functions for constructing common tags

    public static func A(content: HTMLRenderable, id: String? = nil, class cls: String? = nil, href: String? = nil, target: String? = nil, name: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"b", attrList:[("id",id),("class", cls), ("href",href), ("target",target),("name",name)], content:content)
    }
    public static func B(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"b", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func BODY(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"body", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func DIV(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"div", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func FORM(content: HTMLRenderable, id: String? = nil, class cls: String? = nil, action: String? = nil, method: String? = nil, name: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"form", attrList:[("id",id),("class", cls), ("action",action), ("method",method), ("name",name)], content:content)
    }
    public static func H1(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"h1", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func H2(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"h2", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func H3(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"h3", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func H4(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"h4", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func HEAD(content: HTMLRenderable) -> HTMLTag { 
        return HTMLTag(tag:"head", attrList:[], content:content)
    }
    public static func HEADER(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"header", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func HTML(content: HTMLRenderable) -> HTMLTag { 
        return HTMLTag(tag:"html", attrList:[], content:content)
    }
    public static func I(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"i", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func IMG(content: HTMLRenderable, id: String? = nil, class cls: String? = nil, src: String? = nil, height: String? = nil, width: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"img", attrList:[("id",id),("class", cls), ("src",src), ("width",width), ("height",height)], content:content)
    }
    public static func INPUT(id: String? = nil, class cls: String? = nil, type: String? = nil, name: String? = nil, placeholder: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"i", attrList:[("id",id),("class", cls), ("type", type), ("name", name), ("placeholder", placeholder)])
    }
    public static func LINK(rel: String? = nil, href: String? = nil, type: String? = nil, media: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"link", attrList:[("rel",rel),("href", href), ("type", type), ("media",media)])
    }
    public static func META(id: String? = nil, name: String? = nil, content: String? = nil, charset: String? = nil, httpEquiv: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"meta", attrList:[("id",id),("name", name), ("content", content), ("charset",charset), ("http-equiv", httpEquiv)])
    }
    public static func P(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"p", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func SPAN(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"span", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func TEXTAREA(content: HTMLRenderable, id: String? = nil, class cls: String? = nil, name: String? = nil, cols: Int? = nil, rows: Int? = nil) -> HTMLTag { 
        return HTMLTag(tag:"tt", attrList:[("id",id),("class", cls), ("name",name), ("cols", cols.map { "\($0)"}), ("rows", rows.map { "\($0)"})], content:content)
    }
    public static func TITLE(content: HTMLRenderable) -> HTMLTag { 
        return HTMLTag(tag:"title", attrList:[], content:content)
    }
    public static func TT(content: HTMLRenderable, id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"tt", attrList:[("id",id),("class", cls)], content:content)
    }
}

/** Used for passing HTML code which should not be quoted. */
struct HTMLLiteral: HTMLRenderable {
    let value: String
    init(_ value: String) { self.value = value }
    var asHTML: String { return self.value }
}


/*let a: [Any] = [ "Hello<> world", HTMLTag(tag:"a", attr:["href":"blah"], content:"hello")]

print (a.asHTML)

let lit = HTMLLiteral("<marquee>Hello</marquee>")
print("literal = \(lit.asHTML)")

let arr: [HTMLRenderable] = [HTMLTag.P("hi"), "hello", HTMLLiteral("<marquee>Hello</marquee>")]
print("array = \(arr.asHTML)")

let div = HTMLTag.DIV([
    HTMLTag.P("Hello world", class:"first"),
    HTMLTag.P("This is the second paragraph"),
    HTMLTag(tag:"br" ),
    HTMLTag(tag:"br", content:"" ),
    //lit
    //HTMLLiteral("<marquee>This is a literal</marquee>")
    ], id:"body")
print(div.asHTML)*/