net = require('net')
tcpProtocol = require('./tcp-protocol')

module.exports = class Peer
    constructor: (@host, @port) ->
        @handshook = false
    
    handshake: (peerId, torrent) ->
        client = net.connect(
            port: @port
            host: @host
        , () ->
            console.log('connected')
            client.write(tcpProtocol.buildHandshake(torrent, peerId))
        )
        
        client.on('data', (data) =>
            console.log('got data from peer')
            if @handshook
                msg = tcpProtocol.parseMessage(data)
                console.log(msg)
            else
                try
                    handshake = tcpProtocol.parseHandshake(data)
                    console.log(handshake)
                    @peerId = handshake.peerId
                    @handshook = true
                catch err
                    client.destroy()
        )