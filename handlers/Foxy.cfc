component {

	property name="foxyService" inject="foxyService";

	public string function datafeed( event, rc, prc, args={} ) {
		var datafeed = rc.FoxyData ?: "";

		try {
			var foxyData = foxyService.processDatafeed( datafeed );

			for( var transaction in foxyData.transactions ) {
				announceInterception( "preFoxyDatafeedProcessTransaction" );
				announceInterception( "postFoxyDatafeedProcessTransaction" );
			}

			event.renderData( type="text", data="foxy" );
		}
		catch( any e ) {
			event.renderData( type="text", data="Error: " & e.message );
		}

	}

}
