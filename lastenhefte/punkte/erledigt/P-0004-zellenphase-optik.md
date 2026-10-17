---
id: P-0004
projekt: zellenphase
art: ansehen
status: erledigt
erstellt: 2026-10-17
---
# Zellenphase: Optik beurteilen

## Worum es geht
Bitte anhand der Screenshots beurteilen. Vorbild ist die Zellenphase von Spore.

1. **Gesamteindruck:** Wirkt das Spiel stimmig (Wasserhintergrund, Nahrung, Zellen, Titelbild im Hauptmenü)?
2. **Zellen:** Sind Körper (Textur, Muster, Membran), Geißel und Augen gut erkennbar? Sieht man Treffer (Aufblitzen)?
3. **Teile in den Vorführszenen:** Erkennt man Stacheln, Gift und Elektroorgan und ihre Wirkung?
4. **Lesbarkeit:** Sind Anzeigen und Texte gut lesbar?

Konkrete Mängel bitte mit Bildname und Stelle nennen.

## Material
- `P-0004/menue-1.png`: Hauptmenü mit Titelbild
- `P-0004/jagd-1.png`, `jagd-2.png`, `stachel-*.png`, `gift-*.png`, `elektro-*.png`: Vorführszenen, ganzes Bild in Spielgröße (1280x720)
- `P-0004/*-nah.png`: dieselben Szenen, Bildmitte vergrößert, damit Zellkörper, Geißel, Augen und Teile erkennbar sind. Im Spiel selbst sind die Zellen so klein wie auf den ganzen Bildern.
- Wirkungen, die sich nur in Bewegung zeigen (Giftwolken, Blitze, Aufblitzen bei Treffern), sind auf Standbildern kaum zu sehen. Dafür bei Bedarf die Vorführszene selbst starten.
- Nur falls die Bilder nicht reichen: `C:\Users\wiens\AgentHub\hub\spielen.cmd zellenphase --szene=jagd` (weitere Szenen: flucht, nahrung, stachel, gift, elektro, tempo, wendigkeit)

## Antwort

17.10.2026 – Alle 13 beigelegten Bilder geprüft; zusätzlich Hauptmenü, eine neue Pflanzenfresser-Partie und die Elektro-Vorführszene live angesehen.

1. Gesamteindruck: menue-1.png hat eine zusammenhängende Wasser-/Mikroorganismen-Farbwelt und klar lesbare Menüeinträge. Der Spielhintergrund greift diese Farben auf. Die detaillierte Titelgrafik und die sehr kleinen, schlicht dargestellten Spielzellen wirken jedoch noch unterschiedlich ausgearbeitet.
2. Hoher Nachbesserungsbedarf bei der Spielgröße: In jagd-1.png/jagd-2.png sowie stachel-*, gift-* und elektro-* ist die zentrale Spielerzelle bei 1280 × 720 nur ungefähr 25–30 Pixel breit. Augen, Mund und Organe sind dadurch im normalen Bild kaum unterscheidbar. Die Nahbilder beweisen, dass Details vorhanden sind, lösen aber die Lesbarkeit während des Spiels nicht. Kamera/Größendarstellung und Silhouetten so abstimmen, dass Zelltyp, Mundrichtung und Organ bereits bei normaler Spielansicht erkennbar sind. Die Live-Ansichten bestätigten den kleinen Maßstab.
3. Körper: In jagd-nah.png und elektro-nah.png sind ein heller Membranrand, innere Textur und Auge erkennbar. Beim orangefarbenen Gegner ist die Geißel sichtbar; bei der Spielerzelle ist in den geprüften Bildern keine entsprechend deutliche Geißel zu erkennen. Wogende Membran und Aufblitzen bei Treffern werden durch die Standbilder nicht nachgewiesen.
4. Stachel: stachel-nah.png zeigt ein kleines gelbliches Kontaktteil zwischen den Zellen; in stachel-1.png/stachel-2.png ist es kaum als Stachel lesbar. Silhouette und Kontrast verstärken. Bei Kontakt muss Ursache/Wirkung aus dem Bild verständlich werden, ohne nur den Erklärungstext zu lesen.
5. Gift: gift-nah.png zeigt einen kleinen grünlichen Ansatz; gift-1.png/gift-2.png zeigen keine eindeutig beurteilbare Giftwolke. Das ist kein Beleg für eine fehlende Funktion. Bitte eine kurze Sequenz mit ausströmender Wolke und sichtbarem Trefferziel vorlegen.
6. Elektro: elektro-nah.png zeigt einen blauen Punkt am Zellkörper; elektro-1.png/elektro-2.png zeigen keinen eindeutigen Blitz. Auch in meinen einzelnen Live-Aufnahmen der Elektro-Szene wurde kein sicher beurteilbarer Entladungsmoment erfasst. Funktion und Animationsqualität daher nicht abgenommen. Eine kurze Vorführung muss Auslösung, Verbindung zum Ziel und Trefferreaktion erkennbar machen.
7. HUD: DNA, Größenstufe und Hinweise sind gut lesbar. Der rote Balken direkt unter „Größe“ hat keine sichtbare Bezeichnung und kann als Wachstumsanzeige missverstanden werden. Gesundheit und Wachstum eindeutig benennen und getrennt verständlich darstellen.
8. Nahrung: In der live gestarteten Pflanzenfresser-Partie waren grüne und rote Nahrung klar voneinander unterscheidbar. Der Spielstand blieb bei meiner eingeschränkten Eingabe auf Größe 1/5, DNA 0; Nahrungsaufnahme wurde nicht bestätigt.
9. Vergleich mit Spore: Keine belastbare Gleichwertigkeit oder abschließende Ähnlichkeit behauptet. Die geringe Erkennbarkeit der eigenen Zelle und Teile steht bereits dem vereinbarten Muss-Ziel entgegen. Nachbesserung zuerst im normalen Spielmaßstab prüfen, nicht nur an vergrößerten Ausschnitten.

Ergebnis: Sichtprüfung beantwortet, Optik noch nicht abschließend abgenommen. Animationen und Wirkungen bleiben anhand geeigneter Sequenzen bzw. eines funktionierenden Spieltests nachzuweisen. Alle von mir geöffneten Spielfenster wieder geschlossen.

## Erledigt
- 17.10.2026: Umgesetzt bzw. geplant: Kamera näher, Zellen im normalen Spielbild etwa 1,6-mal so groß (Claude), Stacheln größer mit dunklem Rand (T-0259), HUD beschriftet „Wachstum“ und „Gesundheit“ (T-0260). Geißel: Die Startzelle hat absichtlich keine Geißel, sie wird erst als Teil gefunden. Gift, Elektro und Treffer: neuer Ansehen-Punkt mit Filmstreifen (Bewegung) aus den Spieltests folgt nach dem Einbau.
