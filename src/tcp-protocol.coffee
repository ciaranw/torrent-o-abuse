ByteEncoding = require('./byte-encoding')
binary = require('binary')
BitField = require('./bitfield')

PROTOCOL = do() ->
    data = new Buffer(' BitTorrent protocol')
    data[0] = 19
    data

RESERVED = new Buffer(8)

exports.MSG_TYPES = MSG_TYPES =
    KEEP_ALIVE: -1
    CHOKE: 0
    UNCHOKE: 1
    INTERESTED: 2
    NOT_INTERESTED: 3
    HAVE: 4
    BITFIELD: 5
    REQUEST: 6
    PIECE: 7
    CANCEL: 8
    PORT: 9


exports.buildHandshake = (torrent, peerId) ->
    Buffer.concat([PROTOCOL, RESERVED, ByteEncoding.encode(torrent.getInfoHash()), new Buffer(peerId)])

exports.parseHandshake = (buffer) ->
    console.log(buffer)
    parsed = binary.parse(buffer)
        .word8bu('protocolLength')
        .buffer('protocol', 'protocolLength')
        .buffer('reserved', 8)
        .buffer('infoHash', 20)
        .buffer('peerId', 20)
        .vars
    
    protocol: parsed.protocol.toString()
    infoHash: parsed.infoHash
    clientId: parsed.peerId.toString()
    

parseChoke = (data) ->
    type: MSG_TYPES.CHOKE

parseUnchoke = (data) ->
    type: MSG_TYPES.UNCHOKE

parseBitfield = (data, length) ->
    console.log(data.length)
    type: MSG_TYPES.BITFIELD
    bitfield: new BitField(data)

exports.parseMessage = (buffer) ->
    if buffer.length == 0
        return type: MSG_TYPES.KEEP_ALIVE
    
    sizeType = binary.parse(buffer)
        .word32be('messageLength')
        .word8be('type')
        .vars
    
    data = buffer.slice(5)
    
    switch sizeType.type
        when MSG_TYPES.CHOKE then parseChoke(data)
        when MSG_TYPES.UNCHOKE then parseUnchoke(data)
        when MSG_TYPES.BITFIELD then parseBitfield(data, sizeType.length)