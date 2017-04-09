package head.app;

import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.DeviceOrientationEvent;
import js.html.CanvasRenderingContext2D;
import js.html.VideoElement;

class MainActivity extends om.Activity {

    var net : Client;
    var video : VideoElement;
    var canvas : CanvasElement;
    var context: CanvasRenderingContext2D;
    var animationFrameId : Int;

    public function new( net : Client ) {
        super();
        this.net = net;
    }

    override function onCreate() {

        super.onCreate();

        video = document.createVideoElement();
        video.muted = true;
        video.autoplay = true;

        canvas = document.createCanvasElement();
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        element.appendChild( canvas );

        context = canvas.getContext2d();
        context.fillStyle = '#fff';
    }

    override function onStart() {

        super.onStart();

        video.addEventListener( 'loadedmetadata', function() {
			trace( 'Remote video videoWidth: ' + video.width + 'px,  videoHeight: ' + video.height + 'px' );
		});
        video.srcObject = net.stream;

        net.onMessage = function(msg){
            //trace( msg );
        }

        animationFrameId = window.requestAnimationFrame( update );

        window.addEventListener( 'resize', handleWindowResize, false  );
        window.addEventListener( 'deviceorientation', handleDeviceOrientation, false );
        //window.addEventListener( 'touch', handleTouchStart, false );
    }

    override function onStop() {

        super.onStop();

        window.cancelAnimationFrame( animationFrameId );

        window.removeEventListener( 'resize', handleWindowResize );
        window.removeEventListener( 'deviceorientation', handleDeviceOrientation );
    }

    function update( time : Float ) {

        animationFrameId = window.requestAnimationFrame( update );

        var mx = Std.int( canvas.width/2 );
        //var my = Std.int( canvas.height/2 );

        context.clearRect( 0, 0, canvas.width, canvas.height );
        context.drawImage( video, 0, 0, mx, canvas.height );
        context.drawImage( video, mx, 0, mx, canvas.height );
    }

    function handleWindowResize(e) {
        //video.width = Std.int( window.innerWidth / 2 );
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }

    function handleDeviceOrientation( e : DeviceOrientationEvent ) {
        if( net.connected ) {
            net.sendMessage( { type: 'orientation', alpha : e.alpha, beta: e.beta, gamma: e.gamma } );
        }
    }
}
