class_name SoundSynth
extends RefCounted
## Erzeugt Klänge im Code (keine Audiodateien nötig). Abtastwerte liegen zwischen -1 und 1.

const MIX_RATE := 22050

enum Wave { SINE, SQUARE, SAW }


## Wert der Wellenform bei Phase `t` (eine Schwingung = 1.0), Ergebnis -1 .. 1.
static func wave_value(wave: int, t: float) -> float:
	var p := fposmod(t, 1.0)
	match wave:
		Wave.SQUARE:
			return 1.0 if p < 0.5 else -1.0
		Wave.SAW:
			return 2.0 * p - 1.0
		_:
			return sin(p * TAU)


## Wandelt Abtastwerte in 16-Bit-PCM (little endian) um. Werte außerhalb -1 .. 1 werden begrenzt.
static func to_pcm16(samples: PackedFloat32Array) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(round(clampf(samples[i], -1.0, 1.0) * 32767.0)))
	return bytes


## Macht aus Abtastwerten einen abspielbaren Stream (mono, MIX_RATE), auf Wunsch als Schleife.
static func make_stream(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = to_pcm16(samples)
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream
