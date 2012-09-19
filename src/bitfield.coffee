masks = [0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01]

module.exports = class BitField
    constructor: (@buffer) ->
    
    isSet: (position) ->
        bufferIndex = Math.floor(position / 8)
        bitIndex = position % 8
        (@buffer[bufferIndex] & masks[bitIndex]) != 0
    
    inspect: () ->
        flags = for i in [0..@buffer.length * 8]
            @isSet(i)
    