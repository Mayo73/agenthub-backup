---
projekt: hub-engine
titel: Hub Engine – modulare Windows-Spielengine für Mensch und KI-Agenten
status: warteschlange
prioritaet: 2
ablaufplan: ja
erstellt: 2026-10-18
---

# Hub Engine – modulare Windows-Spielengine für Mensch und KI-Agenten

## Zielsetzung

Eine eigene, modular aufgebaute Entwicklungsumgebung für den Agent Hub, mit der der Nutzer und KI-Agenten 2D- und 3D-Spiele für Windows erstellen, bearbeiten, testen und exportieren können. Eine verständliche grafische Oberfläche ermöglicht den Einstieg ohne Engine-Vorkenntnisse. Codex/ChatGPT, Claude und die lokalen Agenten erhalten dokumentierte Schnittstellen für sämtliche veröffentlichten Projektfunktionen. KI unterstützt die konkrete Arbeit an Szenen, Verhalten, Assets, Physik und Fehlern; Spielphysik einschließlich Ballistik gehört zum Grundumfang.

Der Nutzer hat dieses Lastenheft am 18.10.2026 ausdrücklich zur Umsetzung freigegeben. Bestätigt sind der Aufbau auf einer offenen Engine und der grafische Ablaufplan. Als Grundlage ist Godot vorgesehen; eigene Module, Editor-Workflows und Agentensteuerung werden darauf aufgebaut.

## Ausgangslage

- Der Agent Hub plant und bearbeitet bereits Windows-Spiele und einen Android-Prototyp. Die neue Engine soll als eigenes Projekt entstehen und anschließend über einen Adapter mit dem Hub zusammenarbeiten.
- Bisherige Spielprüfungen haben gezeigt, wie wichtig steuerbare Testeingaben mit gehaltener Taste, strukturierte Zustandsabfragen und sichtbare Testergebnisse sind.
- Bestehende Projekte werden durch diesen Auftrag nicht automatisch migriert oder umgebaut.
- Der Nutzer lässt den Ort der Oberfläche offen: native Windows-Oberfläche oder Browser, je nach technischer Eignung.

### Festgelegte Richtung und Freigabestand

1. Nutzerentscheidung: auf einer offenen Engine aufbauen. Geplante Basis ist Godot; dessen Renderer und Physik werden als übernommene Komponenten offengelegt.
2. Nutzerentscheidung: grafischen Ablaufplan im Agent-Hub-Dashboard erstellen. Der Hub soll die unten aufgeführten Phasen mit Abhängigkeiten, Tickets und Abnahmepunkten abbilden.
3. Der vollständige Projektentwurf wurde vorgestellt und am 18.10.2026 durch den Nutzer mit „Ja freigeben“ zur Umsetzung freigegeben. Der Agent Hub darf ihn übernehmen und im beschriebenen Umfang planen und umsetzen.

## Funktionsumfang

### Muss

1. **Windows und zwei gleichwertige Spielarten**
   - Native Windows-Laufzeit und eigenständig startbare Windows-Exporte für 2D- und 3D-Spiele.
   - Projekte anlegen, öffnen, speichern, schließen, duplizieren und aus einer Vorlage starten.
   - Ein kleines spielbares 2D-Beispiel und ein kleines spielbares 3D-Beispiel als Referenzprojekte; nicht nur ein leerer Editor oder eine technische Einzelszene.

2. **Modulare Architektur**
   - Dokumentierte Modulgrenzen für Projekt-/Szenenmodell, Darstellung, Physik, Assets, Eingabe, Audio, Benutzeroberfläche, Spielverhalten, KI-Provider und Agent-Hub-Anbindung.
   - Module melden Version, Fähigkeiten, Abhängigkeiten, Datenformate, Befehle und benötigte Berechtigungen über einen gemeinsamen Vertrag.
   - Optionale Module aktivieren/deaktivieren; notwendige Abhängigkeiten schützen und verständlich anzeigen. Keine Zusage, den kompletten Renderer oder die Physik während eines laufenden Spiels beliebig auszutauschen.
   - Ein kleines unabhängiges Beispielmodul samt Anleitung demonstriert Erweiterung ohne Änderung des Engine-Kerns.

3. **Einfach bedienbarer grafischer Editor**
   - Deutsche Beschriftungen, Projektübersicht, Vorlagen, Szenenbaum, Asset-Bibliothek, Eigenschaftenanzeige, 2D-/3D-Ansicht und klar erreichbare Aktionen für Start, Pause, Stopp, Speichern und Export.
   - Objekte platzieren, auswählen, verschieben, drehen, skalieren, duplizieren und löschen. Numerische Eingaben und grafische Werkzeuge bearbeiten dieselben Werte.
   - Kameras, einfache Beleuchtung und Materialien in 3D; Sprites, Ebenen und Kamera in 2D.
   - Sichtbare Auswahl, verständliche Fehlermeldungen, Suchfunktion, kontextbezogene Hilfe und Rückgängig/Wiederholen.
   - Ein Einstiegspfad führt ohne Quellcodeänderung vom Vorlagenprojekt über eine Szenenänderung bis zum spielbaren Windows-Export.
   - Vorschlag für die erste Version: native Editoransicht mit nativer Spielvorschau, Dashboard-Anbindung für Projektstand und Aufträge. Ein Browsereditor ist zulässig, wenn die Bearbeitung und korrekte Windows-Vorschau damit nachweislich funktionieren. Der Nutzer muss keine Oberflächentechnik vorgeben.

4. **Grundbausteine für Spiele**
   - Szenen, Objekte/Komponenten, wiederverwendbare Objektvorlagen, Referenzen, stabile Objektkennungen und dokumentierte Projekteigenschaften.
   - Eingabeaktionen mit Tastatur/Maus, einfache UI-Elemente, Audioquellen und einfache Animationen.
   - Import mindestens eines verbreiteten Bildformats, eines Audioformats und eines offenen 3D-Austauschformats; unterstützte Formate und Importfehler dokumentieren.
   - Erweiterbares Spielverhalten durch Scripts beziehungsweise klar definierte Verhaltenskomponenten. Fehlgeschlagene Scriptänderungen verständlich melden und letzten gültigen Stand wiederherstellen.

5. **2D- und 3D-Physik**
   - Statische, dynamische und steuerbare Körper, passende Kollisionsformen, Schwerkraft, Masse, Kräfte/Impulse, Reibung, Rückprall und Kollisionsgruppen.
   - Triggerbereiche, Treffer-/Kontaktinformationen und einstellbare Physikparameter über Oberfläche und Agentenschnittstelle.
   - Festes dokumentiertes Physik-Zeitintervall, Pause und einzelne Simulationsschritte für Tests.
   - Keine pauschale Zusage bitgenau identischer Physik auf unterschiedlicher Hardware oder mit verschiedenen Physikversionen.

6. **Ballistik für Spiele**
   - Wiederverwendbare Projektilkomponente für 2D und 3D mit Startposition, Richtung/Anfangsgeschwindigkeit, Schwerkraft und Lebensdauer.
   - Sichtbare Flugbahn-Vorschau und auslesbare Trefferereignisse mit getroffenem Objekt, Position und Richtung/Normale, soweit vom Verfahren verfügbar.
   - Konfigurierbare Trefferreaktionen, mindestens Stoppen/Entfernen sowie Rückprall mit einstellbarem Energieverlust.
   - Schnelle Projektile dürfen die für die Testszene festgelegten dünnen Hindernisse nicht unbemerkt durchqueren. Kontinuierliche Kollisionsprüfung oder geeignete Strecken-/Formabfragen verwenden und mit konkreten Geschwindigkeits- und Wandstärkenbereichen testen.
   - Abstrakte, einheitlich dokumentierte Spielwerte; vereinfachte Physikannahmen sichtbar beschreiben.

7. **Vollständige funktionale Steuerung durch Agenten**
   - Ein gemeinsames, versioniertes Befehls- und Abfragemodell für grafische Oberfläche, CLI und Agentenadapter.
   - Jede veröffentlichte Projektfunktion muss ohne notwendige Klickautomation aufrufbar sein: Projekte/Szenen/Objekte/Komponenten/Assets bearbeiten, Verhalten ändern, Physik konfigurieren, Module verwalten, speichern, starten/pausieren/stoppen, testen und exportieren.
   - Strukturierte Ein-/Ausgabe, dokumentierte Schemas, eindeutige Fehlercodes, Auftragskennungen, Fortschritt, Ergebnisse und Fähigkeitenabfrage.
   - Lokale CLI sowie ein MCP-Adapter oder gleichwertige dokumentierte Tool-Anbindung für Codex/ChatGPT und Claude; ein lokaler Agent nutzt dieselben Operationen. Die konkreten verfügbaren Clients und Zugriffsrechte müssen bei der Integration geprüft werden.
   - Keine Behauptung, die Bereitstellung eines Servers allein verbinde automatisch alle Chatprogramme. Tatsächliche Verbindung und Befehlsausführung je Agententyp sind Abnahmekriterien.

8. **Gemeinsames Arbeiten ohne stille Überschreibungen**
   - Ein zentraler Schreibkoordinator, Projekt-/Szenenrevisionen und erkennbare Bearbeitungskonflikte.
   - Mensch und Agenten sehen denselben gespeicherten Stand sowie laufende Änderungen. Nicht widersprechende Arbeitsaufträge können getrennt vorbereitet werden; Konflikte werden vor Übernahme gemeldet.
   - Änderungen dokumentieren Urheber/Auftrag, Ausgangsrevision, Ergebnis und Fehler. Keine stillen Überschreibungen durch verspätete Agentenantworten.
   - Vorschau/Differenz, gemeinsame Rücknahme und wiederherstellbare Checkpoints. Bereits freigegebene Arbeitsabläufe dürfen innerhalb ihres Umfangs automatisch laufen; nicht jeden kleinen Edit erneut bestätigen lassen.

9. **KI-Unterstützung in konkreten Arbeitsabläufen**
   - Austauschbare Provideradapter; vorhandene lokale Modelle und bereits angebundene Hub-Agenten nutzen, ohne einen einzelnen Anbieter zur Voraussetzung zu machen.
   - Aus natürlicher Sprache ein kleines Szenenarrangement mit Spielverhalten erzeugen und anschließend gezielt verändern.
   - Kontextbezogene Hilfe zu ausgewähltem Objekt, Szene und Fehler; Eigenschaften, Materialparameter und Physikwerte vorschlagen und nachvollziehbar ändern.
   - Script-/Verhaltensentwürfe vor Übernahme auf gültige Syntax/Import und anschließend im Testlauf prüfen.
   - Testfälle aus einem Arbeitsauftrag vorschlagen, ausführen, Logs/Zustände auswerten und einen überprüfbaren Korrekturvorschlag liefern.
   - Assetsuche, Import, Zuordnung und Varianten mit vorhandenen/lokalen Mitteln unterstützen. Erzeugung neuer Bild-, Audio- oder 3D-Dateien nur bei tatsächlich verfügbarem und für dieses Projekt freigegebenem Dienst/Modul.
   - KI-Aufträge zeigen verwendeten Kontext, Provider, Fortschritt, Abbruchmöglichkeit und Änderungen. Projektbezogene Zugriffsregeln und bestehende Kostenfreigaben einhalten.
   - Ohne erreichbares KI-Modell bleiben manuelle Bearbeitung, Speichern, Spielen und Export möglich. Einen fehlenden Provider verständlich anzeigen, keine simulierte KI-Erfolgsmeldung.

10. **Beobachten und testen**
    - Objektzustände, Positionen, Geschwindigkeiten, Kontakte, Szenenstruktur, Fehler und Spielereignisse strukturiert abfragen.
    - Tastatur-/Mauseingaben, gehaltene Tasten, gleichzeitige Tasten und Freigabe zu definierten Simulationsschritten als Testsequenz senden; bei Abbruch alle Testeingaben zurücksetzen.
    - Screenshots der tatsächlichen Spielansicht sowie wiederholbare Zustandsmessungen erfassen. Aufnahme von Video/Audio als gesonderte Erweiterung möglich; technische Audiodaten ersetzen keinen gehörten Klang.
    - Tests ohne Editorfenster unterstützen, soweit der Test keine Grafik-/Audioausgabe benötigt. Reine Headless-Tests ersetzen keine visuelle Prüfung der Windows-Laufzeit.
    - Testprotokoll enthält Engine-/Projektversion, Ausgangszustand, Seed, Schrittweite, Eingabefolge, Messwerte, erwartete Toleranzen und Ergebnisse.

11. **Build, Export und Agent Hub**
    - Build-/Exportaufträge mit Fortschritt, Abbruch, Logs, Fehlern und klar bezeichneten Ergebnisdateien.
    - Der Agent-Hub-Adapter kann Engine-Aufträge starten, beobachten, abbrechen und Ergebnisse an Hub-Tickets/Materialien zurückliefern.
    - Engine bleibt unabhängig startbar; ohne Hub kann der Nutzer Projekte bearbeiten und exportieren.
    - Versionskompatibilität von Engine, Modulen, Projekten und Exportwerkzeugen dokumentieren und fehlende Voraussetzungen vor dem Build anzeigen.
    - Implementierung und spätere Projektmigration bleiben Aufgaben des Hubs, nicht des Konzept-Chats.

### Soll

- Gelenke und verbundene Körper, einfache Seil-/Federbeispiele.
- Optionaler Luftwiderstand und Wind für Spielprojektile, mit dokumentiertem vereinfachtem Modell.
- Debugansichten für Kollisionsformen, Kräfte, Kontakte und Projektilbahnen.
- Einfache Navigation/Wegfindung, grundlegender Animationsablauf und zusätzliche Szenen-/Objektvorlagen.
- Laufende Anpassung geeigneter Eigenschaften während einer Testvorschau mit eindeutiger Wahl, ob Änderungen in das Projekt übernommen werden.
- Profiling-Ansicht für Bildzeit, Physikzeit und Speicher; vergleichbare Messungen anhand dokumentierter Referenzszenen.
- Aufzeichnung kurzer Testvideos beziehungsweise Audioclips, soweit technisch sinnvoll und ohne zusätzliche Kosten.
- Erprobte KI-Rezepte für wiederkehrende Aufgaben wie Spielfigur, Kamera, Hindernisse, Auslöser und Testlauf.

### Kann

- Browseroberfläche zusätzlich zum Haupteditor, einschließlich geeigneter Live-Vorschau.
- Visuelle Logikbausteine, weitergehende Terrain- und Partikelwerkzeuge.
- Weitere Import-/Exportformate und zusätzliche lokale KI-Provider.
- Eigenes Benennungsschema, Logo und Oberflächenthema nach dem funktionalen Grundausbau.

## Abnahmekriterien

1. Auf der dokumentierten Windows-Testumgebung lassen sich je ein 2D- und ein 3D-Referenzspiel anlegen, speichern, schließen, wieder öffnen, spielen und als eigenständige Anwendung exportieren. Die exportierten Spiele laufen ohne gestarteten Hub/Editor.
2. In beiden Beispielen kann der Nutzer über die grafische Oberfläche ein Objekt hinzufügen, transformieren, seine Eigenschaften ändern, testen und exportieren, ohne Quellcode ändern zu müssen.
3. Ein dokumentiertes Fähigkeitenverzeichnis ordnet jeder veröffentlichten Projektfunktion einen strukturierten Befehl/eine Abfrage und mindestens einen prüfbaren Test zu. Es gibt keine nur per GUI bedienbare Pflichtfunktion.
4. Codex/ChatGPT, Claude und mindestens ein tatsächlich vorhandener lokaler Agent führen jeweils über ihre dokumentierte Verbindung eine kleine Folge aus: Projekt öffnen, Objekt ändern, speichern, Simulation starten/pausieren/schrittweise ausführen, Zustand abrufen und Export beauftragen. Fehlt für einen Client eine Freigabe/Verbindung, wird dies offen als nicht bestanden dokumentiert; kein Ersatznachweis allein durch einen Testclient.
5. Das Beispielmodul lässt sich nach Anleitung einbinden und wieder deaktivieren. Ein absichtlich inkompatibles Modul wird mit verständlichem Fehler abgewiesen; bestehende Projekte bleiben ladbar.
6. In 2D und 3D fallen dynamische Körper unter Schwerkraft, kollidieren mit einem statischen Boden und reagieren messbar auf Impulse. Reibung, Rückprall, Trigger und Kollisionsgruppen werden in dokumentierten Tests geprüft.
7. In einer Ballistikszene ohne Luftwiderstand wird die gemessene Bahn in beiden Dimensionen mit der analytischen Bahn bei konstanter Schwerkraft verglichen. Beispiel-Testbereich: höchstens zwei simulierte Sekunden bei 120 Physikschritten pro Sekunde; maximaler Positionsfehler 0,15 Szeneneinheiten. Szeneneinheiten, Startzustand und Messverfahren vor Abnahme festschreiben.
8. Ein schneller Projektiltest gegen eine dünne Wand löst genau das erwartete Trefferereignis aus. Mindestens 100 festgelegte Versuche innerhalb eines dokumentierten Bereichs für Geschwindigkeit, Wandstärke und Auftreffwinkel liefern keinen ausgelassenen Treffer. Rückprall und Lebensdauer werden separat geprüft.
9. Eine definierte Testeingabe hält eine Taste über 120 Schritte, kombiniert zeitweise eine zweite Taste und lässt beide wieder los. Eingabestatus und resultierende Bewegung stimmen mit dem Testablauf überein; nach Abbruch bleibt keine Testtaste gedrückt.
10. Zwei Agenten beziehungsweise GUI und Agent ändern aus derselben Ausgangsrevision widersprechend dieselbe Eigenschaft. Der Konflikt wird erkannt; eine Änderung überschreibt die andere nicht unbemerkt. Rücknahme und Checkpoint-Wiederherstellung werden praktisch demonstriert.
11. Eine KI erstellt eine kleine Szene mit Verhalten aus einem Textauftrag, verändert sie anhand eines zweiten Auftrags und diagnostiziert einen absichtlich eingebauten Fehler anhand tatsächlich erfasster Daten. Änderungen, Validierung und Testresultat sind sichtbar und rücknehmbar.
12. Bei abgeschaltetem KI-Provider funktionieren manuelle Bearbeitung, Speichern, Spielen und Export weiterhin; der Assistent meldet den fehlenden Provider verständlich.
13. Ein Testlauf liefert strukturierten Zustand, Log und Screenshot aus der echten Grafikvorschau. Wiederholungen auf derselben dokumentierten Konfiguration erfüllen die angegebenen Zustandstoleranzen; keine bitgenaue plattformübergreifende Physikgarantie.
14. Der Hub startet einen Engine-Auftrag, zeigt seinen Fortschritt und erhält Ergebnis/Fehler samt Artefaktpfad. Ein zweiter Auftrag lässt sich abbrechen. Danach funktioniert die Engine weiterhin unabhängig vom Hub.
15. Änderungen und Exporte bleiben auf die zugelassenen Projekt-/Ausgabeorte beschränkt. Ein Test mit unzulässigem Zielpfad scheitert verständlich, ohne dort zu schreiben.
16. Mindestens ein Referenzspiel wird vom Projektstart über Szenen-/Verhaltensänderung bis zum fertigen Export durch einen Agentenworkflow erstellt; der Nutzer kann denselben Stand anschließend im grafischen Editor weiterbearbeiten.
17. Eine kurze deutsche Anleitung erklärt Installation/Start, Erstprojekt, Oberfläche, Agentenanbindung, Module, Tests, Export sowie bekannte Grenzen. Abnahmeprotokolle trennen bestandene Prüfungen, offene Voraussetzungen und noch nicht wahrgenommene Ergebnisse.

## Rahmenbedingungen

- Plattform: Windows für Engine-Laufzeit, lokale Dienste und exportierte Spiele. Der Standort der grafischen Oberfläche ist flexibel.
- Technik: eigene modulare Engine-/Editor-/Automatisierungsschicht auf Godot. Claude legt eine geeignete stabile Godot-Version und die konkreten Erweiterungspunkte fest, prüft vorhandene Komponenten und dokumentiert die Abgrenzung zwischen eigener Entwicklung und übernommenem Kern.
- Architektur: ein gemeinsames Befehlsmodell für GUI, CLI und Agenten; getrennte Adapter für Editor, Spiel-Laufzeit, Build und Agent Hub. Interne Auswahl der Programmiersprachen und Transportprotokolle trifft Claude innerhalb des freigegebenen Entwurfs.
- Daten und Datenschutz: lokale Projekte und Projektstände; lokale Schnittstellen standardmäßig nur auf diesem PC, projektbezogener Zugriff. Projektinhalte nur an bereits freigegebene Agenten/Provider weitergeben. Keine Zugangsdaten in Lastenheften, Projektdateien oder Logs.
- Medien: zunächst eigene, vorhandene oder passend frei lizenzierte Beispielassets. Für dieses Projekt ist weder Higgsfield-Nutzung noch ein zusätzlicher kostenpflichtiger KI-/Mediendienst freigegeben.
- Grenzen: keine zusätzlichen Kosten, Abos, Konten, Adminrechte oder unbestätigten Lizenzannahmen. Bestehende Freigaben gelten nur in ihrem tatsächlichen Umfang; kostenlose notwendige Werkzeuge gemäß geltender Hub-Anleitung behandeln.
- Offene Komponenten: verwendete Grundlagen, eigene Module, Versionen und Lizenzen offen dokumentieren. Eine eigene Oberfläche auf Godot nicht als selbst entwickelten Renderer/Physikkern darstellen.
- Ressourcen/Leistung: vorhandene Hardware und lokale Modelle zuerst erfassen. Leistungsgrenzen mit Referenzszenen und Messdaten dokumentieren; keine unbelegte Bildraten- oder kurze Fertigstellungszusage.
- Priorität: Standard 2; keine Änderung an Prioritäten, Status oder laufender Arbeit anderer Hub-Projekte.
- Ablaufplan: ja, ausdrücklich bestätigt. Der Hub erstellt den grafischen Ablaufplan aus den folgenden Phasen; das Vorliegen dieser Beschreibung ist noch kein Nachweis eines bereits erstellten Dashboard-Diagramms.

### Geplante Umsetzungsphasen

1. Godot-Basis und Erweiterungspunkte prüfen, Modul-/Projekt-/Befehlsvertrag festlegen und einen Windows-Durchstich mit kleinem Editor, Agentenaufruf und Export erstellen.
2. Vollständigen 2D-Arbeitsablauf mit Assets, Spielverhalten, Physik, Ballistik und Referenzspiel liefern.
3. Vollständigen 3D-Arbeitsablauf mit Kamera, Materialien/Beleuchtung, Physik, Ballistik und Referenzspiel liefern.
4. KI-Arbeitsabläufe, die drei tatsächlichen Agentenanbindungen, Konfliktbehandlung und Hub-Integration vervollständigen.
5. Gesamtabnahme mit GUI-/API-Funktionsabdeckung, Modultest, wiederholbaren Simulationstests und eigenständigen Windows-Exporten.

Agentenschnittstellen, KI-Anschlussstellen, Rücknahme und Testbarkeit entstehen bereits in Phase 1 und werden in jeder Folgephase mitgeführt. Die Phasen verschieben 2D, 3D, Ballistik oder Agentensteuerung nicht aus dem zugesagten Gesamtumfang.

### Technische Grundlage der Empfehlung

Offizielle Dokumentation, geprüft am 18.10.2026; Grundlage der Architekturplanung, keine Behauptung bereits implementierter Agentenschnittstellen:
- Physik und Grenzen der Deterministik: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
- Editor-Plugin-Erweiterungen: https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html
- Editorsteuerung: https://docs.godotengine.org/en/stable/classes/class_editorinterface.html
- Kommandozeile und Headless-Betrieb: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- Windows-Export: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html

## Nicht-Ziele

- Eine vollständige Entsprechung aller Funktionen etablierter Großengines in der ersten Ausbaustufe.
- Automatischer Umbau bestehender Hub-Spiele oder eigenmächtige Änderungen am Hub außerhalb des freigegebenen Engine-Adapters.
- Uneingeschränkte Kontrolle des gesamten Rechners durch Agenten.
- Veröffentlichung in Stores, Hosting öffentlicher Dienste, Multiplayer-Backend oder Exporte für Konsolen/Mobilgeräte als Teil dieses ersten Projekts.
- Hochgenaue wissenschaftliche Simulation, vollständige Flüssigkeits-/Zerstörungssimulation oder nicht vereinbarte Spezialphysik.
- Automatische Erzeugung aller Medien unabhängig von verfügbaren Werkzeugen und Freigaben.

## Rückmeldungen

- 2026-10-18 (übernommen): Nutzer wünscht eine eigene modulare Windows-Game-Engine für den Agent Hub, breite KI-Unterstützung sowie vollständige Steuerbarkeit durch Codex/ChatGPT, Claude und lokale KI-Agenten. Eine einfach bedienbare grafische Oberfläche ist erforderlich; ob nativ oder im Browser ist offen. 2D, 3D und Physik einschließlich Ballistik sind ausdrücklich gewünscht.

- 2026-10-18 (übernommen): Nutzer bestätigt „Auf offener Engine aufbauen“ und beantwortet den grafischen Ablaufplan mit „Ja“. Dies legt technische Richtung und Ablaufplan fest; eine Freigabe des gesamten vorliegenden Lastenhefts zur Umsetzung steht noch aus.

- 2026-10-18 (übernommen): Nutzer gibt das vollständig vorgestellte Lastenheft mit „Ja freigeben“ ausdrücklich zur Umsetzung frei. Status auf bereit gesetzt. Freigabe umfasst die modulare Godot-basierte Windows-Engine mit 2D/3D, Spielphysik und Ballistik, verständlicher Oberfläche, KI-Unterstützung, vollständigen Agentenschnittstellen sowie dem grafischen Ablaufplan. Es gelten die im Lastenheft beschriebenen Rahmenbedingungen und Kostengrenzen.
