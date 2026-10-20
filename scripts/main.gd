class_name Main
extends Control
## Wurzel der App: Kopfzeile mit Prototyp-Hinweis, Inhaltsbereich für den aktuellen Bildschirm
## und Reiterleiste. Alle Bedienelemente entstehen im Code.

const SCREENS: Array[String] = ["entdecken", "matches", "profil"]
const TAB_TITLES := {"entdecken": "Entdecken", "matches": "Matches", "profil": "Profil"}

var banner: Label
## Hier hängt der aktuelle Bildschirm (genau ein Kind).
var content: Control
var tab_bar: HBoxContainer
## Bildschirmname -> Button der Reiterleiste
var tab_buttons: Dictionary = {}
var current_screen := ""
## Der aktuell angezeigte Bildschirm (Kind von content).
var screen: Control = null
## Gesamter Zustand der App, beim Start aus store_path geladen.
var state: AppState
var store_path := StateStore.DEFAULT_PATH
## Demo-Leiste zum Wechseln der Testperson.
var perspective: PerspectiveBar
## Match-ID des offenen Chats (nur wenn current_screen "chat" ist).
var chat_id := ""


func _ready() -> void:
	state = StateStore.load_state(store_path)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = UiStyle.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(layout)

	var banner_box := PanelContainer.new()
	banner_box.add_theme_stylebox_override("panel", UiStyle.panel(UiStyle.DEMO, 0))
	banner = UiStyle.label("PROTOTYP · nur fiktive Testprofile", UiStyle.SIZE_SMALL, UiStyle.BG)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_box.add_child(banner)
	layout.add_child(banner_box)

	perspective = PerspectiveBar.new()
	perspective.set_state(state)
	perspective.switched.connect(_on_switched)
	layout.add_child(perspective)

	content = Control.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.clip_contents = true
	layout.add_child(content)

	tab_bar = HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 0)
	for screen_name in SCREENS:
		var b := UiStyle.tab_button(TAB_TITLES[screen_name])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(show_screen.bind(screen_name))
		tab_bar.add_child(b)
		tab_buttons[screen_name] = b
	layout.add_child(tab_bar)

	show_screen("entdecken")


## Zeigt einen Bildschirm im Inhaltsbereich; der vorherige wird entfernt.
func show_screen(screen_name: String) -> void:
	if screen_name == "chat":
		show_chat(chat_id)
		return
	if screen != null:
		content.remove_child(screen)
		screen.queue_free()
	screen = _make_screen(screen_name)
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_child(screen)
	current_screen = screen_name
	for n in tab_buttons:
		(tab_buttons[n] as Button).disabled = n == screen_name


## Zeigt den Chat zu einem Match; der Reiter „Matches“ bleibt als aktiv markiert.
func show_chat(match_id: String) -> void:
	if screen != null:
		content.remove_child(screen)
		screen.queue_free()
	chat_id = match_id
	var chat := ChatScreen.new(state, match_id)
	chat.changed.connect(save)
	chat.back.connect(show_screen.bind("matches"))
	chat.open_meeting.connect(show_meeting)
	screen = chat
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_child(screen)
	current_screen = "chat"
	for n in tab_buttons:
		(tab_buttons[n] as Button).disabled = n == "matches"


## Zeigt das Treffen zu einem Match; der Reiter „Matches" bleibt als aktiv markiert.
func show_meeting(match_id: String) -> void:
	if screen != null:
		content.remove_child(screen)
		screen.queue_free()
	var meeting := MeetingScreen.new(state, match_id)
	meeting.changed.connect(save)
	meeting.back.connect(show_chat.bind(match_id))
	screen = meeting
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_child(screen)
	current_screen = "treffen"
	for n in tab_buttons:
		(tab_buttons[n] as Button).disabled = n == "matches"


## Wechselt die Testperson, speichert und baut den aktuellen Bildschirm neu auf.
## Ein offener Chat oder Treffen geht zurück zur Liste, weil die neue Person vielleicht nicht beteiligt ist.
func _on_switched(id: String) -> void:
	state.switch_to(id)
	save()
	perspective.set_state(state)
	if current_screen == "chat" or current_screen == "treffen":
		show_screen("matches")
	else:
		show_screen(current_screen)


func save() -> void:
	StateStore.save(state, store_path)


## Für Tests und Spieltests: eigene Speicherdatei verwenden und daraus neu laden.
func use_store(path: String) -> void:
	store_path = path
	state = StateStore.load_state(path)
	perspective.set_state(state)
	show_screen(current_screen)


## Alle Profile, Matches, Nachrichten und Treffen auf die ursprünglichen Testdaten zurücksetzen.
func reset_demo() -> void:
	state = StateStore.reset(store_path)
	perspective.set_state(state)
	show_screen("entdecken")


func _on_reset_demo() -> void:
	reset_demo()


## Profil gespeichert: Zustand sichern, die Demo-Leiste zeigt den neuen Namen.
func _on_profile_changed() -> void:
	save()
	perspective.set_state(state)


## Baut den Bildschirm zu einem Namen. Noch nicht umgesetzte Bildschirme zeigen nur den Titel.
func _make_screen(screen_name: String) -> Control:
	if screen_name == "entdecken":
		var discover: DiscoverScreen = DiscoverScreen.new(state)
		discover.changed.connect(save)
		discover.open_chat.connect(show_chat)
		return discover
	if screen_name == "matches":
		var matches := MatchesScreen.new(state)
		matches.open_chat.connect(show_chat)
		return matches
	if screen_name == "profil":
		var profile := ProfileScreen.new(state)
		profile.changed.connect(_on_profile_changed)
		profile.reset_requested.connect(_on_reset_demo)
		return profile
	var l := UiStyle.label(TAB_TITLES.get(screen_name, screen_name), UiStyle.SIZE_TITLE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l
