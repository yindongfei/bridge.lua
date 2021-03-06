local System = System
local Int = System.Int
local charCodeAt = System.String.charCodeAt

local Char = {}

Char.compareTo = Int.compareTo
Char.compareToObj = Int.compareToObj
Char.equals = Int.equals
Char.equalsObj = Int.equalsObj
Char.getHashCode = Int.getHashCode

function Char.isControl(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    return (c >=0 and c <= 31) or (c >= 127 and c <= 159)
end

function Char.isDigit(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    return (c >= 48 and c <= 57)
end

-- https://msdn.microsoft.com/zh-cn/library/yyxz6h5w(v=vs.110).aspx
function Char.isLetter(c, index)    
    if index then
        c = charCodeAt(c, index) 
    end
    if c < 256 then
        return (c >= 65 and c <= 90) or (c >= 97 and c <= 122)
    else  
        return (c >= 0x0400 and c <= 0x042F) 
        or (c >= 0x03AC and c <= 0x03CE) 
        or (c == 0x01C5 or c == 0x1FFC) 
        or (c >= 0x02B0 and c <= 0x02C1) 
        or (c >= 0x1D2C and c <= 0x1D61) 
        or (c >= 0x05D0 and c <= 0x05EA)
        or (c >= 0x0621 and c <= 0x063A)
        or (c >= 0x4E00 and c <= 0x9FC3) 
    end
end

function Char.isLetterOrDigit(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    return Char.isDigit(c) or Char.isLetter(c)
end

function Char.isLower(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    return (c >= 0x0061 and c <= 0x007A) and (c >= 0x03AC and c <= 0x03CE)
end

function Char.isNumber(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    return (c >= 48 and c <= 57) or c == 178 or c == 179 or c == 185 or c == 188 or c == 189 or c == 190
end

function Char.isPunctuation(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    if c < 256 then
        return (c >= 0x0021 and c <= 0x0023) 
        or (c >= 0x0025 and c <= 0x002A) 
        or (c >= 0x002C and c <= 0x002F) 
        or (c >= 0x003A and c <= 0x003B) 
        or (c >= 0x003F and c <= 0x0040)  
        or (c >= 0x005B and c <= 0x005D)
        or c == 0x5F or c == 0x7B or c == 0x007D or c == 0x00A1 or c == 0x00AB or c == 0x00AD or c == 0x00B7 or c == 0x00BB or c == 0x00BF
    end
    return false
end

local isSeparatorTable = {
    [32] = true,
    [160] = true,
    [0x2028] = true,
    [0x2029] = true,
    [0x0020] = true,
    [0x00A0] = true,
    [0x1680] = true,
    [0x180E] = true,
    [0x202F] = true,
    [0x205F] = true,
    [0x3000] = true,
}

function Char.isSeparator(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    return (c >= 0x2000 and c <= 0x200A) or isSeparatorTable[c] == true
end

local isSymbolTable = {
    [36] = true,
    [43] = true,
    [60] = true, 
    [61] = true, 
    [62] = true, 
    [94] = true, 
    [96] = true,
    [124] = true,
    [126] = true,
    [172] = true, 
    [180] = true,
    [182] = true,
    [184] = true,
    [215] = true,
    [247] = true,
}

function Char.isSymbol(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    if c < 256 then
        return (c >= 162 and c <= 169) or (c >= 174 and c <= 177) or isSymbolTable(c) == true
    end
    return false
end 

function Char.isUpper(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    return (c >= 0x0041 and c <= 0x005A) or (c >= 0x0400 and c <= 0x042F)
end

--https://msdn.microsoft.com/zh-cn/library/t809ektx(v=vs.110).aspx
local isWhiteSpace = {
    [0x0020] = true,
    [0x00A0] = true,
    [0x1680] = true,
    [0x202F] = true,
    [0x205F] = true,
    [0x3000] = true,
    [0x2028] = true,
    [0x2029] = true,
    [0x0085] = true,
}

function Char.isWhiteSpace(c, index)
    if index then
        c = charCodeAt(c, index)
    end
    return (c >= 0x2000 and c <= 0x200A) or (c >= 0x0009 and c <= 0x000d) or isWhiteSpace[c] == true
end

function Char.parse(s)
    if s == nil then
        System.throw(System.ArgumentNullException())
    end
    if #s ~= 1 then
        System.throw(System.FormatException())
    end
    return string.byte(s)
end

function Char.tryParse(s)
    if s == nil or #s ~= 1 then
        return false
    end 
    return true, string.byte(s)
end

function Char.toLower(c)
    local s = string.char(c)
    s = string.lower(s)
    return string.byte(s)
end

function Char.toUpper(c)
    local s = string.char(c)
    s = string.upper(s)
    return string.byte(s)
end

function Char.isHighSurrogate(c, index) 
    if index then
        c = charCodeAt(c, index)
    end
    return c >= 0xD800 and c <= 0xDBFF
end
        
function Char.isLowSurrogate(c, index) 
    if index then
        c = charCodeAt(c, index)
    end
    return c >= 0xDC00 and c <= 0xDFFF
end

function Char.isSurrogate(c, index) 
    if index then
        c = charCodeAt(c, index)
    end
    return c >= 0xD800 and c <= 0xDFFF
end

Char.__defaultVal__ = 0

System.defStc("System.Char", Char)
Char.__inherits__ = { System.IComparable, System.IComparable_1(Char), System.IEquatable_1(Char) }