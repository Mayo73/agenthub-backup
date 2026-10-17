# Zelltypen der Zellenphase

Alle elf Arten nutzen dieselbe KI (`scripts/ai_brain.gd`): Sie fliehen vor Fleisch- und Allesfressern, die mehr als 1,2-mal so groß sind, jagen als Fleisch- oder Allesfresser Zellen, die kleiner als das 0,8-Fache sind, suchen sonst passende Nahrung und treiben, wenn nichts in Sicht ist (Sichtweite 350 Pixel). Das gilt auch gegenüber der Spielerzelle. Ihre Teile (`scripts/species_parts.gd`) sind sichtbar, wirken im Kampf aber nicht; beißen können nur Fleisch- und Allesfresser.

Größen der Abschnitte (Radius): 0 = 12, 1 = 18, 2 = 27, 3 = 40, 4 = 60 Pixel.

| Art | Abschnitt | Ernährung | Verhalten | Aussehen | Gefahr für den Spieler |
|-----|-----------|-----------|-----------|----------|------------------------|
| Blasenling | 0 | Pflanzenfresser | flieht, sucht Pflanzen | hellgrün, ohne Muster, Filtermaul, Wimpern | 0 (harmlos) |
| Flimmerling | 0 | Pflanzenfresser | flieht, sucht Pflanzen, schnell (140 Pixel/s) | hellblau, Punkte, gestreckt, Filtermaul, Geißel | 0 (harmlos) |
| Schnapper | 1 | Fleischfresser | jagt, flieht vor Größeren | orange, Streifen, gestreckt, Kiefer, Geißel | 15 |
| Stachelkugel | 1 | Pflanzenfresser | flieht, sucht Pflanzen, langsam | gelblich, Punkte, rundlich, acht Stacheln, Filtermaul | 0 (beißt nicht) |
| Giftling | 2 | Allesfresser | jagt Kleinere, frisst Pflanzen und Fleisch | lila, Flecken, Rüssel, zwei Giftdrüsen | 8 |
| Zitterzelle | 2 | Fleischfresser | jagt, flieht vor Größeren | gelb, Streifen, stark gestreckt, Kiefer, leuchtendes Elektroorgan, Geißel | 12 |
| Panzerling | 2 | Pflanzenfresser | flieht, sucht Pflanzen, langsam, 110 Gesundheit | braun, Flecken, Filtermaul, zwei Stacheln nach hinten | 0 (beißt nicht) |
| Weidezelle | 3 | Pflanzenfresser | flieht, sucht Pflanzen | türkis, Flecken, Filtermaul, Wimpern an beiden Seiten | 0 (harmlos) |
| Hornjäger | 3 | Fleischfresser | jagt, sehr schnell (170 Pixel/s) | rotbraun, Punkte, gestreckt, Kiefer, zwei Hornstacheln, Düse | 25 |
| Riesenschlund | 4 | Fleischfresser | jagt, langsam (80 Pixel/s), 300 Gesundheit | dunkellila, Flecken, gedrungen, Kiefer, zwei Geißeln | 40 |
| Schwebqualle | 4 | Pflanzenfresser | flieht, sucht Pflanzen, sehr langsam (50 Pixel/s), 250 Gesundheit | blassrosa, ohne Muster, gedrungen, Filtermaul, Wimpern rundum | 0 (harmlos) |

## Flimmerling
Schnelle hellblaue Zelle mit Punkten und gestrecktem Körper. Sie nutzt ein Filtermaul zur Nahrungsaufnahme und eine Geißel zum Vortrieb. Schon ab Abschnitt 1 ist die Spielerzelle groß genug, dass der Flimmerling vor ihr flieht; er gilt als agile Beute für größere Zellen.

## Panzerling
Braune Zelle mit Flecken und einer robusten Struktur. Sie besitzt zwei Stacheln im hinteren Bereich, die jedoch nicht beißen – sie sind rein dekorativ. Mit 110 Gesundheit ist sie widerstandsfähiger als viele andere Arten in Abschnitt 2.

## Schwebqualle
Große, blassrosa Zelle ohne Muster und mit gedrungenem Körper. Sie bewegt sich mit Wimpern rundum fort und ist eine große, aber wehrlose Beute für die Spielerzelle im Abschnitt 4. Mit 250 Gesundheit verfügt sie über viel Lebenskraft, doch sie kann nicht aktiv verteidigen.

## Blasenling
Kleine hellgrüne Zelle ohne Muster mit Filtermaul und schlagenden Wimpern. Sie frisst Pflanzen und flieht vor jedem Fleisch- oder Allesfresser, der deutlich größer ist. Schon ab Abschnitt 1 ist die Spielerzelle groß genug, dass der Blasenling vor ihr flieht und leichte Beute wird.

## Schnapper
Gestreckte orange Zelle mit Streifen, Kiefer und Geißel. Als Fleischfresser jagt er kleinere Zellen, auch die Spielerzelle im Abschnitt 0, und flieht vor größeren Fleischfressern. Ab Abschnitt 2 dreht sich das Verhältnis um: Er flieht vor der Spielerzelle und wird zur Beute.

## Stachelkugel
Rundliche gelbliche Zelle mit Punkten und acht Stacheln um den Körper. Sie ist ein langsamer Pflanzenfresser, beißt nicht und flieht vor größeren Fleischfressern; die Stacheln sind nur Aussehen. Ab Abschnitt 2 flieht sie vor der Spielerzelle.

## Giftling
Lila Zelle mit Flecken, Rüssel und zwei Giftdrüsen. Als Allesfresser frisst er Pflanzen und Fleisch und jagt kleinere Zellen; er hinterlässt keine Giftwolken (das kann nur die Spielerzelle mit dem Giftteil). Ab Abschnitt 3 flieht er vor der Spielerzelle.

## Zitterzelle
Stark gestreckte gelbe Zelle mit Streifen, Kiefer, Geißel und einem leuchtenden Elektroorgan. Sie jagt als Fleischfresser kleinere Zellen und flieht vor größeren; das Elektroorgan ist sichtbar, entlädt sich aber nicht. Ab Abschnitt 3 flieht sie vor der Spielerzelle.

## Weidezelle
Große türkise Zelle mit Flecken, Filtermaul und Wimpern an beiden Seiten. Sie frisst Pflanzen und flieht vor größeren Fleischfressern, vor allem vor dem Riesenschlund. Erst im Abschnitt 4 ist die Spielerzelle groß genug, dass die Weidezelle vor ihr flieht.

## Hornjäger
Gestreckte rotbraune Zelle mit Punkten, Kiefer, zwei Hornstacheln und einer Düse; mit 170 Pixeln pro Sekunde die schnellste Art. Er jagt alle deutlich kleineren Zellen und flieht nur vor dem Riesenschlund. Ab Abschnitt 4 flieht er vor der Spielerzelle; vorher ist er die gefährlichste Bedrohung.

## Riesenschlund
Gedrungene dunkellila Zelle mit Flecken, Kiefer und zwei Geißeln. Er ist langsam, hat 300 Gesundheit und beißt mit 40 am stärksten. Keine Art ist groß genug, um ihn in die Flucht zu schlagen, auch die Spielerzelle im Abschnitt 4 nicht (gleiche Größe); besiegen lässt er sich nur im Kampf.

## Ein-Biss-Regel
Eine Zelle gilt als deutlich kleiner, wenn ihr Radius höchstens halb so groß ist wie der Radius der Spielerzelle (`CombatRules.SWALLOW_RATIO` = 0,5). Bei den Größenabschnitten (Radius 12, 18, 27, 40 und 60 Pixel) heißt das: mindestens zwei Abschnitte kleiner. Beißt die Spielerzelle mit einem Mundwerkzeug für Fleisch (Fleisch- oder Allesfresser) eine solche Zelle, verschluckt sie sie mit einem Biss ganz, auch bei voller Gesundheit. Sie bekommt dann sofort so viel Nahrung, DNA und Wachstum wie die Fleischbrocken einer besiegten Zelle zusammen (`CombatRules.swallow_value()`, 3 × 2 = 6), und ein Beute-Teil wird wie bei einem Sieg freigeschaltet. Gleich große oder nur wenig kleinere Zellen verletzt ein Biss weiterhin nur. Vorbild ist Spore, wo kleine Zellen ebenfalls im Ganzen gefressen werden.

## Vorführung
Die Vorführszenen lassen sich mit folgenden Startbefehlen starten:

- `-- --szene=jagd`: Ein Schnapper jagt die kleine Spielerzelle. Zeigt das Jagdverhalten von Fleischfressern.
- `-- --szene=flucht`: Ein Blasenling flieht vor der großen Spielerzelle. Zeigt das Fluchtverhalten.
- `-- --szene=nahrung`: Ein Blasenling schwimmt zur Pflanzennahrung. Zeigt die Nahrungssuche.
- `-- --szene=verschlingen`: Die Spielerzelle (Fleischfresser, Abschnitt 2) verschluckt den kleinen Blasenling mit einem Biss, den gleich großen Panzerling verletzt ein Biss nur. Zeigt die Ein-Biss-Regel.
