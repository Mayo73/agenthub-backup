---
id: A-0001
title: Titelbild für das Hauptmenü
project: drift
kind: bild
status: fertig
target: assets/menu/title_background.png
attempted:
credits: 0.25
---
## Beschreibung
Hintergrundbild für das Hauptmenü (`scenes/main_menu.tscn`), füllt das ganze Fenster (1280x720, Seitenverhältnis 16:9). Es ersetzt den dunklen `ColorRect` „Background“ als Blickfang; Titel „DRIFT“ und Knöpfe bleiben Godot-Elemente darüber, mittig in einer Spalte von etwa 320 Pixeln Breite.

Motiv: ein Sportwagen driftet in isometrischer Ansicht (wie im Spiel, schräg von oben) durch eine Kurve einer Rennstrecke, mit Reifenrauch und dunklen Reifenspuren auf dem Asphalt. Grüne Wiese neben der Strecke (passend zur Spielfarbe, etwa #295C33), rot-weiße Randsteine, ein paar Reifenstapel. Abendlicht.

Stil: klare, stilisierte Spielgrafik mit flachen Farben und weichen Verläufen, keine Fotografie. Diesen Stil nach dem ersten brauchbaren Ergebnis im Projekt-`CLAUDE.md` unter „Stil“ festhalten; er gilt für alle weiteren Drift-Grafiken.

Aufbau: Das Auto und der meiste Rauch im linken oder rechten Drittel, die Bildmitte ruhiger und dunkler, damit Titel und Knöpfe lesbar bleiben.

Nicht im Bild: Text, Schrift, Zahlen, Logos, Marken, echte Automodelle, Menschen.

Vorschlag: `gpt_image_2_5`, Seitenverhältnis 16:9 (0,25 Credits laut Kostenabfrage). Passt der Entwurf nicht, ein zweiter Versuch mit angepasstem Prompt oder `nano_banana_2`.

## Nachbearbeitung
- auf genau 1280x720 bringen: `bild.gd … --size 1280x720` (vorher bei Bedarf zuschneiden, damit nichts verzerrt)
- kein Freistellen nötig

## Einbau (Ticket nach Fertigstellung)
Danach ein Ticket mit `after: A-0001` planen: in `scenes/main_menu.tscn` einen `TextureRect` „BackgroundImage“ über dem `ColorRect` „Background“ und unter „Buttons“ einfügen, Textur `res://assets/menu/title_background.png`, ganzes Fenster füllend (`stretch_mode` „keep aspect covered“), dazu ein halbtransparenter dunkler `ColorRect` hinter der Knopfspalte für die Lesbarkeit. Test: Der Knoten existiert und hat eine geladene Textur.

## Verlauf
- 2026-10-16: angelegt auf Wunsch des Nutzers als erster echter Medien-Auftrag
- 2026-10-16 03:10: erzeugt mit gpt_image_2_5 (1 Generierung, 0,25 Credits), nachbearbeitet mit bild.gd, im Projekt committet (372dcaa)
