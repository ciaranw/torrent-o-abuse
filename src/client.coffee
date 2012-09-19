httpProtocol = require('./http-protocol')
net = require('net')
tcpProtocol = require('./tcp-protocol')

module.exports = class Client
    constructor: (@torrent) ->
        @peerId = "-TA0001-#{Math.floor(Math.random() * 100000000)}"
        @client = net.createServer((socket) =>
            socket.on('data', (data) =>
                console.log('got data from client')
                socket.write(tcpProtocol.buildHandshake(@torrent, @peerId))
            )
        )
        @client.listen(6881)
    
    announce: (cb) ->
        httpProtocol.announce('localhost', 6969, @peerId, @torrent, cb)
    

    