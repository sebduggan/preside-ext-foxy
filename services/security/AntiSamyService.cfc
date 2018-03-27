component extends="preside.system.services.security.AntiSamyService" {

	private void function _setupPolicyFiles() {
		var libPath       = _getLibPath();
		var customLibPath = ExpandPath( "/application/extensions/preside-ext-foxy/services/security/antisamycustom" );

		_setPolicyFiles ( {
			  antisamy = libPath       & '/antisamy-anythinggoes-1.4.4.xml'
			, ebay     = libPath       & '/antisamy-ebay-1.4.4.xml'
			, myspace  = libPath       & '/antisamy-myspace-1.4.4.xml'
			, slashdot = libPath       & '/antisamy-slashdot-1.4.4.xml'
			, tinymce  = libPath       & '/antisamy-tinymce-1.4.4.xml'
			, preside  = libPath       & '/antisamy-preside-1.4.4.xml'
			, custom   = customLibPath & '/antisamy-preside-custom-1.4.4.xml'
		} );
	}

}