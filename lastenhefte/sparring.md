---
projekt: sparring
titel: Sparring – Android-Prototyp für Kampfsport-Matches
status: aktiv
prioritaet: 2
ablaufplan: ja
erstellt: 2026-10-18
---

# Sparring – Android-Prototyp für Kampfsport-Matches

## Zielsetzung

Ein funktionierender, mit React Native entwickelter Android-App-Prototyp ermöglicht das gegenseitige Swipe-Matching von Kampfsportpartnern und die Vereinbarung von freiwilligem sportlichem Sparring draußen. Die erste Version arbeitet ausschließlich mit fiktiven Testprofilen und lokalen Testdaten. Der Nutzer kann den gesamten Ablauf vom Profil über Swipe, Match und Chat bis zur gemeinsamen Orts- und Terminwahl selbst bedienen; Aktionen verändern den tatsächlichen App-Zustand und Daten bleiben lokal gespeichert. Das Ergebnis ist eine installierbare mobile Anwendung, kein Spiel und keine reine Designvorführung. Eine Umsetzung der App in Godot oder einer anderen Spielengine ist ausgeschlossen.

## Ausgangslage

- Neue Projektidee des Nutzers aus dem Sprachgespräch am 18.10.2026; am selben Tag ausdrücklich zur Umsetzung durch den Agent Hub freigegeben.
- Bestätigt: gegenseitiges Swipe-Matching, auch zwischen unterschiedlichen Disziplinen wie Jiu-Jitsu und MMA, sowie ein gemeinsam vereinbarter Treffpunkt draußen. Die Teilnahme soll ausdrücklich einvernehmlich sein; ein Gym ist keine Voraussetzung.
- Plattform ausdrücklich nur Android. iPhone und iPad wurden als Versprecher korrigiert.
- Grafischer Ablaufplan im Agent-Hub-Dashboard mit „Ja, definitiv“ bestätigt.
- Erster Lieferumfang ausdrücklich bestätigt: „Prototyp mit Testprofilen erstmal“.
- Der folgende Umfang wurde am 18.10.2026 mit „Ja, absolut freigeben“ ausdrücklich zum Projektstart freigegeben. Bestehende Projekte werden nicht pausiert oder umpriorisiert.
- Am 20.10.2026 hat der Nutzer ausdrücklich den Neustart desselben Projekts mit React Native als fester Bedingung und als funktionierendem App-Prototyp statt Spiel beauftragt. Die Godot-Fassung bleibt als Referenz erhalten; ihre bisherigen Abnahmen gelten nicht für die neue App.

## Funktionsumfang

### Muss

- **Lokaler Demomodus:** Sichtbare Kennzeichnung als Prototyp mit Testprofilen. Alle Profile, Nachrichten und Treffen sind fiktive, lokal gespeicherte Testdaten. Kein Konto und kein Server erforderlich.
- **Profile:** Mindestens acht fiktive erwachsene Testpersonen mit Anzeigename, eigenem oder frei lizenziertem Avatar, Kampfsportart und Erfahrung. Mindestens Jiu-Jitsu, MMA und Boxen sind vertreten. Ein eigenes Demoprofil kann bearbeitet werden.
- **Entdecken und Swipen:** Profile einzeln ansehen, Interesse bekunden oder überspringen; beide Aktionen funktionieren auch über sichtbare Schaltflächen. Unterschiedliche Kampfsportarten verhindern ein Match nicht automatisch.
- **Gegenseitiges Matching:** Ein Match entsteht erst bei beiderseitigem Interesse. Zum Nachspielen beider Seiten kann zwischen mindestens zwei lokalen Testpersonen gewechselt werden. Dieser Wechsel ist klar als Demofunktion gekennzeichnet. Einseitiges Interesse eröffnet keinen Chat.
- **Demochat:** Nach dem Match lokal Nachrichten zwischen den beiden Testpersonen austauschen. Der Perspektivwechsel erlaubt das Testen von Absender und Empfänger; es werden keine Nachrichten an echte Menschen versendet.
- **Treffen vereinbaren:** Einen Outdoor-Ort als Text, Datum, Uhrzeit und Trainingsform vorschlagen. Beide Testpersonen müssen zustimmen, bevor die App das Treffen als bestätigt anzeigt. Änderungen an Ort, Termin oder Trainingsform setzen die Bestätigung zurück. Eine Gym-Buchung ist nicht erforderlich.
- **Freiwilligkeit:** Ein Match beenden oder einen Termin absagen können; das Ergebnis ist aus beiden Testperspektiven sichtbar. Ein bestätigter Termin wird nicht als Verpflichtung zur Teilnahme oder zum Weitermachen dargestellt.
- **Lokaler Zustand:** Profiländerungen, Interessen, Matches, Nachrichten und Termine bleiben nach App-Neustart erhalten. Eine deutlich beschriftete Funktion stellt nach Bestätigung die ursprünglichen Testdaten wieder her.
- **Android-Lieferung:** Installierbare APK, deutsche Oberfläche und kurze Anleitung für Installation, Demoprofilwechsel, kompletten Testablauf und Zurücksetzen bereitstellen.
- **Ablaufplan:** Im Dashboard Meilensteine für React-Native-Grundgerüst, Profile, Swipe und Match, Chat, Treffen, Speicherung, APK und Abnahme führen. Fortschritt und Abnahme beziehen sich auf den freigegebenen React-Native-Neustart.

### Soll

- Kampfsportart und Erfahrung als einfache Filter für die vorhandenen Testprofile anbieten.
- Gewünschte Trainingsintensität und gemeinsam vereinbarte Regeln im Treffvorschlag darstellen. Unterschiedliche Disziplinen werden nicht als automatisch identische Wettkampfregeln behandelt.
- Blockieren einer Testperson ausprobieren können; danach erscheinen keine weiteren Kontaktmöglichkeiten zu dieser Person.
- Verständliche Leerzustände für keine weiteren Profile, keine Matches und keine Nachrichten sowie Hinweise bei unvollständigen Treffvorschlägen.

### Kann

- Schematische, selbst erstellte Ortsdarstellung ohne externen Kartendienst.
- Weitere rein fiktive Profilmerkmale wie Gewichtsklasse, Verfügbarkeit und vorhandene Ausrüstung.

## Abnahmekriterien

1. Beim ersten Start erscheinen mindestens acht eindeutig als Testprofile gekennzeichnete Personen; Jiu-Jitsu, MMA und Boxen sind darunter.
2. Profiländerungen bleiben nach vollständigem Beenden und erneutem Starten der App erhalten.
3. Testperson A bekundet Interesse an B: Noch kein Match. Nach dem Wechsel zu B und gegenseitigem Interesse entsteht genau ein gemeinsames Match, das aus beiden Perspektiven sichtbar ist.
4. Ein Jiu-Jitsu- und ein MMA-Profil können sich gegenseitig matchen. Swipen und die entsprechenden Schaltflächen lösen dasselbe Verhalten aus.
5. A und B können nach dem Match lokal Nachrichten austauschen. Beim Wechsel zu einer unbeteiligten Testperson erscheint dieser Chat nicht in deren Chatliste. Dies prüft die Demoansicht, nicht die Sicherheit eines Onlinebetriebs.
6. Ein Outdoor-Ort, Datum, Uhrzeit und Trainingsform lassen sich vorschlagen. Erst nach beiderseitiger Zustimmung ist das Treffen bestätigt. Jede Änderung an diesen Angaben verlangt erneute Zustimmung.
7. Absage und Beenden eines Matches sind aus beiden Testperspektiven sichtbar. Nach dem Beenden können über dieses Match keine neuen Nachrichten oder Treffanfragen erstellt werden.
8. Der vollständige Ablauf Profil → Swipe → Match → Chat → Treffvorschlag → Bestätigung funktioniert bei deaktivierter Netzwerkverbindung; es sind keine Anmeldung und keine Standortfreigabe nötig.
9. Nach einem Neustart bleiben Match, Nachrichten und Termin erhalten. Die bestätigte Rücksetzfunktion stellt den dokumentierten Ausgangszustand wieder her.
10. Die APK lässt sich in einer dokumentierten Android-Testumgebung installieren und starten. Getestete Android-Version und Gerät beziehungsweise Emulator werden angegeben; eine spätere Prüfung auf dem konkreten Nutzergerät wird nicht ohne Durchführung als bestanden ausgegeben.
11. Im Agent-Hub-Dashboard ist der bestätigte grafische Ablaufplan mit den genannten Meilensteinen sichtbar.
12. Ein tatsächliches Treffen oder Sparring ist kein Software-Abnahmekriterium; alle Funktionsprüfungen verwenden fiktive Testdaten.
13. Die App ist mit React Native gebaut, nachweisbar an Projektquellen und Build-Konfiguration. Die installierte APK startet bei ausgeschaltetem Entwicklungsrechner beziehungsweise gestopptem Entwicklungsserver und ermöglicht den vereinbarten lokalen Ablauf bei deaktivierter Netzwerkverbindung.
14. Android-Bedienung: Die System-Zurück-Aktion schließt je nach Zustand zuerst die geöffnete Bildschirmtastatur, dann einen geöffneten Dialog beziehungsweise führt von einer Unterseite zurück. Formulare sind scrollbar; bei geöffneter Bildschirmtastatur bleiben das bearbeitete Eingabefeld und die zugehörigen Aktionen sichtbar oder durch Scrollen erreichbar. Status- und Navigationsleisten des Systems verdecken keine App-Inhalte oder Bedienelemente. Diese Fälle werden in der dokumentierten Android-Testumgebung geprüft.
15. Der vollständige Ablauf Profil → gegenseitiges Match → beidseitiger Chat → Treffvorschlag → Bestätigung → Änderung/Absage und das Speichern nach vollständigem Beenden und Neustart werden auf der React-Native-App in einer dokumentierten Android-Testumgebung tatsächlich ausgeführt. Ein Prüfprotokoll nennt Android-Version, Gerät beziehungsweise Emulator, Schritte und beobachtete Ergebnisse; Bildschirmaufnahmen belegen gefüllte Zustände mit eigenen und empfangenen Nachrichten sowie Treffvorschlag und Bestätigung. Standbilder allein ersetzen den Bedien- und Persistenztest nicht.

## Rahmenbedingungen

- Plattform: ausschließlich Android. Claude legt eine geeignete Mindestversion und eine verfügbare Testumgebung fest und dokumentiert sie. Das konkrete Nutzergerät ist noch nicht benannt und kann bei der Installation berücksichtigt werden.
- Technik: **React Native ist eine feste Bedingung.** Lokale Datenspeicherung und eine installierbare APK, die ohne Entwicklungsrechner oder Entwicklungsserver startet und den vereinbarten Ablauf offline ermöglicht. Keine Umsetzung in Godot oder einer anderen Spielengine. Die Auswahl geeigneter kostenfreier Bibliotheken innerhalb dieser Vorgabe bleibt Claude überlassen. Kostenfreie, für den Prototyp notwendige Entwicklungswerkzeuge im Rahmen der bestehenden Hub-Regeln verwenden.
- Zielgruppe und Region: Demodaten stellen erwachsene Personen mit unterschiedlichen Erfahrungen dar. Eine Zielregion für echte Nutzer ist für diesen lokalen Prototyp nicht nötig und wird vor einer späteren Betriebsfassung geklärt.
- Daten und Datenschutz: ausschließlich fiktive lokale Daten. Keine realen Nutzerkonten, keine Standorterfassung, kein Backend und keine Telemetrie. Ein Perspektivwechsel dient nur zum Prüfen der Demo; er ist keine Anmeldung oder verifizierte Identität.
- Medien: eigene oder passend frei lizenzierte UI-Elemente und Avatare. Für dieses Projekt sind weder kostenpflichtige Medien noch Higgsfield-Credits freigegeben.
- Grenzen: 0 Euro zusätzliche Dienst-/Assetkosten; kein Hosting, externer Kartendienst, Verifikationsdienst, Store-Konto, Abo oder Kauf beauftragt. Falls zusätzliche Kosten, Konten oder Adminrechte notwendig werden, als konkrete Entscheidung vorlegen.
- Sonstiges: grafischer Ablaufplan ausdrücklich bestätigt (ablaufplan: ja). Plattform, Ablaufplan und Prototypumfang wurden bestätigt; ausdrückliche Startfreigabe am 18.10.2026 mit „Ja, absolut freigeben“ und ausdrücklicher Auftrag zum React-Native-Neustart am 20.10.2026. Alle Abnahmekriterien sind auf der neuen App erneut zu prüfen; frühere Godot-Testergebnisse sind keine Abnahme der React-Native-Version.
- Weiterer Ausbau: echter Mehrnutzerbetrieb, Anmeldung, Moderation, Standortdienste und Veröffentlichung wären ein gesondert abzustimmender Folgeumfang.

## Nicht-Ziele

- Ein Spiel, Spielmechaniken oder die Umsetzung der App in Godot beziehungsweise einer anderen Spielengine.
- Eine reine Designvorführung ohne funktionierende App-Abläufe und dauerhafte lokale Speicherung.
- Echte Nutzervermittlung, echte Nachrichtenübermittlung oder echte Treffen in dieser ersten Version.
- iPhone-, iPad- oder Desktop-Version.
- Verpflichtende Gym-Mitgliedschaft oder Gym-Buchung.
- App-Store-Veröffentlichung, Onlinebetrieb und Monetarisierung.
- Eine vollständige Dating-App; übernommen wird das Prinzip des gegenseitigen Swipe-Matchings.

## Rückmeldungen

- 2026-10-18: Nutzeridee: per Swipe Kampfsportpartner finden; bei gegenseitigem Interesse einen Treffpunkt vereinbaren. Als Beispiele wurden Jiu-Jitsu und MMA genannt.
- 2026-10-18: Der Nutzer hat klargestellt, dass die Teilnahme einvernehmlich sein soll und Treffen draußen statt verpflichtend in einem Gym stattfinden sollen.
- 2026-10-18: Nach Korrektur der Versprecher ausdrücklich Android als Plattform bestätigt.
- 2026-10-18: Grafischen Ablaufplan im Agent-Hub-Dashboard mit „Ja, definitiv“ bestätigt.
- 2026-10-18: Auf die Frage nach echtem Mehrnutzerbetrieb oder Prototyp ausdrücklich „Prototyp mit Testprofilen erstmal“ gewählt. Entwurf auf einen lokal bedienbaren Android-Prototyp eingegrenzt; Projektstart noch nicht freigegeben.
- 2026-10-18 (übernommen): Der Nutzer hat den konkret vorgelegten Umfang ausdrücklich mit „Ja, absolut freigeben“ zur Umsetzung freigegeben: lokaler Android-Prototyp mit acht fiktiven Testprofilen, Swipe-Matching, Demochat, Orts-/Terminvereinbarung und grafischem Ablaufplan. Status auf bereit gesetzt. Kein echter Mehrnutzerbetrieb, keine Veröffentlichung und keine zusätzlichen kostenpflichtigen Dienste freigegeben.

- 2026-10-20 (übernommen): **Ausdrücklich beauftragter Neustart als React-Native-App.** Der Nutzer verlangt: „Ich möchte bitte das Sparring Projekt neustarten mit der Bedingung es mit react native zu bauen. Und ich möchte den scope anpassen: es soll ein funktionierender App Prototyp sein und kein Spiel“. Damit sind der technische Neustart und die folgende Präzisierung des App-Umfangs freigegeben; keine erneute Startfreigabe erforderlich. Diese Vorgabe ersetzt für Sparring die bisher freie Technikwahl „Claude entscheidet“.

  **Verbindliche Technik und Ziel:** Sparring wird als echte Android-Anwendung mit React Native neu aufgebaut. React Native ist für dieses Projekt eine feste Bedingung, nicht nur eine Präferenz. Keine Umsetzung der App-Oberfläche in Godot oder einer anderen Spielengine und keine Spielmechanik. Ziel ist ein vollständig bedienbarer, installierbarer App-Prototyp mit tatsächlichen Zustandsänderungen und lokaler Speicherung; eine reine Designvorführung oder klickbare Attrappe genügt nicht. Die Auswahl passender kostenfreier Bibliotheken innerhalb dieser Vorgabe bleibt Claude überlassen.

  **Übergabe des bisherigen Stands:** Claude soll beim Übernehmen dieser Rückmeldung die weitere Godot-Entwicklung von Sparring ablösen, die alten Implementierungsaufträge entsprechend schließen beziehungsweise als überholt kennzeichnen und unter derselben Projektkennung `sparring` einen neuen React-Native-Arbeitsplan anlegen. Den bisherigen Stand als Referenz erhalten, nicht löschen. Vorhandene Anforderungen, Testdaten und geeignete eigene/frei lizenzierte Medien dürfen weiterverwendet werden. Bisherige Godot-Ticketabschlüsse und Sichtprüfungen zählen nicht als Abnahme der neuen React-Native-App. Diese Rückmeldung ist ein Neustart des bestehenden Projekts, kein zusätzliches Projekt und keine Änderung der Priorität anderer Projekte.

  **Funktionierender App-Umfang:** Die vereinbarte erste Version bleibt Android mit mindestens acht fiktiven erwachsenen Testprofilen und lokalem Demoperspektivwechsel. Profil bearbeiten, Filter, Wischen und entsprechende Schaltflächen, gegenseitiges Matching, Nachrichten zwischen den Testperspektiven, Outdoor-Ort/Datum/Uhrzeit/Trainingsform vorschlagen und beidseitig bestätigen sowie Absagen, Match beenden und die vorgesehenen Blockierfunktionen müssen tatsächlich bedienbar sein. Änderungen an einem bestätigten Treffvorschlag setzen die Zustimmung zurück. Daten bleiben nach vollständigem App-Neustart erhalten; Zurücksetzen erfolgt erst nach Bestätigung. Testdaten bleiben als solche gekennzeichnet. Echte Nutzerkonten, ein Online-Backend oder eine Veröffentlichung sind mit diesem Neustart nicht zusätzlich beauftragt.

  **App-Bedienung und Lieferung:** Deutsche mobile Oberfläche mit nachvollziehbarer Navigation, funktionierender Android-Zurück-Bedienung, Touch-Eingaben und scrollbaren Formularen. Die Bildschirmtastatur darf Eingabefelder und zugehörige Aktionen nicht unerreichbar machen; Systemleisten dürfen Inhalte nicht verdecken. Die APK muss nach Installation unabhängig vom Entwicklungsrechner beziehungsweise Entwicklungsserver starten und den vereinbarten lokalen Ablauf offline ermöglichen. Kurze Installations- und Testanleitung beilegen. Die zuletzt abgestimmte moderne Swipe-App-Gestaltung dient als gestalterische Referenz und kann für passende mobile App-Bedienelemente angepasst werden.

  **Neue Abnahme und Ablaufplan:** Die vorhandenen fachlichen Abnahmekriterien auf der React-Native-Version erneut prüfen und um die verbindliche Technik sowie die genannte Android-Bedienung ergänzen. Den vollständigen Ablauf Profil → gegenseitiges Match → beidseitiger Chat → Treffvorschlag → Bestätigung → Änderung/Absage und das Speichern nach Neustart in einer dokumentierten Android-Testumgebung tatsächlich ausführen. Bildschirmaufnahmen müssen gefüllte Zustände zeigen; Standbilder allein belegen keine funktionierenden Abläufe. Den bereits gewünschten grafischen Ablaufplan im Dashboard auf React-Native-Grundgerüst, Profile, Swipe/Match, Chat, Treffen, Speicherung, APK und Abnahme umstellen und den Fortschritt für diesen Neustart neu bewerten. Claude übernimmt die entsprechenden Änderungen im Hauptteil des Lastenhefts und in der Projektplanung.

  **Bestehender Rahmen:** Android bleibt die Zielplattform, der grafische Ablaufplan bleibt gewünscht, und die bisherigen Grenzen zu zusätzlichen Kosten, Konten, Medien und Veröffentlichung gelten weiter. Keine neue kostenpflichtige Infrastruktur oder Higgsfield-Nutzung für Sparring freigegeben.
