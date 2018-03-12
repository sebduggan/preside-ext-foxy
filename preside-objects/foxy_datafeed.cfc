/**
 * @dataManagerGroup Foxy
 * @versioned        false
 */

component dataManagerGroup="Foxy" {
	property name="label"   required=false formula="date_format( ${prefix}datecreated, get_format( date, 'ISO' ) )";
	property name="raw_xml" type="string" dbtype="text";
	property name="json"    type="string" dbtype="text";
}