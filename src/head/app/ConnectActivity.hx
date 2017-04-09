package head.app;

import js.Browser.document;

class ConnectActivity extends om.Activity {

    override function onCreate() {

        super.onCreate();

        var input = document.createInputElement();
        input.type = 'text';
        input.value = '192.168.';
        element.appendChild( input );

        var connect = document.createButtonElement();
        connect.textContent = 'CONNECT';
        connect.onclick = function(){

            var net = new Client( '192.168.1.103', 7000 );
            net.connect().then( function(e){

                trace( 'HMD connected' );

                replace( new MainActivity( net ) );
            });

            /*
            var str = input.value;
            if( str.length > 8 ) {

                trace(str);

                var net = new Client( '192.168.1.103', 7000 );
                net.connect().then( function(e){
                    trace(e);
                });

                //replace( new MainActivity( str ) );
            }
            */
        }
        element.appendChild( connect );

        /*
        var scan = document.createButtonElement();
        scan.textContent = 'SCAN';
        element.appendChild( scan );
        */
    }

    /*
    override function onStart() {

        super.onStart();

        scan.onclick = function(){
            scan.disabled = true;
        }

        var net = new om.net.IPScan( 128 );
        net.search( 7000, '192.168.42' ).then( function(socket:js.html.WebSocket){
            trace( '#####################################################' );
            trace( '#####################################################' );
            trace( '#####################################################' );
            trace( '#####################################################' );
            trace( '#####################################################' );
            trace( 'Net connection found: '+socket );
        }).catchError( function(e) {
            trace(e);
        });
    }
    */
}
