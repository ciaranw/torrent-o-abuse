request = require('request')
qs = require('querystring')
Bencoding = require('./bencoding')
ByteEncoding = require('./byte-encoding')

_urlEncode = (buffer) ->
    escaped = for i in buffer
        switch true
            when 0x2b == i then '%2b'
            when 0x00 <= i <= 0x7F
                escape(String.fromCharCode(i))
            else
                hex = i.toString(16)
                hex = if hex.length == 1 then "0#{hex}" else hex
                "%#{hex}".toUpperCase()
    
    escaped.join('')

exports.announce = (host, port, peerId, torrent, cb) ->
    queryParams =
        peer_id: peerId
        port: 6881
    
    byteEncoded = ByteEncoding.encode(torrent.getInfoHash())
    console.log(byteEncoded.toString('hex'))
    query = "#{qs.stringify(queryParams)}&info_hash=#{_urlEncode(byteEncoded)}"
    console.log(query)
    
    url = "http://#{host}:#{port}/announce?#{query}"
    
    options =
        url: url
        encoding: null
    
    request(options, (err, resp, data) ->
        if err
            cb(err)
        else
            decoded = Bencoding.decode(data)
            cb(null, decoded)
        
    )
    