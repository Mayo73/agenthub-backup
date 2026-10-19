extends "res://tests/base_test.gd"

var reg := ProviderRegistry.new()


func setup() -> void:
	reg = ProviderRegistry.new()
	reg.add("ollama", "Ollama", "lokal", 1)
	reg.add("claude", "Claude", "hub", 2)


func test_keiner() -> void:
	var result := reg.active()
	check(result.code == "dependency", "active() sollte dependency zurückgeben, wenn keiner erreichbar ist")
	check(result.message.begins_with("Kein KI-Anbieter erreichbar"), "Meldung muss mit 'Kein KI-Anbieter erreichbar' beginnen")


func test_prioritaet() -> void:
	reg.set_available("ollama", true)
	reg.set_available("claude", true)
	var result := reg.active()
	check(result.is_ok(), "active() sollte ok zurückgeben, wenn einer erreichbar ist")
	check(result.data["id"] == "ollama", "ollama sollte gewählt werden (niedrigere Priorität)")


func test_bevorzugt() -> void:
	reg.set_available("ollama", true)
	reg.set_available("claude", true)
	var result := reg.prefer("claude")
	check(result.is_ok(), "prefer() sollte ok zurückgeben")
	result = reg.active()
	check(result.data["id"] == "claude", "nach prefer('claude') sollte claude aktiv sein")

	reg.set_available("claude", false)
	result = reg.active()
	check(result.data["id"] == "ollama", "nach set_available(claude, false) sollte ollama aktiv sein")


func test_fehler() -> void:
	var reg_test := ProviderRegistry.new()
	var result := reg_test.add("x", "X", "cloud")
	check(result.code == "invalid_argument", "add mit unbekanntem kind sollte invalid_argument zurückgeben")
	check(result.message == "Art cloud ist unbekannt", "Meldung muss exakt lauten")

	reg_test.add("ollama", "O", "lokal", 1)
	result = reg_test.add("ollama", "O", "lokal")
	check(result.code == "conflict", "add mit existierender Kennung sollte conflict zurückgeben")
	check(result.message == "Anbieter ollama gibt es schon", "Meldung muss exakt lauten")

	result = reg_test.prefer("gibts")
	check(result.code == "not_found", "prefer bei unbekanntem Anbieter sollte not_found zurückgeben")
	check(result.message == "Anbieter gibts gibt es nicht", "Meldung muss exakt lauten")


func test_text() -> void:
	reg.set_available("ollama", true)
	reg.set_available("claude", false)
	var text := reg.status_text()
	check(text == "Claude: nicht erreichbar\nOllama: erreichbar", "status_text() sollte korrekte Zeilen mit Namen zurückgeben")
