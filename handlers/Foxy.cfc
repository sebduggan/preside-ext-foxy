component {

	property name="foxyService"          inject="foxyService";

	public string function datafeed( event, rc, prc, args={} ) {
		var datafeed = rc.FoxyData ?: "";

		try {
			var foxyData     = foxyService.processDatafeed( datafeed );
			var transactions = foxyData.transactions ?: [];

			foxyService.processTransactions( transactions );
			event.renderData( type="text", data="foxy" );
		}
		catch( any e ) {
			var message = e.message.len() ? e.message : e.detail;
			event.renderData( type="text", data="Error: " & message );
		}
	}

}
