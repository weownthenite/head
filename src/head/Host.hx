package head;

import haxe.Json;
import js.Promise;
import js.html.MediaStream;
import js.html.rtc.DataChannel;
import js.html.rtc.IceCandidate;
import js.html.rtc.PeerConnection;
import js.html.rtc.SessionDescription;
import js.node.Buffer;
import js.node.Net;
import js.node.net.Server;
import js.node.net.Socket;
import om.net.WebSocket;

private class Client {

    var socket : Socket;
    var connection : PeerConnection;
    var channel : DataChannel;
    var stream : MediaStream;

    public function new( socket : Socket, stream : MediaStream ) {

        this.socket = socket;
        this.stream = stream;

        socket.once( 'data', function( buf : Buffer ) {
            socket.write( WebSocket.createHandshake( buf ) );
            socket.addListener( 'data', handleData );
        });
    }

    function handleData( buf : Buffer ) {

        var data = WebSocket.readFrame( buf );
        var msg = Json.parse( data.toString() );
        //trace(msg);

        switch msg.type {

        case 'init':

            connection = untyped __js__( 'new webkitRTCPeerConnection({iceServers:[]})' );
            connection.onicecandidate = function(e) {
                if( e.candidate == null ) {
                    trace("Send init");
                    sendSocketMessage( { type: 'init', sdp: connection.localDescription } );
                }
            }

            channel = connection.createDataChannel( "channel-1" );
            channel.onopen = function(e) {
                //trace(e);
                channel.onmessage = function(e) {
                    //trace(e);

                }
                channel.onclose = function(e) {
                    trace(e);
                }
            }

            connection.addStream( stream );

            connection.createOffer( { offerToReceiveAudio: 0,	offerToReceiveVideo: 1 } )
                .then( function(desc) connection.setLocalDescription( desc ) )
                .then( function(_) {
                    trace("...............");
                    //sendSocketMessage( { type: 'init', sdp: peer.localDescription } );
                });

        case 'sdp':
            connection.setRemoteDescription( new SessionDescription( msg.sdp ) ).then( function(e){
                //trace( 'HMD connected' );
                //connected = true;
                //socket.end();
            });
        }
    }

    public inline function sendMessage( msg : Dynamic ) {
        send( Json.stringify( msg ) );
    }

    public inline function send( str : String ) {
        channel.send( str );
    }

    public function disconnect() {
        socket.end();
        if( connection != null ) {
            connection.close();
        }
    }

    function sendSocketMessage( msg : Dynamic ) {
        sendSocket( Json.stringify( msg )  );
    }

    function sendSocket( str : String ) {
        socket.write( WebSocket.writeFrame( new Buffer( str ) ) );
    }
}

/**
    Remote HMD host.
**/
class Host {

    public var ip(default,null) : String;
    public var port(default,null) : Int;

    var server : Server;
    var clients : Array<Client>;

    public function new( ip : String, port : Int ) {
        this.ip = ip;
        this.port = port;
        clients = [];
    }

    public function start( stream : MediaStream ) : Promise<Dynamic> {

        return new Promise( function(resolve,reject) {

            server = Net.createServer( function(socket:Socket) {

                var client = new Client( socket, stream );
                //client.onMessage = onMessage;
                clients.push( client );
            });

            server.listen( port, ip, function() {

                //window.addEventListener( 'resize', handleWindowResize, false  );

                resolve( cast this );
            });
        });
    }

    public function stop() {
        if( server != null ) {
            server.close();
        }
        clients = [];
    }

}
