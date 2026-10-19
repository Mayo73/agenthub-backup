class_name ModuleManifest
extends RefCounted
## Manifest eines Moduls: Metadaten, Version und Fähigkeiten.

var id := ""
var name := ""
var version := "0.0.0"
var engine_api := 1
var requires: Array[String] = []
var optional := true
var capabilities: Array[String] = []


static func from_dict(d: Dictionary) -> ModuleManifest:
	var m := ModuleManifest.new()
	m.id = str(d.get("id", ""))
	m.name = str(d.get("name", ""))
	m.version = str(d.get("version", "0.0.0"))
	m.engine_api = int(d.get("engine_api", 1))
	m.requires.clear()
	for r in d.get("requires", []):
		m.requires.append(str(r))
	m.optional = bool(d.get("optional", true))
	m.capabilities.clear()
	for c in d.get("capabilities", []):
		m.capabilities.append(str(c))
	return m


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"version": version,
		"engine_api": engine_api,
		"requires": requires,
		"optional": optional,
		"capabilities": capabilities
	}


func validate() -> Array[String]:
	var probleme: Array[String] = []
	if id == "":
		probleme.append("id fehlt")
	if name == "":
		probleme.append("name fehlt")
	var version_regex := RegEx.new()
	version_regex.compile("^[0-9]+\\.[0-9]+\\.[0-9]+$")
	if version_regex.search(version) == null:
		probleme.append("version muss die Form 1.2.3 haben")
	return probleme
