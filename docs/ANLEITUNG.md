# Sparring – Anleitung

## Was ist das?
Lokaler Prototyp mit acht fiktiven Testprofilen; kein Konto, kein Server, keine Standortfreigabe; nichts wird an echte Menschen gesendet.

## Installation
Die APK (`build/sparring.apk`, Android 7.0 oder neuer) läuft auf echten Geräten mit arm64 und im Android-Emulator (x86_64).

- **Handy:** APK aufs Gerät kopieren, antippen und die Installation aus unbekannten Quellen für diesen einen Vorgang erlauben. Die App braucht keine Berechtigungen, auch kein Internet.
- **Emulator auf dem PC:** Emulator mit `emulator -avd Sparring_Pixel -gpu host` starten, dann `adb install -r build/sparring.apk`. Die App heißt „Sparring“.
- Deinstallieren löscht auch alle lokalen Testdaten.

## Testperson wechseln
Die Leiste unter der Kopfzeile („Du bist: …“) wechselt die Testperson. Das ist eine Demofunktion zum Nachspielen beider Seiten, keine Anmeldung.

## Kompletter Testablauf
1. Als Alex unter „Entdecken“ nach rechts wischen oder „Interesse“ tippen, bis Sam erscheint.
2. Zu Sam wechseln und bei Alex Interesse bekunden – jetzt entsteht das Match.
3. Unter „Matches“ den Chat öffnen und eine Nachricht schreiben.
4. Im Chat „Treffen“ tippen, Ort draußen, Datum, Uhrzeit und Trainingsform eintragen und vorschlagen.
5. Zu Alex wechseln und dem Treffen zustimmen – erst dann ist es bestätigt.
6. Ein Treffen absagen oder das Match beenden geht jederzeit; beides sehen beide Seiten.

## Freiwilligkeit
Ein bestätigtes Treffen ist keine Verpflichtung; jede Seite kann absagen oder das Match beenden.

## Zurücksetzen
Im Reiter „Profil“ stellt „Demo zurücksetzen“ nach einer Rückfrage die ursprünglichen Testdaten wieder her (alle Profile, Matches, Nachrichten und Treffen).
