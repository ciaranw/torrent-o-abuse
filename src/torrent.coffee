fs = require('fs')
crypto = require('crypto')
Bencoding = require('./bencoding')

module.exports = class Torrent
    constructor: (filePath, loadedCb) ->
        fs.readFile(filePath, (err, data) =>
            if err
                loadedCb(err, null)
            else
                @data = Bencoding.decode(data)
                loadedCb.call(@, null)
        )
    
    getInfoHash: () ->
        encoded = Bencoding.encode(@data.info)
        hash = crypto.createHash('sha1')
        hash.update(encoded)
        hash.digest()
        