---
projekt: zellenphase
titel: Zellenphase – Evolutionsspiel nach dem Vorbild von Spore
status: wartet-auf-dich
prioritaet: 2
ablaufplan: ja
erstellt: 2026-10-16
---

# Zellenphase – Evolutionsspiel nach dem Vorbild von Spore

## Zielsetzung

Ein eigenständiges Windows-Spiel soll die Zellenphase von Spore in Spielablauf, Steuerung, Zelleditor und visueller Wirkung möglichst eng nachbilden. Der Nutzer möchte ausdrücklich testen, wie nah der Agent Hub an das Vorbild herankommt. Ziel ist eine vollständig spielbare Zellenphase mit eigenen Medien; der Ähnlichkeitsvergleich ist Teil der Abnahme.

## Ausgangslage

- Neues Projekt als nächstes Vorhaben neben dem bereits laufenden Drift-Projekt; dessen Status und Priorität bleiben unverändert.
- Bestätigt am 16.10.2026: Windows-Spiel, möglichst enge Orientierung an Spore und grafischer Ablaufplan im Agent-Hub-Dashboard.
- Der Nutzer erlaubt, das volle Potenzial von Higgsfield für dieses Projekt zu nutzen.
- Referenz für den Kernablauf: [Original-Spore-Handbuch, Abschnitte „Cell Stage“ und „Cell Creator“](https://shared.steamstatic.com/store_item_assets/steam/apps/17390/manuals/manual.pdf?t=1642702281). Es beschreibt Nahrung und DNA, Wachstum, Teilefunde, Partnersuche, Editor und den Einfluss von Mundwerkzeugen.
- Die folgenden Mindestumfänge und Testwerte sind Projektvorgaben, keine Behauptung über exakte Originalwerte. Claude prüft Detailregeln anhand zugänglicher Referenzen und dokumentiert verbleibende Abweichungen.

## Funktionsumfang

### Muss

- **Vollständiger Durchlauf:** Neue Partie mit Pflanzen- oder Fleischfresser beginnen, Nahrung sammeln, wachsen, Teile freischalten, die Zelle mehrfach umbauen und das Ende der Zellenphase erreichen. Ein Abschlussbildschirm beendet den Durchlauf.
- **Steuerung und Kamera:** Mausgeführtes Schwimmen mit gedrückter Maustaste, ergänzend WASD/Pfeiltasten; nachvollziehbare Beschleunigung, Trägheit und Wendegeschwindigkeit. Die Kamera folgt der Zelle; Zoom und Größenwechsel vermitteln den Wechsel des Maßstabs.
- **Wasserwelt und Darstellung:** Draufsicht mit räumlich wirkenden Zellen, animierten Körperteilen, Wasserpartikeln und mehreren Tiefenebenen. Nahrung, Gefahren und eigene Zelle müssen im Spielgeschehen unterscheidbar bleiben. In der fertigen Version alle sichtbaren Platzhalter ersetzen.
- **Nahrung und Entwicklung:** Pflanzenmaterial und Fleisch unterscheiden; Mundwerkzeuge bestimmen die verwertbare Nahrung. DNA als ausgebbare Ressource und Wachstum als eigener Fortschritt anzeigen. Nahrung wird über passende Mundkontakte aufgenommen.
- **Ökosystem:** Andere Zellen suchen Nahrung, verfolgen geeignete Beute und fliehen vor Gefahren. Mindestens acht erkennbar verschiedene Gegner-/Beutetypen und fünf aufeinanderfolgende Größenabschnitte vorsehen. Durch Wachstum können frühere Bedrohungen zu erreichbarer Beute werden.
- **Kampf und Überleben:** Gesundheit, Trefferreaktionen, Tod und verständlicher Wiedereinstieg. Lage und Ausrichtung von Mundwerkzeugen und Schutzteilen beeinflussen Begegnungen; reine Nähe zu einem Gegner reicht nicht für jeden Treffer.
- **Teile und Freischaltungen:** Teile über Funde und besiegte Zellen freischalten. Als Mindestumfang funktional unterschiedliche Mundwerkzeuge für Pflanzen, Fleisch und gemischte Ernährung, Fortbewegungsteile für Tempo und Wendigkeit sowie Stacheln, Gift und elektrische Abwehr. Augen und Körpergestaltung vervollständigen das Erscheinungsbild. Claude legt Kosten, Effekte und Freischaltreihenfolge mit Referenzbezug fest; Abweichungen werden benannt.
- **Partnersuche und Zelleditor:** Ein Ruf und das Erreichen eines Partners führen in den Editor. Körperform, Farbe und Muster bearbeiten; freigeschaltete Teile platzieren, verschieben, drehen und entfernen, mit nachvollziehbarer Symmetriebedienung. DNA-Kosten und Fähigkeitsänderungen vor dem Bestätigen anzeigen. Umbauten verändern anschließend Darstellung, Fortbewegung, Ernährung oder Abwehr tatsächlich.
- **Bedienung und Speicherung:** Deutsches Hauptmenü, neue Partie, fortsetzen, Pause, Einstellungen und Beenden. Lokaler Spielstand einschließlich Zellaufbau, Freischaltungen, DNA, Gesundheit und Entwicklungsstand. Automatisch nach abgeschlossenem Editorbesuch und Größenwechsel speichern.
- **Audio und Einstellungen:** Wasseratmosphäre, Fressen, Treffer, Wachstum und Editoraktionen vertonen; Hintergrundmusik sowie getrennte Lautstärke für Musik und Effekte. Vollbild/Fenster und Auflösung einstellen; Einstellungen dauerhaft speichern.
- **Nähe zum Vorbild prüfen:** Eine Vergleichsliste für Steuerung, Kamera/Größe, Nahrung/Kampf, Editor, Optik und Ablauf führen. Zu jedem Punkt Referenz, umgesetztes Verhalten, bekannten Unterschied und zugehörigen Nutzertest festhalten. Abweichungen, die den Kern verändern, dem Nutzer vorlegen.
- **Dashboard und Lieferung:** Grafischen Ablaufplan mit Abhängigkeiten, Meilensteinen und Nutzerprüfungen im Dashboard unter „Ablaufplan“ führen. Ein startbares Windows-Paket mit EXE und kurzer Bedienungsanleitung bereitstellen.

### Soll

- Rückgängig/Wiederholen im Editor und mehrere lokale Spielstände.
- Kurze, kontextbezogene Einführung in Bewegung, Fressen, Teilefunde und Editor.
- Erkennbarer Entwicklungsrückblick am Ende eines Durchlaufs.

### Kann

- Zusätzliche Zelltypen, Farbvarianten und auswählbare Schwierigkeitsgrade.
- Kurze mit Higgsfield erstellte Einleitung, sofern sie den Spieleinstieg unterstützt.

## Abnahmekriterien

1. Das ausgelieferte Windows-Paket startet auf diesem PC ohne geöffnete Entwicklungsumgebung; neue Partie, Pause, Fortsetzen und Beenden funktionieren.
2. Je eine Partie mit Start als Pflanzen- und Fleischfresser kann vom Beginn bis zum Abschluss ohne blockierenden Fehler durchgespielt werden.
3. Ein Test mit jeder Ernährungsart belegt, welche Nahrung aufgenommen werden kann. Ungeeignete Nahrung erhöht weder DNA noch Wachstum.
4. Mindestens fünf Größenabschnitte sind erreichbar. Zellgröße, Kamera und verfügbare Begegnungen verändern sich sichtbar; mindestens eine zuvor bedrohliche Zellart wird später zu möglicher Beute.
5. Für alle acht Zelltypen sind Darstellung und Verhalten dokumentiert. Verfolgung, Flucht und Nahrungssuche werden in reproduzierbaren Spielsituationen vorgeführt.
6. Jede vorgesehene Teilefunktion wird in einer Testszene geprüft: Nahrungsaufnahme, Tempo, Wendigkeit, Stachelkontakt, Giftwirkung und elektrische Abwehr. Unterschiede müssen messbar oder direkt beobachtbar sein.
7. Teile lassen sich freischalten und anschließend im Editor verwenden. Nicht freigeschaltete oder unbezahlbare Teile können nicht verbindlich eingebaut werden; DNA wird nie negativ.
8. Ruf, Partnersuche, Editor und Rückkehr ins Spiel funktionieren mindestens dreimal in einer Partie. Umbauten bleiben erhalten und beeinflussen die nachfolgende Spielsituation.
9. Ein Test umfasst Platzieren, Verschieben, Drehen und Entfernen eines Teils sowie eine Änderung von Körperform und Farbe. Vorschau, Kosten und fertige Zelle stimmen überein.
10. Nach Speichern, vollständigem Beenden und Neustart stimmen Zellaufbau, Freischaltungen, DNA, Gesundheit und Entwicklungsstand mit dem gespeicherten Zustand überein. Auch Audio- und Anzeigeeinstellungen bleiben erhalten.
11. Tod, Wiedereinstieg und der abschließende Phasenwechsel führen zu bedienbaren Zuständen; ein 30-minütiger Spieltest verläuft ohne Absturz oder festhängende Menüs.
12. Auf diesem PC bei 1920 × 1080 werden in einer dokumentierten 60-Sekunden-Szene mit mindestens 30 aktiven KI-Zellen durchschnittlich mindestens 60 FPS erreicht. Laden und Menüs sind von dieser Messung ausgenommen.
13. Im Dashboard ist ein grafischer Ablaufplan für dieses Projekt sichtbar, einschließlich Meilensteinen für Kernspiel, Editor, vollständigen Durchlauf und Abnahme.
14. Alle projektspezifischen automatischen Prüfungen sind erfolgreich. Für Steuerung, Optik und Spielgefühl liegt die ausgefüllte Vergleichsliste vor; der Nutzer hat diese drei Bereiche ausdrücklich beurteilt und die Endfassung abgenommen. Die reine Anzahl vorhandener Funktionen genügt nicht als Ähnlichkeitsnachweis.

## Rahmenbedingungen

- Plattform: Windows-Desktop auf diesem PC, Maus und Tastatur; eigenständig startbare EXE.
- Technik: Claude entscheidet. Engine und Darstellungsverfahren so wählen, dass verformbare Zellen, frei platzierbare Teile und räumliche Wirkung unterstützt werden.
- Daten und Datenschutz: Vollständig lokal spielbares Spiel ohne Konto, Telemetrie oder Onlinezwang. Spielstände lokal speichern.
- Medien: Volles Potenzial von Higgsfield nutzen, soweit es dem Projekt hilft: Bilder, Texturen, Hintergründe, Videos, 3D-Modelle und gegebenenfalls Sprachausgabe. Die Nutzung von Credits aus dem bestehenden Abo ist erlaubt. Musik und Soundeffekte werden separat selbst erstellt oder aus passend frei lizenzierten Quellen bezogen. Eingesetzte Werkzeuge und Medienherkunft dokumentieren.
- Grenzen: Eigene Spielmedien und geeignete Lizenzen verwenden. Higgsfield im Rahmen des vorhandenen Abos; zusätzliche Creditkäufe, weitere kostenpflichtige Dienste oder Assetkäufe sind bisher nicht beauftragt.
- Sonstiges: Zunächst eine frühe spielbare Fassung für Schwimmen, Fressen, Kampf und Wachstum vorlegen; danach Editor und vollständigen Durchlauf, zuletzt Grafik-/Audioabnahme. Diese Prüfungen als Meilensteine im Dashboard abbilden. Der frühe Prototyp ersetzt den vereinbarten Endumfang nicht.
- Warteschlange: Standardpriorität 2. Am 16.10.2026 ausdrücklich vom Nutzer freigegeben und auf `bereit` gesetzt; bestehende Projekte werden nicht pausiert oder umpriorisiert.

## Nicht-Ziele

- Kreaturen-, Stammes-, Zivilisations- oder Weltraumphase.
- Online-Mehrspieler, öffentliche Kreaturenbibliothek oder Spore-Kontoanbindung.
- Browser-, Mobil- oder Konsolenversion.
- Zusätzliche Mechaniken, die den gewünschten Vergleich mit der Spore-Zellenphase verwässern.
- Öffentliche Veröffentlichung oder Verkauf als Bestandteil dieses Auftrags.

## Rückmeldungen

- 2026-10-16 (übernommen): Der Nutzer möchte ein Windows-Spiel, das sich möglichst eng an der Zellenphase von Spore orientiert, um zu testen, wie nah der Agent Hub an das Vorbild herankommt.
- 2026-10-16 (übernommen): Ein grafischer Ablaufplan soll im Dashboard erstellt werden.
- 2026-10-16 (übernommen): Auf die Frage nach Higgsfield hat der Nutzer ausdrücklich geantwortet: „Volles Potenzial von Higgsfield nutzen“.
- 2026-10-16 (übernommen): Der Nutzer hat den vorliegenden Gesamtumfang ausdrücklich mit „Freigeben“ zur Umsetzung freigegeben. Status auf `bereit` gesetzt.
- 2026-10-17 (übernommen): Änderungswunsch des Nutzers: Deutlich kleinere KI-Zellen sollen mit einem einzigen Bissen vollständig verspeist werden können. Bei einem erfolgreichen Biss mit einem zum Fressen von Zellen geeigneten Mundwerkzeug soll eine solche Beute auch bei voller Gesundheit sofort gefressen werden und die übliche Nahrung-/DNA-/Wachstumswirkung auslösen. Claude soll ein eindeutiges relatives Größenverhältnis für „deutlich kleiner“ festlegen und dokumentieren. Bitte mit einer deutlich kleineren sowie einer ähnlich großen KI-Zelle vorführen, dass die Ein-Biss-Regel gezielt für die kleinere Beute greift.
- 2026-10-17 (übernommen): Erweiterungswunsch des Nutzers: Nach der Zellenphase soll eine spielbare Fischphase folgen, in der sich die eigene Lebensform als Fisch weiterentwickelt. Die Fischphase soll einen echten dreidimensionalen Unterwasserraum mit freiem Schwimmen in allen drei Raumachsen bieten, einschließlich Auf- und Abtauchen und Wechsel der Schwimmtiefe. Es soll einen nachvollziehbaren Übergang von der Zellenphase in diese nächste Entwicklungsstufe geben. Die weitere Entwicklung als Fisch soll im Spiel sichtbar und spielerisch wirksam sein. Dieser Wunsch erweitert den bisherigen Umfang über den Abschluss der Zellenphase hinaus. Claude soll Übergang, 3D-Steuerung/Kamera und Fischentwicklung konkret planen und als zusätzliche Meilensteine mit prüfbaren Ergebnissen in den bestehenden grafischen Ablaufplan im Dashboard aufnehmen.
