class_name Utils extends Object

const variant_type_name = {
	TYPE_INT: "int",
	TYPE_FLOAT: "float",
	TYPE_STRING: "string",
	TYPE_DICTIONARY: "dictionary",
}


static func validate_dictionary(dictionary: Dictionary, schema: Dictionary, path: String = "") -> Dictionary:
	var issues = {}
	for key in dictionary:
		var key_path = "%s.%s" % [path, key]
		var type = typeof(dictionary[key])
		if (type == TYPE_DICTIONARY):
			issues.merge(validate_dictionary(dictionary[key], schema[key], key_path))
		elif (schema.has(key) && (type != schema[key])):
			issues[key_path] = "expected [%s] but got [%s]" % [variant_type_name[schema[key]], variant_type_name[type]]
	return issues


static func recursive_merge(a: Dictionary, b: Dictionary, overwrite: bool = false) -> void:
	for key in b:
		if (a.has(key) && (a[key] is Dictionary) && (b[key] is Dictionary)):
			Utils.recursive_merge(a[key], b[key])
		elif (!a.has(key) || overwrite):
			a[key] = b[key]
