package head;

import haxe.Json;
import js.Promise;
import js.html.MediaStream;
import js.html.WebSocket;
import js.html.rtc.DataChannel;
import js.html.rtc.IceCandidate;
import js.html.rtc.PeerConnection;
import js.html.rtc.SessionDescription;

/**
    Remote HMD client.
**/
class Client {

    public dynamic function onDisconnect() {}
    public dynamic function onMessage( msg : Dynamic ) {}
    public dynamic function onStream( stream : MediaStream ) {}

    public var ip(default,null) : String;
    public var port(default,null) : Int;
    public var connected(default,null) : Bool;
    public var stream(default,null) : MediaStream;

    var socket : WebSocket;
    var connection : PeerConnection;
    var channel : DataChannel;

    public function new( ip : String, port : Int ) {
        this.ip = ip;
        this.port = port;
        connected = false;
    }

    public function connect() : Promise<Dynamic> {

        return new Promise( function(resolve,reject) {

            var url = 'ws://$ip:$port';
            socket = new WebSocket( url );
            socket.addEventListener( 'open', function(e) {
                trace(e);
                sendSocketMessage( {
                    type: 'init'
                } );
            });
            socket.addEventListener( 'message', function(e) {

                var msg : Dynamic = Json.parse( e.data );
                trace(msg);

                switch msg.type {

                case 'init':

                    connection = new PeerConnection();
                    connection.onicecandidate = function(e) {
                        trace(e );
                    }
                    connection.ondatachannel = function(e) {
                        channel = e.channel;
                        channel.onopen = function(e) {
                            trace( 'Data Channel Open' );
                            connected = true;
                            resolve( {} );
                        }
                    }
                    connection.onaddstream = function(e) {
                        trace(e);
                        stream = e.stream;
                        //onStream( e.stream );
                    }
                    connection.setRemoteDescription( new SessionDescription( msg.sdp ) ).then( function(_) {
                        connection.createAnswer().then( function(desc){
                            connection.setLocalDescription( desc ).then( function(_){
                                sendSocketMessage( { type: 'sdp', sdp: desc } );
                            });
                        });
                    });
                }
            });
            socket.addEventListener( 'close', function(e) {
                trace(e);
                connected = false;
            });
            socket.addEventListener( 'error', function(e) {
                trace(e);
                reject( e );
            });
        });
    }

    public inline function sendMessage( msg : Dynamic ) {
        channel.send( Json.stringify( msg ) );
    }

    public function disconnect() {
        if( socket != null ) {
            trace(socket);
            //socket.close();
        }
    }

    inline function sendSocketMessage( msg : Dynamic ) {
        socket.send( Json.stringify( msg ) );
    }

}
