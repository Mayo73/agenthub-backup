---
projekt: drift
titel: Drift – isometrisches Driftspiel
status: warteschlange
prioritaet: 1
ablaufplan: ja
erstellt: 2026-10-15
---

# Drift – isometrisches Driftspiel

> Nachträglich aus den Absprachen mit Claude erstellt (15.10.2026), damit das laufende Projekt in der Warteschlange steht.

## Zielsetzung

Ein 2D-Driftspiel in isometrischer Ansicht für Windows: schnelle Runden fahren und mit Drifts Punkte sammeln. Ein weiter Drift bringt mehr Punkte, kostet aber Rundenzeit. Version 1.0 ist ein eigenständiges Windows-Spiel.

## Ausgangslage

Läuft bereits als `projects/drift` (Godot 4.7). Fahrphysik, Strecke, isometrische Ansicht, Drift-Wertung, Rundenzeit und HUD sind fertig; Reifenspuren, Rauch und Rennablauf sind umgesetzt und im Review.

## Funktionsumfang

### Muss

- Driftphysik mit Handbremse und Gegenlenken; Drift-Punkte mit Kombo; Rundenzeit mit Bestzeit
- Reifenspuren und Reifenrauch beim Driften
- Rennablauf: Countdown, 3 Runden, Ergebnis
- Geisterauto der besten Runde
- Menüs: Hauptmenü, Pausemenü, Ergebnisbildschirm
- 3 Strecken mit Auswahl, 3 Autos mit Auswahl
- KI-Gegner mit Platzierung im Ergebnis
- Bestenliste je Strecke, dauerhaft gespeichert
- Sound (Motor, Reifen, Menü, Musik)
- Einstellungen (Lautstärke, Vollbild, Tastenbelegung), dauerhaft gespeichert
- Grafik-Politur (schönere Autos, Strecken-Deko)
- Windows-Version als .exe

### Soll

- (alles Gewünschte ist Muss für Version 1.0)

### Kann

- (noch nichts)

## Abnahmekriterien

1. Die .exe startet auf diesem PC, ohne dass Godot geöffnet werden muss.
2. Vom Hauptmenü aus lassen sich Strecke und Auto wählen und ein Rennen über 3 Runden fahren; danach erscheint das Ergebnis mit Zeit, Punkten und Platz.
3. Bestzeit und Höchstpunktzahl je Strecke bleiben nach einem Neustart des Spiels erhalten.
4. KI-Gegner fahren alle 3 Strecken vollständig, ohne hängen zu bleiben.
5. Einstellungen bleiben nach einem Neustart erhalten.
6. Alle automatischen Prüfungen (`verify.cmd`) sind grün.
7. Der Nutzer hat Fahrgefühl, Optik und Sound abgenommen.

## Rahmenbedingungen

- Plattform: Windows-Desktop, Tastatur und Gamepad
- Technik: Godot 4.7 mit GDScript
- Inhalte: nur selbst erstellte oder frei lizenzierte Grafiken und Klänge
- Daten: alles lokal, keine Online-Dienste

## Nicht-Ziele

- Online-Mehrspieler
- Mobilgeräte und Konsolen

## Rückmeldungen

<!-- Antworten, Eindrücke und Änderungswünsche des Nutzers während der Umsetzung, neueste unten:
- JJJJ-MM-TT (neu): … -->
- 2026-10-16 (übernommen): Grafik, Musik und Klänge für Drift dürfen mit Higgsfield erzeugt werden (Credits aus dem Abo des Nutzers). Das gilt als Ausnahme zu „nur selbst erstellte oder frei lizenzierte Grafiken und Klänge“. „Keine Online-Dienste“ bezieht sich auf das Spiel selbst: Es bleibt offline, nur die Erzeugung während der Entwicklung läuft über Higgsfield. Gilt für „Grafik-Politur“ und „Sound“. (Freigabe des Nutzers im Chat mit Claude)
