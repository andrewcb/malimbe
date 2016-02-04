extension String {

    /** Attempt to decode a Base64 input, creating a string if valid. */
    init?(base64: String) {
        let decode:[Character:UInt8] = ["A":0, "B":1, "C":2, "D":3, "E":4, "F":5, "G":6, "H":7, "I":8, "J":9, "K":10, "L":11, "M":12, "N":13, "O":14, "P":15, "Q":16, "R":17, "S":18, "T":19, "U":20, "V":21, "W":22, "X":23, "Y":24, "Z":25, "a":26, "b":27, "c":28, "d":29, "e":30, "f":31, "g":32, "h":33, "i":34, "j":35, "k":36, "l":37, "m":38, "n":39, "o":40, "p":41, "q":42, "r":43, "s":44, "t":45, "u":46, "v":47, "w":48, "x":49, "y":50, "z":51, "0":52, "1":53, "2":54, "3":55, "4":56, "5":57, "6":58, "7":59, "8":60, "9":61, "+":62, "/":63, "=":64]

        var gen = base64.characters.generate()
        var buf: [UInt8] = []

        var inb: Character? = gen.next()
        while let inb0 = inb {
            guard let b0 = decode[inb0],
                  let b1 = (gen.next().flatMap { decode[$0] }),
                  let b2 = (gen.next().flatMap { decode[$0] }),
                  let b3 = (gen.next().flatMap { decode[$0] }) else { return nil }
            buf.append((b0<<2) | (b1>>4))
            if b2<64 {
                buf.append((b1<<4) | (b2>>2))
                if b3<64 { buf.append((b2<<6) | (b3)) }
            }
            inb = gen.next()
        }
        var gen2 = buf.generate()
        var decoder = UTF8()
        var result:String = ""
        while true {
            if case .Result(let char) = decoder.decode(&gen2) {
                result.append(char)
            } else {
                break
            }
        }
        self = result
    }

    /** Return the current string's UTF-8 representation encoded as Base64 */
    var utf8Base64 : String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".characters
        func charFor(index: UInt8) -> Character { 
            return chars[chars.startIndex.advancedBy(Int(index))]
        }
        var result: String = ""
        var gen = self.utf8.generate()

        var inb: UInt8? = gen.next()
        while let inb1 = inb {
            result.append(charFor((inb1 & 0xFC)>>2))
            
            guard let inb2: UInt8 = gen.next() else {
                result.append(charFor((inb1 & 0x03)<<4))
                result.appendContentsOf("==")
                break
            }

            result.append(charFor(((inb1 & 0x03)<<4) | ((inb2 & 0xf0)>>4)))

            guard let inb3: UInt8 = gen.next() else {
                result.append(charFor(((inb2 & 0x0f)<<2)))
                result.appendContentsOf("=")
                break
            }
            result.append(charFor(((inb2 & 0x0f)<<2) | ((inb3 & 0xc0)>>6)))
            result.append(charFor((inb3 & 0x3f)))

            inb = gen.next()
        }
        return result
    }
}