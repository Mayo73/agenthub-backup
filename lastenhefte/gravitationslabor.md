---
projekt: gravitationslabor
titel: Gravitationslabor – Umlaufbahnen spielerisch erkunden
status: entwurf
prioritaet: 2
ablaufplan: ja
erstellt: 2026-10-17
---

# Gravitationslabor – Umlaufbahnen spielerisch erkunden

## Zielsetzung

Eine lokale Windows-Sandbox macht die Wechselwirkung von Himmelskörpern sichtbar. Der Nutzer setzt Körper ein, verändert Masse und Startgeschwindigkeit und beobachtet Bahnen, Begegnungen und Zusammenstöße. Dies ist ein unverbindlicher Folgeprojekt-Vorschlag von ChatGPT; der Nutzer hat das Projekt noch nicht freigegeben.

## Ausgangslage

Laut STATUS.md vom 17.10.2026 ist nach Zellenphase kein weiteres Projekt eingeplant. Die neue AGENTS.md verlangt vorbereitete Entwürfe. Dieser Vorschlag bietet nach zwei Spielen ein kleines interaktives Werkzeug mit direkt beobachtbaren Ergebnissen; er verändert keine bestehenden Projekte.

## Funktionsumfang

### Muss

- Zweidimensionale Ansicht mit verschiebbarer und zoombarer Kamera.
- Körper per Maus setzen; Masse, Position und Anfangsgeschwindigkeit vor dem Start bearbeiten.
- Gegenseitige Gravitation in konsistenten, im Programm erklärten Simulationseinheiten; keine unsichtbare Änderung von Parametern.
- Sichtbare Geschwindigkeitspfeile und begrenzt lange Bahnspuren, jeweils ein- und ausschaltbar.
- Start, Pause, einzelner Zeitschritt, Zeitraffer und Zurücksetzen auf den ursprünglichen Szenenstand.
- Drei mitgelieferte Szenen: Zweikörpersystem, Begegnung mehrerer Körper und Kollision.
- Ein verständliches Kollisionsmodell: berührende Körper verschmelzen; Masse und Impuls werden übernommen.
- Auswahl eines Körpers zeigt dessen Masse und Geschwindigkeit; Gesamtzahl und Gesamtmasse der Szene anzeigen.
- Szenen lokal speichern und laden; deutsche Bedienoberfläche und eigenständig startbares Windows-Paket.

### Soll

- Vor dem Start eine Bahnvorschau für die aktuelle Konfiguration.
- Drei kleine Aufgaben mit beobachtbaren Zielzuständen, etwa eine gebundene Bahn erzeugen.
- Anzeige des numerischen Fehlers für dafür geeignete kollisionsfreie Referenzszenen.

### Kann

- Bilder der aktuellen Ansicht exportieren.
- Zusätzliche Farbpaletten und auswählbare Spurendarstellung.

## Abnahmekriterien

1. Das Windows-Paket startet ohne Entwicklungsumgebung; alle drei Beispielszenen können geöffnet und gestartet werden.
2. Eine neue Szene mit zwei Körpern lässt sich vollständig über die Oberfläche erstellen; angezeigte Anfangswerte stimmen nach Speichern und Laden überein.
3. Im pausierten Zustand ändern sich Positionen über zehn Sekunden nicht; ein Einzelschritt verändert den Zustand genau um den angezeigten Simulationsschritt.
4. Zurücksetzen stellt für alle Körper Position, Geschwindigkeit und Masse des Startzustands wieder her.
5. Das kollisionsfreie Zweikörper-Beispiel zeigt über zehn Umläufe eine gebundene Bahn. Numerische Abweichungen werden mit einem dokumentierten Test gegen die Referenzwerte geprüft.
6. Bei der Kollision zweier Körper entspricht die neue Masse der Summe; der Gesamtimpuls vor und nach dem Zusammenführen stimmt innerhalb der dokumentierten numerischen Toleranz überein.
7. Wechsel von Normalgeschwindigkeit zu Zeitraffer verändert bei gleicher simulierter Zeit das Ergebnis nur innerhalb einer dokumentierten numerischen Toleranz.
8. Null, negative Masse und ungültige Texteingaben werden mit einer verständlichen Meldung abgefangen; es entstehen keine ungültigen Positionswerte.
9. Zoom, Kamera, Auswahl sowie Ein-/Ausblenden von Spuren und Pfeilen sind per Maus bedienbar und verbergen keine notwendigen Bedienelemente.
10. Eine 20-minütige Sitzung mit mindestens 50 Körpern bleibt auf diesem PC bedienbar und verläuft ohne Absturz.
11. Der Nutzer hat die frühe Zweikörper-Demo sowie Bedienung und Endfassung beurteilt.

## Rahmenbedingungen

- Plattform: Windows-Desktop, Maus und Tastatur; Vorschlag.
- Technik: Claude entscheidet. Numerische Methode und Simulationseinheiten dokumentieren.
- Daten und Datenschutz: vollständig lokal; kein Konto, keine Telemetrie, keine Online-Dienste.
- Medien: prozedural gezeichnete Körper, Pfeile und Spuren; zusätzliche frei lizenzierte Medien nur bei konkretem Bedarf. Keine Nutzung kostenpflichtiger Higgsfield-Credits beauftragt.
- Grenzen: keine neuen Kosten oder Abos. Numerische Toleranzen für die Referenztests vor deren Implementierung festlegen und begründen; Genauigkeitsgrenzen in der Bedienung erklären.
- Sonstiges: Ein spielerisches Erkundungswerkzeug; keine Vorhersage realer Missionen. Zuerst eine bedienbare Zweikörper-Demo, danach Szeneneditor und Kollisionen, zuletzt die Endabnahme.
- Ablaufplan: Grafischer Ablaufplan im Agent-Hub-Dashboard; am 17.10.2026 vom Nutzer für dieses Projekt bestätigt (`ablaufplan: ja`).
- Freigabe: ausschließlich Entwurf; weder Umsetzung noch Priorisierung gegenüber laufenden Projekten beauftragt.

## Nicht-Ziele

- Dreidimensionale Raumfahrt, realer Sternenkatalog oder Raketenbau.
- Relativistische Effekte, Missionsplanung oder wissenschaftlich zertifizierte Genauigkeit.
- Online-Mehrspieler oder Änderungen an Drift/Zellenphase.

## Rückmeldungen

- 2026-10-17 (neu): Von ChatGPT gemäß der aktualisierten AGENTS.md als Auswahlvorschlag für die nächste Warteschlange vorbereitet. Keine Nutzerfreigabe.
