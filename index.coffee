Torrent = require('./src/torrent')
Client = require('./src/client')
Peer = require('./src/peer')
_ = require('underscore')

toPeers = (data) ->
    if Buffer.isBuffer(data)
        noPeers = Math.floor(data.length / 6)
        peers = []
        _.times(noPeers, (i) ->
            start = i * 6
            peersBuffer = data.slice(start, start + 6)
            ip = "#{peersBuffer[0]}.#{peersBuffer[1]}.#{peersBuffer[2]}.#{peersBuffer[3]}"
            port = (0xff & peersBuffer[4]) << 8 | (0xff & peersBuffer[5])
            
            peers.push(new Peer(ip, port))
        )
        peers
    

new Torrent("#{__dirname}/torrents/soldeu-2012.torrent", (err) ->
    client = new Client(@)
    client.announce((err, data) ->
        console.log(err)
        console.log(data)
        
        peers = toPeers(data.peers)
        _.each(peers, (peer) ->
            peer.handshake(client.peerId, client.torrent)
        )
    )
)