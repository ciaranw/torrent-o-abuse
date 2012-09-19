_ = require('underscore')
Iconv = require('iconv').Iconv
converter = new Iconv('UTF-8', 'ISO-8859-1')
converter2 = new Iconv('ISO-8859-1', 'UTF-8')

encodeBuffer = (data) ->
    Buffer.concat([new Buffer("#{data.length}:"), data])

encodeString = (data) -> converter.convert(new Buffer("#{data.length}:#{data}"))
encodeNumber = (data) -> new Buffer("i#{data}e")

encode = (data, buffer = new Buffer(0)) ->
    switch true
        when Buffer.isBuffer(data) then Buffer.concat([buffer, encodeBuffer(data)])
        when _.isString(data) then Buffer.concat([buffer, encodeString(data)])
        when _.isNumber(data) then Buffer.concat([buffer, encodeNumber(data)])
        when _.isArray(data)
            encoded = [new Buffer('l')]
            encoded = encoded.concat(_.map(data, (i) -> encode(i)))
            encoded.push(new Buffer('e'))
            Buffer.concat(encoded)
        when _.isObject(data)
            encoded = _.reduce(data, (memo, value, key) ->
                encodedKey = if key == '_length' then encodeString('length') else encodeString(key)
                encodedValue = encode(value)
                
                memo.push(encodedKey)
                memo.push(encodedValue)
                memo
            , [new Buffer('d')])
            encoded.push(new Buffer('e'))
            Buffer.concat(encoded)
    

decodeString = (data) ->
    colonPosition = _.indexOf(data, ':'.charCodeAt(0))
    lengthStr = data.toString('ascii', 0, colonPosition)
    length = parseInt(lengthStr, 10)
    
    offset = colonPosition + 1
    str = data.slice(offset, offset + length)
    
    [str, data.slice(offset + str.length)]

decodeNumber = (data) ->
    terminatorPosition = _.indexOf(data, 'e'.charCodeAt(0))
    numString = data.toString('ascii', 1, terminatorPosition)
    num = parseInt(numString, 10)
    
    [num, data.slice(terminatorPosition + 1)]

decodeArray = (data) ->
    buf = data.slice(1)
    
    decoded = until buf[0] == 'e'.charCodeAt(0)
        [decoded, newBuf] = decode(buf)
        buf = newBuf
        decoded
    
    [decoded, buf.slice(1)]

decodeObject = (data) ->
    buf = data.slice(1)
    
    decoded = {}
    until buf[0] == 'e'.charCodeAt(0)
        [key, newBuf] = decode(buf)
        
        [value, newBuf] = decode(newBuf)
        
        if key.toString('utf8') == 'length'
            decoded['_length'] = value
        else
            decoded[key] = value
        buf = newBuf
    
    [decoded, buf.slice(1)]

decode = (data) ->
    first = data.toString('utf8', 0, 1)
    
    switch first
        when '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
            decoded = decodeString(data)
        when 'i'
            decoded = decodeNumber(data)
        when 'l'
            decoded = decodeArray(data)
        when 'd'
            decoded = decodeObject(data)
    
    if decoded[1].length == 0
        decoded[0]
    else
        decoded

module.exports =
    encode: encode
    decode: decode