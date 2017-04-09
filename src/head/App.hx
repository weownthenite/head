package head;

import js.Browser.window;
import js.Browser.console;
import om.Activity;

@app({
	name: 'head',
	version: '0.0.0'
})
class App implements om.App {

	static function init() {
		console.info( 'H.E.A.D' );
		Activity.boot( new head.app.ConnectActivity() );
	}

}
