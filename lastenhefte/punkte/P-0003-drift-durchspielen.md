---
id: P-0003
projekt: drift
art: ausprobieren
status: weitergegeben
erstellt: 2026-10-17
---
# Drift: Probe spielen

## Worum es geht
Hier kommt es auf Steuerung und Fahrgefühl an, deshalb bitte selbst spielen (Computer Use). Start: `C:\Users\wiens\AgentHub\hub\spielen.cmd drift`. Steuerung: W/↑ Gas, S/↓ Bremse, A/D lenken, Leertaste Handbremse, R zurück auf die Strecke, Esc Pause.

1. **Fahrgefühl:** Wie fühlt sich das Driften an (zu rutschig, zu träge, Handbremse zu stark)?
2. **Ganzes Rennen:** Ein Rennen über 3 Runden bis zum Ergebnis fahren. Läuft alles durch (Countdown, Rundenzähler, Ergebnis, „Nochmal“, „Zum Menü“)?
3. **Geisterauto:** Im zweiten Rennen auf derselben Strecke: Ist das Geisterauto der besten Runde gut erkennbar und hilfreich?
4. **Strecken:** Alle 3 Strecken kurz anfahren. Haben sie einen eigenen Charakter?
5. **Autos:** Alle 3 Autos kurz fahren. Fühlen sie sich verschieden an?
6. **KI-Gegner:** Sind sie zu leicht oder zu schwer?

Bitte je Punkt kurz das Ergebnis, dazu konkrete Fehler mit Schritten zum Nachstellen. Spiel danach schließen.

## Material
- Start: `C:\Users\wiens\AgentHub\hub\spielen.cmd drift`

## Antwort

17.10.2026 – Teilprüfung durchgeführt; vollständiger Fahrtest mit dem verfügbaren Eingabewerkzeug nicht belastbar möglich.

Vorgehen: Start über hub\spielen.cmd drift. Der erste Shell-Aufruf ließ kein dauerhaftes Spielfenster zurück; mit bis zum Spielende offen gehaltenem Startprozess erschien „Drift (DEBUG)“. Das ist kein nachgewiesener Spielabsturz. Hauptmenü per Maus bedient und Hafenring mit Allrounder gestartet. Countdown „3“, Rennansicht, fortlaufende Zeit, Runde 1/3 und KI-Fahrzeuge beobachtet. Die Anzeige erreichte 95 km/h und später 0 km/h am Streckenrand; daraus wird kein Urteil über die Fahrphysik abgeleitet.

Testgrenze: Computer Use bietet hier einzelne Tastendrücke, aber keinen dokumentierten gehaltenen Tastenzustand. W, D, R und Escape wurden gesendet; R bewirkte keine sichtbare Rücksetzung, Escape öffnete kein Pausemenü. Auch nach Klick ins Spielfeld und bestätigtem Fensterfokus blieb der erneute Escape-Test ohne sichtbare Reaktion. Mausklicks auf Menü und Fensterschließen funktionierten. Ob kurze synthetische Tastendrücke, Eingabeverarbeitung oder ein Spielfehler die Ursache sind, ist nicht geklärt. Dieses Ergebnis darf nicht als Nachweis gewertet werden, dass physische Tastatureingaben ebenfalls ausfallen.

Zu den einzelnen Aufträgen:
1. Fahrgefühl/Handbremse: nicht belastbar beurteilbar; kein Urteil „zu rutschig“ oder „zu träge“.
2. Ganzes Rennen: nur Start und Teil von Runde 1 geprüft, bis etwa 0:50 Rennzeit; kein Drei-Runden-Abschluss, kein Ergebnis, kein „Nochmal“/„Zum Menü“ geprüft.
3. Geisterauto: mangels abgeschlossener Runde nicht geprüft.
4. Strecken: nur Hafenring gesehen; die zwei anderen nicht gefahren.
5. Autos: nur Allrounder ausgewählt; Unterschiede nicht geprüft.
6. KI: fahrende Gegner beobachtet, Schwierigkeit nicht beurteilbar.

Bitte als nächsten Schritt einen kurzen Test mit physischer Tastatur durchführen: Start → Hafenring/Allrounder → Gas/Lenken → R → Escape. Funktioniert das, bleibt für mich die Werkzeuggrenze; funktioniert es nicht, hat die Eingabereparatur Vorrang. Danach vollständiges Rennen, Geist sowie Strecken-/Autovergleich nachholen. Keine Fahr- oder Rennabnahme erteilt.

Spiel über die Fenster-Schließen-Schaltfläche beendet; anschließend bestätigt, dass kein Drift-Fenster mehr geöffnet ist.
