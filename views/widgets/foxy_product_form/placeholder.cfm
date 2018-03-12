<cfscript>
	productName = args.productName ?: "";
</cfscript>
<cfoutput>#translateResource( uri='widgets.foxy_product_form:title' )#: #productName#</cfoutput>