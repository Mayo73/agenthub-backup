class_name ChunkView
extends Node3D
## Zeichnet eine Kachel des Meeresbodens: Bodenfläche mit Höhenprofil, gebogenes Seegras und Felsen.
## WorldChunks entscheidet, wann eine Kachel entsteht und wann sie wieder entfernt wird.

const GRID := 16

var chunk: Vector2i
var layout: ChunkLayout
var floor_mesh: MeshInstance3D
var weeds: Array[MeshInstance3D] = []
var time := 0.0


func _init(c: Vector2i, floor: SeafloorHeight) -> void:
	chunk = c
	name = "Chunk_%d_%d" % [c.x, c.y]
	position = WorldChunks.origin_of(c)
	floor_mesh = MeshInstance3D.new()
	floor_mesh.name = "Floor"
	floor_mesh.mesh = _build_floor(floor)
	floor_mesh.material_override = FishTextures.floor_material()
	add_child(floor_mesh)

	var weed_mat := FishModel.material(Color(0.25, 0.55, 0.3)).duplicate() as StandardMaterial3D
	weed_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var rock_mat := FishTextures.rock_material()
	layout = ChunkLayout.new(c, floor)
	for item: Dictionary in layout.items:
		var m := MeshInstance3D.new()
		var h: float = item["height"]
		var p: Vector3 = item["position"]
		m.position = p - position
		if item["kind"] == "seegras":
			var bend: float = item["bend"]
			m.mesh = SeaweedShape.build_mesh(h, bend)
			m.material_override = weed_mat
			weeds.append(m)
		else:
			m.mesh = FishModel.sphere(1.0)
			m.material_override = rock_mat
			m.scale = Vector3(h, h * 0.6, h * 0.8)
		add_child(m)


## Bodenraster mit (GRID + 1)² Punkten, Höhen aus SeafloorHeight, UV in Weltkoordinaten / 8.
func _build_floor(floor: SeafloorHeight) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step := WorldChunks.SIZE / GRID
	for iz in GRID + 1:
		for ix in GRID + 1:
			var lx := ix * step
			var lz := iz * step
			var wx := position.x + lx
			var wz := position.z + lz
			st.set_uv(Vector2(wx / 8.0, wz / 8.0))
			st.add_vertex(Vector3(lx, floor.height_at(wx, wz), lz))
	for iz in GRID:
		for ix in GRID:
			var a := iz * (GRID + 1) + ix
			var b := a + 1
			var d := a + GRID + 1
			var e := d + 1
			st.add_index(a)
			st.add_index(b)
			st.add_index(d)
			st.add_index(b)
			st.add_index(e)
			st.add_index(d)
	st.generate_normals()
	return st.commit()


func _process(delta: float) -> void:
	time += delta
	for i in weeds.size():
		weeds[i].rotation.z = ReefView.sway(time, i * 0.7)
