/**
 * @labelField                   xml_hash
 * @dataManagerGroup             Foxy
 * @versioned                    false
 * @dataManagerDefaultSortOrder  datecreated desc
 * @dataManagerGridFields        xml_hash,datecreated
 */

component dataManagerGroup="Foxy" {
	property name="raw_xml"  type="string" dbtype="text";
	property name="json"     type="string" dbtype="text";
	property name="xml_hash" type="string" dbtype="varchar" maxlength=32;
}