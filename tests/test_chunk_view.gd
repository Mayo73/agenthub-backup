extends "res://tests/base_test.gd"

var view: ChunkView


func setup() -> void:
	view = ChunkView.new(Vector2i(1, -1), SeafloorHeight.new())
	(Engine.get_main_loop() as SceneTree).root.add_child(view)


func teardown() -> void:
	view.free()


func test_name_und_lage() -> void:
	check_eq(String(view.name), "Chunk_1_-1", "Name der Kachel")
	check(view.position.is_equal_approx(Vector3(64, 0, -64)), "Lage der Kachel")


func test_inhalt() -> void:
	check_eq(view.get_child_count(), 1 + view.layout.items.size(), "Boden plus alle Einträge")
	check_eq(view.weeds.size(), view.layout.count("seegras"), "Seegras-Anzahl")


func test_boden() -> void:
	check(view.floor_mesh.mesh is ArrayMesh, "Boden ist ein ArrayMesh")
	var arrays: Array = (view.floor_mesh.mesh as ArrayMesh).surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	check(verts.size() >= (ChunkView.GRID + 1) * (ChunkView.GRID + 1), "genug Eckpunkte")
