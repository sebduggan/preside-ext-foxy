component {

	public void function configure( required struct config ) {
		var settings            = arguments.config.settings            ?: {};
		var coldbox             = arguments.config.coldbox             ?: {};
		var i18n                = arguments.config.i18n                ?: {};
		var interceptors        = arguments.config.interceptors        ?: {};
		var interceptorSettings = arguments.config.interceptorSettings ?: {};
		var cacheBox            = arguments.config.cacheBox            ?: {};
		var wirebox             = arguments.config.wirebox             ?: {};
		var logbox              = arguments.config.logbox              ?: {};
		var environments        = arguments.config.environments        ?: {};

		interceptorSettings.customInterceptionPoints.append( "preFoxyDatafeedProcessTransaction"  );
		interceptorSettings.customInterceptionPoints.append( "postFoxyDatafeedProcessTransaction" );

		settings.assetmanager.derivatives.foxySquare = {
			  permissions     = "inherit"
			, transformations = [ { method="resize", args={ width=300, height=300, quality="highQuality", maintainAspectRatio=true } } ]
		};
		settings.assetmanager.derivatives.foxyFormDisplay200 = {
			  permissions     = "inherit"
			, transformations = [ { method="resize", args={ width=200, quality="highQuality", maintainAspectRatio=true } } ]
		};
		settings.assetmanager.derivatives.foxyFormDisplay400 = {
			  permissions     = "inherit"
			, transformations = [ { method="resize", args={ width=400, quality="highQuality", maintainAspectRatio=true } } ]
		};


	}
}