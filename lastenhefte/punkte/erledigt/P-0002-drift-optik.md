---
id: P-0002
projekt: drift
art: ansehen
status: erledigt
erstellt: 2026-10-17
---
# Drift: Optik und Menüs beurteilen

## Worum es geht
Bitte anhand der Screenshots beurteilen:

1. **Grafik:** Passen Autos, Strecke, Deko (Reifenstapel, Büsche) und das Titelbild im Hauptmenü zusammen? Wirkt es wie ein stimmiges Spiel?
2. **Reifenspuren und Rauch:** Sind sie beim Driften gut sichtbar und passend? (Auf den Rennbildern driften die KI-Autos; der Spieler fährt dort nicht selbst.)
3. **Menüs:** Ist das Hauptmenü verständlich (Strecke und Auto wählen, Rennen starten, Einstellungen, Beenden)? Ist alles gut lesbar? Ist das Einstellungsmenü klar?

Konkrete Mängel bitte mit Bildname und Stelle nennen (z. B. „rennen-2.png: Text oben links schlecht lesbar“).

## Material
- `P-0002/menue-1.png`: Hauptmenü mit Titelbild
- `P-0002/rennen-1.png` bis `rennen-4.png`: Rennszene im Verlauf (Countdown, Start, KI-Autos in der Kurve)
- `P-0002/einstellungen-1.png`: Einstellungsmenü
- Nur falls die Bilder nicht reichen: `C:\Users\wiens\AgentHub\hub\spielen.cmd drift`

## Antwort

17.10.2026 – Sichtprüfung aller sechs beigelegten Bilder; zusätzlich Hauptmenü und Hafenring-Rennansicht live geöffnet.

1. Grafik: Titelbild, rote Fahrzeugdarstellung und Streckenthema passen grundsätzlich zusammen. Die Rennansicht bleibt jedoch deutlich flächiger als das gemalte Titelbild: rennen-1.png bis rennen-4.png zeigen weitgehend einfarbigen Asphalt/Rasen und regelmäßig wiederholte Deko. Für die vereinbarte Grafik-Politur vorhandene Materialien mit dezenten Texturen/Schatten und variierter Deko angleichen; kein zusätzlicher Funktionsumfang nötig.
2. Wichtiger Erkennbarkeitsmangel: In rennen-1.png bis rennen-3.png sind Spielerauto und ein Gegner beide rot und gleich dargestellt. Besonders bei der Überlagerung in rennen-2.png ist die Zuordnung ohne die Kamerazentrierung schwierig. Spieler dauerhaft durch eine eindeutige Markierung/Kontur oder eine exklusiv reservierte Farbe kennzeichnen. Nachprüfung: Bei dicht nebeneinander fahrenden roten Autos muss das eigene Fahrzeug auf einen Blick erkennbar sein.
3. Reifenspuren und Rauch: In rennen-1.png bis rennen-4.png ist kein klar beurteilbarer Drift mit sichtbaren Spuren/Rauch dokumentiert. Das beweist nicht, dass die Effekte fehlen. Der Rauch im Titelbild ist kein Funktionsnachweis. Bitte einen Ausschnitt mit tatsächlich aktivem Drift und anschließend verbleibender Spur liefern; Bewegungstest bleibt bei P-0003 offen.
4. Hauptmenü (menue-1.png): Auswahlpfeile, Strecke, Auto, Start, Einstellungen und Beenden sind übersichtlich und gut lesbar. Die Anzeige von Bestzeit/Rekord ist verständlich. Funktion der einzelnen Auswahlen wurde in dieser Bildprüfung nicht vollständig geprüft.
5. Einstellungen (einstellungen-1.png): Tastenbelegung und Zurück-Schaltfläche sind lesbar. Bei „Vollbild“ fehlt ein erkennbarer Ein/Aus-Zustand bzw. Checkbox-Indikator. Sichtbaren Zustand ergänzen. Ein einzelner Lautstärkeregler ist für das vorliegende Drift-Lastenheft ausreichend.
6. Renn-HUD: Geschwindigkeit, Punkte, Runde, Zeit und Platz sind kontrastreich lesbar. Die Hilfszeile am unteren Rand ist kleiner, aber auf den Originalbildern erkennbar.

Ergebnis: Bildprüfung beantwortet, mit konkretem Nachbesserungsbedarf. Keine pauschale Endabnahme von Grafik oder dynamischen Effekten.

## Erledigt
- 17.10.2026: Umgesetzt: Spielerauto mit leuchtendem Ring markiert (T-0255, gemergt), Vollbild zeigt „An/Aus“ (T-0256), abwechslungsreichere Deko (T-0257), Asphalt- und Rasentextur (A-0014, A-0015 erzeugt; Einbau T-0258). Menüs und HUD als gut lesbar abgehakt. Spuren und Rauch: neuer Ansehen-Punkt mit Filmstreifen aus dem Spieltest folgt nach dem Einbau.
