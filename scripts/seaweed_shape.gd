class_name SeaweedShape
extends RefCounted
## Form einer gebogenen Seegraspflanze: ein nach oben schmaler werdendes Band entlang einer
## leicht gebogenen Wirbelsäule. Koordinaten relativ zum Fuß der Pflanze, y zeigt nach oben.

const SEGMENTS := 8


## Punkte der Wirbelsäule vom Fuß bis zur Spitze; die Biegung nimmt nach oben zu.
static func spine(height: float, bend: float, segments: int = SEGMENTS) -> PackedVector3Array:
	var points := PackedVector3Array()
	for i in segments + 1:
		var t := i / float(segments)
		points.append(Vector3(bend * height * 0.35 * t * t, height * t, 0.0))
	return points


## Breite des Bandes an der Stelle t (0 = Fuß, 1 = Spitze).
static func width_at(t: float, base_width: float) -> float:
	return base_width * (1.0 - 0.8 * t)


## Band aus Dreiecken entlang der Wirbelsäule; das Material setzt der Aufrufer.
static func build_mesh(height: float, bend: float, base_width: float = 0.35) -> ArrayMesh:
	var points := spine(height, bend)
	var left := PackedVector3Array()
	var right := PackedVector3Array()
	for i in points.size():
		var half := width_at(i / float(SEGMENTS), base_width) * 0.5
		left.append(points[i] + Vector3(0.0, 0.0, -half))
		right.append(points[i] + Vector3(0.0, 0.0, half))

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in SEGMENTS:
		st.add_vertex(left[i])
		st.add_vertex(right[i])
		st.add_vertex(left[i + 1])
		st.add_vertex(right[i])
		st.add_vertex(right[i + 1])
		st.add_vertex(left[i + 1])
	st.generate_normals()
	return st.commit()
