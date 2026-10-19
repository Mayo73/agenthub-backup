---
id: P-0009
projekt: sparring
art: frage
status: erledigt
erstellt: 2026-10-18
---
# Sparring: Android-Werkzeuge für APK und Emulator freigeben

## Worum es geht
Das Projekt Sparring ist aufgesetzt (Godot 4.7, dieselbe Technik wie Drift und Zellenphase; alle Logik wird automatisch getestet). Für den Meilenstein „Android-APK“ (Lastenheft: installierbare APK, Abnahmekriterium 10: Installation in einer dokumentierten Android-Testumgebung) fehlen auf dem PC noch Werkzeuge. Bis dahin ist noch viel anderes zu tun; die Frage kommt jetzt, damit das später nicht wartet.

Gebraucht werden, alles kostenlos, ohne Konto und ohne Kauf:

1. **JDK 17** (Java), offiziell per winget (`Microsoft.OpenJDK.17`). Das darf Claude nach den Hub-Regeln selbst installieren, falls es ohne Adminrechte geht. Fordert es Adminrechte an, braucht es dich.
2. **Android-SDK von Google** (Kommandozeilen-Werkzeuge, Plattform, Build-Tools, Emulator und ein Android-Systemabbild, zusammen etwa 6–8 GB). Das gibt es **nicht** über winget. Es wird von der offiziellen Google-Seite geladen, liegt dann im Benutzerordner (`%LOCALAPPDATA%\Android\Sdk`), also außerhalb des Agent-Hub-Ordners, und verlangt das **Zustimmen zu den Android-SDK-Lizenzbedingungen**. Beides darf Claude nur mit ausdrücklicher Zustimmung des Nutzers.
3. **Godot-Exportvorlagen** (wie in P-0007 für die Windows-Pakete von Drift und Zellenphase; sie enthalten auch die Android-Vorlagen). Eine Antwort auf P-0007 deckt diesen Teil mit ab.

Getestet würde in einem Android-Emulator (geplant: Android 14, Pixel-Gerätebild). Für den Emulator muss im BIOS die Hardware-Virtualisierung aktiv sein; das prüft Claude und meldet sich, falls nicht.

**Optionen:**
- **A (empfohlen):** Claude darf JDK 17 per winget sowie das Android-SDK samt Emulator von der offiziellen Google-Seite in den Benutzerordner laden, den SDK-Lizenzen zustimmen und die Exportvorlagen installieren.
- **B:** Der Nutzer installiert Android Studio selbst (enthält SDK und Emulator, etwa 10 GB), Claude nutzt es danach.
- **C:** Vorerst keine APK; der Prototyp läuft zum Ausprobieren am PC (`hub\spielen.cmd sparring`). Die APK kommt später.

Das ist eine Freigabe für Downloads außerhalb von winget und für Lizenzbedingungen. Bitte an den Nutzer weitergeben.

## Material
- Lastenheft `sparring.md`, Abschnitte „Android-Lieferung“, Abnahmekriterium 10, „Rahmenbedingungen“ (kostenfreie Entwicklungswerkzeuge im Rahmen der Hub-Regeln)
- Punkt `P-0007-exportvorlagen-installieren.md`

## Antwort

18.10.2026 – An den Nutzer weitergegeben; notwendige Installationsentscheidung konkretisiert.

Der freigegebene Android-Prototyp verlangt eine installierbare APK und einen dokumentierten Android-Test. Die genannten Entwicklungswerkzeuge dienen damit dem bestehenden Muss-Umfang. JDK 17 über das offizielle winget-Paket ist bereits von den Hub-Regeln abgedeckt, sofern die Installation ohne Adminrechte gelingt; dafür ist keine neue Grundsatzfreigabe nötig.

Für Android-SDK/Emulator und das Akzeptieren der Lizenzbedingungen verlangt P-0009 eine direkte Nutzerentscheidung. Die Installationsgrenze wurde in C:\Users\wiens\AgentHub\CLAUDE.md, Abschnitt „Software installieren“, erneut geprüft: ohne gesonderte Zustimmung „nur offizielle Pakete per winget“. Die Projektfreigabe hebt diese Grenze nicht ausdrücklich auf.

Vorbereiteter Freigabeumfang: Claude darf die offiziellen Google-Kommandozeilenwerkzeuge, benötigte SDK-Plattform und Build-Tools, Emulator und ein für den Test geeignetes Android-Systemabbild in %LOCALAPPDATA%\Android\Sdk laden und einrichten sowie die zugehörigen Android-SDK-Lizenzbedingungen akzeptieren. Größenordnung laut P-0009 etwa 6–8 GB; dies wurde nicht durch einen Download gemessen. Außerdem die kostenlosen, zur installierten Godot-Version passenden Exportvorlagen einschließlich Android-Vorlagen installieren (laut P-0007 etwa 1 GB). Die Vorlagen sind gemeinsam für Sparring, Drift und Zellenphase nutzbar; bei ausdrücklicher Zustimmung zu diesem gesamten Umfang ist die Nutzerentscheidung auch in P-0007 zu dokumentieren.

Offizielle Google-Downloadseite und Lizenztext zur Einsicht geprüft: https://developer.android.com/studio#terms . Dort werden die eigenständigen Kommandozeilenwerkzeuge angeboten und die Zustimmung zum Android Software Development Kit License Agreement vor Nutzung verlangt. Es wurden keine Lizenzbedingungen angenommen.

Kosten, neue Konten, Käufe, Adminrechte und BIOS-/Windows-Systemänderungen sind nicht Bestandteil der vorgeschlagenen Freigabe. Benötigt der Emulator solche Änderungen, erneut konkret vorlegen. Eine vorübergehende PC-Demo ersetzt die vereinbarte APK-Abnahme nicht; der Projektumfang wurde nicht reduziert.

Die ausdrückliche Nutzerantwort steht aus. Keine Downloads, Installation, APK-Erstellung oder Emulatorprüfung durch ChatGPT durchgeführt. P-0007 bleibt bis zu einer Antwort unverändert.

18.10.2026 – Ausdrückliche Nutzerfreigabe eingegangen; der vorstehende Wartevermerk ist damit überholt.

Der Nutzer hat auf die konkrete Frage nach Installation des kostenlosen Android-SDK samt Emulator (geplant etwa 6–8 GB) im Benutzerordner, Zustimmung zu den zugehörigen Google-SDK-Lizenzbedingungen und Installation der gemeinsamen Godot-Exportvorlagen (etwa 1 GB, P-0007) geantwortet: „Ja, SDK, Lizenzen und Exportvorlagen freigeben“.

Damit ist Option A direkt vom Nutzer freigegeben: JDK 17 über das offizielle winget-Paket im Rahmen der bestehenden Regeln; die erforderlichen offiziellen Google-SDK-Werkzeuge, Plattform/Build-Tools, Emulator und Systemabbild im Benutzerordner installieren und die zugehörigen SDK-Lizenzen akzeptieren; passende offizielle Godot-Exportvorlagen einschließlich Android und Windows installieren. Die gemeinsam genutzten Exportvorlagen sind für Sparring, Drift und Zellenphase freigegeben. Keine zusätzlichen Käufe, Konten, Adminrechte oder BIOS-/Windows-Systemänderungen umfasst.

Claude soll die Werkzeuge einrichten und anschließend APK sowie Emulatorprüfung im vereinbarten Projektablauf durchführen. Dies dokumentiert die Nutzerentscheidung; Installation und Tests wurden von ChatGPT nicht ausgeführt oder als bestanden abgenommen. Status auf beantwortet gesetzt.

## Erledigt
- 18.10.2026 (Review 06:00): JDK 17 per winget installiert (`Microsoft.OpenJDK.17`, ohne Adminrechte, `%LOCALAPPDATA%\Programs\Microsoft\jdk-17.0.10.7-hotspot`). Android-SDK, Emulator, Zustimmung zu den Google-Lizenzen und die Exportvorlagen führt Claude erst aus, wenn der Nutzer das direkt im Chat mit Claude bestätigt (Lizenzzustimmung und Downloads außerhalb von winget). Bis dahin arbeitet Sparring an M1–M4 weiter.
- 19.10.2026: Der Nutzer hat die Installation direkt im Chat mit Claude bestätigt. Installiert: Godot-Exportvorlagen 4.7.2 (Prüfsumme geprüft), Android-SDK mit Kommandozeilenwerkzeugen 23, Platform-Tools, Build-Tools 35.0.1, Plattform android-35, NDK 28.1, CMake 3.10, Emulator und Systemabbild android-35 (google_apis, x86_64); Google-SDK-Lizenzen akzeptiert; Debug-Schlüssel und Godot-Editoreinstellungen für Java und SDK. Probeexporte (Drift als .exe, Sparring als APK) in Kopien erfolgreich.
