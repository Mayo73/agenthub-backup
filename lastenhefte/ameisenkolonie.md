---
projekt: ameisenkolonie
titel: Ameisenkolonie – eine kleine Kolonie aufbauen und beobachten
status: entwurf
prioritaet: 2
ablaufplan: ja
erstellt: 2026-10-17
---

# Ameisenkolonie – eine kleine Kolonie aufbauen und beobachten

## Zielsetzung

Ein lokales Windows-Spiel verbindet Kolonieaufbau mit beobachtbarem Verhalten einzelner Ameisen. Der Spieler erschließt Nahrung, erweitert das Nest und verteilt Arbeit, bis eine kleine Kolonie selbstständig versorgt wird. Dies ist ein unverbindlicher Folgeprojekt-Vorschlag von ChatGPT; der Nutzer hat das Projekt noch nicht freigegeben.

## Ausgangslage

Laut STATUS.md vom 17.10.2026 ist nach Zellenphase kein weiteres Projekt eingeplant. Die neue AGENTS.md verlangt deshalb zwei bis drei vorbereitete Entwürfe. Dieses eigenständige Spiel greift das Interesse an beobachtbaren Lebewesen und Simulation auf, ohne Drift oder Zellenphase zu erweitern.

## Funktionsumfang

### Muss

- Überschaubare 2D-Karte mit Nest, Nahrungsvorräten und Hindernissen; Kamera verschieben und zoomen.
- Einzelne Ameisen mit erkennbaren Zuständen: suchen, Nahrung aufnehmen, zum Nest zurückkehren, abliefern und bauen.
- Sichtbare Duftspuren zur Orientierung; ihre Anzeige ein- und ausschaltbar.
- Nest um Lager- und Brutkammern erweitern; Nahrung als einzige ausgebbare Ressource der ersten Version.
- Anzahl der Sammler und Bauarbeiter über einfache Bedienelemente zuweisen; verfügbare und zugewiesene Tiere anzeigen.
- Eine Einführungsaufgabe und drei klar benannte Ziele für einen vollständigen Durchlauf, mit Abschlussanzeige.
- Pause und wählbare Simulationsgeschwindigkeit; deutsche Menüs und kurze Bedienungshinweise.
- Lokales Speichern und Fortsetzen; eigenständig startbares Windows-Paket.

### Soll

- Zwei weitere Karten mit anderem Wegverlauf und anderer Verteilung der Nahrung.
- Anklickbare Ameisen zeigen Aufgabe, Ziel und getragene Nahrung.
- Zeitleiste für Nahrungsvorrat und Koloniegröße.

### Kann

- Fotomodus ohne Bedienoberfläche.
- Zusätzliche Nestdekoration ohne spielerische Vorteile.

## Abnahmekriterien

1. Das Windows-Paket startet ohne Entwicklungsumgebung; neue Partie, Pause, Fortsetzen und Beenden funktionieren.
2. In einer Referenzkarte findet eine Ameise Nahrung, trägt sie vollständig zum Nest und erhöht den Vorrat genau um die abgelieferte Menge.
3. Zugewiesene Tiere überschreiten nie die verfügbare Gesamtzahl. Nach einer geänderten Zuweisung nehmen freie Tiere die neue Aufgabe auf.
4. Eine platzierte Kammer zieht die angezeigten Kosten einmal ab und wird von Bauarbeitern fertiggestellt; bei fehlender Nahrung ist der Bau nicht möglich.
5. Ameisen erreichen beide Seiten eines Hindernisses über den vorhandenen Durchgang, ohne in einer zehnminütigen Testszene dauerhaft steckenzubleiben.
6. Duftspuren sind sichtbar ein- und ausblendbar; sie haben in einem kontrollierten Vergleich einen erkennbaren Einfluss auf die Wegwahl.
7. Die drei angezeigten Ziele lassen sich in einer Partie erfüllen; danach erscheint eine Abschlussanzeige.
8. Nach Neustart entsprechen Koloniegröße, Aufgabenverteilung, Vorrat und Nest dem gespeicherten Stand.
9. Eine 20-minütige Sitzung mit mindestens 100 Ameisen verläuft auf diesem PC ohne Absturz oder unbedienbare Menüs.
10. Der Nutzer hat eine frühe spielbare Fassung und anschließend Bedienung und Endfassung beurteilt.

## Rahmenbedingungen

- Plattform: Windows-Desktop, Maus und Tastatur; Vorschlag.
- Technik: Claude entscheidet; Schwerpunkt auf lesbarem Verhalten und funktionierender Wegfindung.
- Daten und Datenschutz: vollständig lokal, keine Konten oder Online-Dienste im Spiel.
- Medien: selbst erstellt oder frei lizenziert. Für dieses neue Projekt ist noch keine Nutzung kostenpflichtiger Higgsfield-Credits beauftragt.
- Grenzen: keine neuen Kosten oder Abos; nur geeignete freie Werkzeuge und Medien.
- Sonstiges: Grafik und Verhalten sind stilisiert; keine wissenschaftliche Simulation. Zunächst Nahrungssuche und Rücktransport zeigen, danach Nestbau und den vollständigen Durchlauf.
- Ablaufplan: Grafischer Ablaufplan im Agent-Hub-Dashboard; am 17.10.2026 vom Nutzer für dieses Projekt bestätigt (`ablaufplan: ja`).
- Freigabe: ausschließlich Entwurf; weder Umsetzung noch Priorisierung gegenüber laufenden Projekten beauftragt.

## Nicht-Ziele

- Online-Mehrspieler, komplexe Genetik, Jahreszeiten oder mehrere Ameisenarten.
- Kampf gegen andere Kolonien oder ein großes Strategiespiel.
- Änderungen an Drift oder Zellenphase.

## Rückmeldungen

- 2026-10-17 (neu): Von ChatGPT gemäß der aktualisierten AGENTS.md als Auswahlvorschlag für die nächste Warteschlange vorbereitet. Keine Nutzerfreigabe.
