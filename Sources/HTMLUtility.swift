/* Malimbe - a server-side web framework for Swift
 * https://github.com/andrewcb/malimbe/ 
 * Licenced under the Apache Licence.
 */

/* Helpers for generating HTML; includes the HTMLRenderable protocol, 
   and a DSL for emitting HTML tags in Swift code.
*/

/** The HTMLRenderable protocol, used for objects (including tags) which produce HTML markup */
public protocol HTMLRenderable {
    /** Return a HTML representation of this object as a String */
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
    Hopefully future versions of Swift will fix this. */
    public var asHTML: String { return self.flatMap { ($0 as? HTMLRenderable)?.asHTML }.joinWithSeparator(" ") }
}

/** A lightweight class representing a HTML tag.  */
public struct HTMLTag: HTMLRenderable {
    let tag: String
    let attr: [String:String]
    let content: HTMLRenderable?

    /** Construct a HTMLTag
     - parameter tag: the name of the HTML tag
     - parameter attr: A Dictionary of tag attributes and their values
     - parameter content: The content of the tag, i.e., what goes between opening and closing tags.  If this is nil, the tag closes itself. */
    public init(tag:String, attr: [String:String] = [:], content:HTMLRenderable? = nil) {
        self.tag = tag
        self.attr = attr
        self.content = content
    }

    /* Construct tags from lists of tuples with possibly empty values; this 
       method exists to allow tag-specific helper methods to have optional
       keyword arguments.  */

    init(tag:String, attrList: [(String,String?)], content:HTMLRenderable...) {
        let presentParams: [(String,String)] = attrList.flatMap { (a, b) in b.map { (a, $0) } }
        let paramDict: [String:String] = [String:String](presentParams)
        switch content.count {
        case 0: self.init(tag:tag, attr:paramDict)
        case 1: self.init(tag:tag, attr:paramDict, content: content[0])
        default: let c: [HTMLRenderable] = content
            self.init(tag:tag, attr:paramDict, content: c)
        }
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

    public static func A(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil, href: String? = nil, target: String? = nil, name: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"a", attrList:[("id",id),("class", cls), ("href",href), ("target",target),("name",name)], content:content)
    }
    public static func B(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"b", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func BODY(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"body", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func BR(id id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"br", attrList:[("id",id),("class", cls)])
    }
    public static func DIV(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"div", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func DD(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"dd", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func DL(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"dl", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func DT(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"dt", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func FORM(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil, action: String? = nil, method: String? = nil, name: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"form", attrList:[("id",id),("class", cls), ("action",action), ("method",method), ("name",name)], content:content)
    }
    public static func H1(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"h1", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func H2(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"h2", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func H3(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"h3", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func H4(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"h4", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func HEAD(content: HTMLRenderable...) -> HTMLTag { 
        return HTMLTag(tag:"head", attrList:[], content:content)
    }
    public static func HEADER(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"header", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func HTML(content: HTMLRenderable...) -> HTMLTag { 
        return HTMLTag(tag:"html", attrList:[], content:content)
    }
    public static func I(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"i", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func IMG(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil, src: String? = nil, height: String? = nil, width: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"img", attrList:[("id",id),("class", cls), ("src",src), ("width",width), ("height",height)], content:content)
    }
    public static func INPUT(id: String? = nil, class cls: String? = nil, type: String? = nil, name: String? = nil, placeholder: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"input", attrList:[("id",id),("class", cls), ("type", type), ("name", name), ("placeholder", placeholder)])
    }
    public static func LI(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil, type: String? = nil, value: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"li", attrList:[("id",id),("class", cls), ("type", type), ("value", value)], content:content)
    }
    public static func LINK(rel rel: String? = nil, href: String? = nil, type: String? = nil, media: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"link", attrList:[("rel",rel),("href", href), ("type", type), ("media",media)])
    }
    public static func META(id id: String? = nil, name: String? = nil, content: String? = nil, charset: String? = nil, httpEquiv: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"meta", attrList:[("id",id),("name", name), ("content", content), ("charset",charset), ("http-equiv", httpEquiv)])
    }
    public static func OL(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil, compact: String? = nil, reversed: String? = nil, start: String? = nil, type: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"ul", attrList:[("id",id),("class", cls), ("compact", compact), ("reversed", reversed), ("start", start), ("type", type)], content:content)
    }
    public static func P(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"p", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func SPAN(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"span", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func TEXTAREA(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil, name: String? = nil, cols: Int? = nil, rows: Int? = nil) -> HTMLTag { 
        return HTMLTag(tag:"textarea", attrList:[("id",id),("class", cls), ("name",name), ("cols", cols.map { "\($0)"}), ("rows", rows.map { "\($0)"})], content:content)
    }
    public static func TITLE(content: HTMLRenderable...) -> HTMLTag { 
        return HTMLTag(tag:"title", attrList:[], content:content)
    }
    public static func TT(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"tt", attrList:[("id",id),("class", cls)], content:content)
    }
    public static func UL(content: HTMLRenderable..., id: String? = nil, class cls: String? = nil, compact: String? = nil, type: String? = nil) -> HTMLTag { 
        return HTMLTag(tag:"ul", attrList:[("id",id),("class", cls), ("compact", compact), ("type", type)], content:content)
    }
}

/** Used for passing HTML code which should not be quoted. */
struct HTMLLiteral: HTMLRenderable {
    let value: String
    init(_ value: String) { self.value = value }
    var asHTML: String { return self.value }
}
