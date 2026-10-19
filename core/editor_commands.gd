class_name EditorCommands
extends RefCounted

## Befehle für die Editor-Auswahl und -Suche.
## Nutzt `EditorSession` für die eigentliche Logik.


static func register_all(commands: CommandRegistry, session: EditorSession) -> void:
	## Alle Editor-Befehle beim angegebenen Registry registrieren.

	var select_handler: Callable = func(args: Dictionary) -> CommandResult:
		var id: String = args["id"]
		if not session.select(id):
			return CommandResult.error(CommandResult.NOT_FOUND, "Objekt %s gibt es nicht" % id)
		return CommandResult.success({"selected": session.selected})

	commands.register(
		"editor.select",
		"Objekt auswählen",
		{"id": "string"},
		select_handler
	)

	var selection_handler: Callable = func(_args: Dictionary) -> CommandResult:
		return CommandResult.success({
			"selected": session.selected,
			"object": session.selected_object()
		})

	commands.register(
		"editor.selection",
		"Ausgewähltes Objekt abfragen",
		{},
		selection_handler
	)

	var search_handler: Callable = func(args: Dictionary) -> CommandResult:
		var text: String = args["text"]
		return CommandResult.success({"ids": session.search(text)})

	commands.register(
		"editor.search",
		"Objekte suchen",
		{"text": "string"},
		search_handler
	)

	var path_handler: Callable = func(args: Dictionary) -> CommandResult:
		var id: String = args["id"]
		var path: Array[String] = session.path_of(id)
		if path.is_empty():
			return CommandResult.error(CommandResult.NOT_FOUND, "Objekt %s gibt es nicht" % id)
		return CommandResult.success({"path": path})

	commands.register(
		"editor.path",
		"Pfad eines Objekts im Szenenbaum",
		{"id": "string"},
		path_handler
	)
