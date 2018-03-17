component {

	private function index( event, rc, prc, args={} ) {
		return renderViewlet( event='foxy._renderForm', args=args );
	}

	private function placeholder( event, rc, prc, args={} ) {
		args.productName = renderLabel( "foxy_product", args.foxy_product );
		return renderView( view='widgets/foxy_product_form/placeholder', args=args );
	}
}
