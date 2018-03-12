/**
 * @dataManagerGroup            Foxy
 * @dataManagerSortable         true
 * @dataManagerDefaultSortOrder sortorder
 * @dataManagerGridFields       label,price,datecreated,datemodified
 */

component {
	property name="price"     type="numeric" dbtype="float" required=true;
	property name="sortorder" type="numeric" dbtype="int";

}