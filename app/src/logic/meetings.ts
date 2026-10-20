import type { AppData, MeetingDetails, Meeting } from './types';
import { FORMS, INTENSITIES } from './demoData';

/**
 * Gibt leere Meeting-Details zurück.
 * place, date, time, rules sind leer, form und intensity haben die Erstwerte.
 */
export function emptyDetails(): MeetingDetails {
  return {
    place: '',
    date: '',
    time: '',
    form: FORMS[0],
    intensity: INTENSITIES[0],
    rules: '',
  };
}

/**
 * Prüft, welche Pflichtfelder fehlen oder ungültig sind.
 * Gibt eine Liste der fehlenden/unzulässigen Felder zurück (sortiert in fester Reihenfolge).
 */
export function missingFields(details: MeetingDetails): string[] {
  const problems: string[] = [];

  // Ort: leer nach trim()
  if (details.place.trim() === '') {
    problems.push('Ort');
  }

  // Datum: muss TT.MM.JJJJ mit gültigem Tag (1–31) und Monat (1–12) sein
  const dateMatch = details.date.match(/^\d{2}\.\d{2}\.\d{4}$/);
  if (!dateMatch) {
    problems.push('Datum');
  } else {
    const day = parseInt(details.date.slice(0, 2), 10);
    const month = parseInt(details.date.slice(3, 5), 10);
    if (day < 1 || day > 31 || month < 1 || month > 12) {
      problems.push('Datum');
    }
  }

  // Uhrzeit: muss HH:MM mit Stunde 0–23 und Minute 0–59 sein
  const timeMatch = details.time.match(/^\d{2}:\d{2}$/);
  if (!timeMatch) {
    problems.push('Uhrzeit');
  } else {
    const hour = parseInt(details.time.slice(0, 2), 10);
    const minute = parseInt(details.time.slice(3, 5), 10);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      problems.push('Uhrzeit');
    }
  }

  // Trainingsform: muss in FORMS sein
  if (!FORMS.includes(details.form)) {
    problems.push('Trainingsform');
  }

  // Intensität: muss in INTENSITIES sein
  if (!INTENSITIES.includes(details.intensity)) {
    problems.push('Intensität');
  }

  return problems;
}

/**
 * Gibt ein Meeting für ein Match zurück oder undefined, falls keins existiert.
 */
export function meetingOf(data: AppData, matchId: string): Meeting | undefined {
  return data.meetings.find(m => m.matchId === matchId);
}

/**
 * Erstellt einen neuen Vorschlag oder aktualisiert einen bestehenden.
 * Wenn etwas fehlt, das Match nicht existiert, beendet ist oder by nicht beteiligt ist,
 * wird unverändert zurückgegeben.
 */
export function propose(
  data: AppData,
  matchId: string,
  by: string,
  details: MeetingDetails
): AppData {
  // Auf fehlende/ungültige Felder prüfen (vor trim())
  if (missingFields(details).length > 0) {
    return data;
  }

  // Match existiert?
  const match = data.matches.find(m => m.id === matchId);
  if (!match) {
    return data;
  }

  // Match beendet?
  if (match.endedBy !== '') {
    return data;
  }

  // by ist in a oder b?
  if (match.a !== by && match.b !== by) {
    return data;
  }

  // Felder säubern mit trim()
  const place = details.place.trim();
  const date = details.date.trim();
  const time = details.time.trim();
  const form = details.form.trim();
  const intensity = details.intensity.trim();
  const rules = details.rules.trim();

  // Gibt es schon einen Vorschlag für dieses Match?
  const existing = data.meetings.find(m => m.matchId === matchId);

  if (!existing) {
    // Neuen Meeting anhängen
    return {
      ...data,
      meetings: [
        ...data.meetings,
        {
          matchId,
          place,
          date,
          time,
          form,
          intensity,
          rules,
          proposedBy: by,
          approved: [by],
          cancelledBy: '',
        },
      ],
    };
  }

  // Bereits ein Vorschlag vorhanden: alle sechs Felder gleich UND nicht abgesagt?
  if (
    existing.place === place &&
    existing.date === date &&
    existing.time === time &&
    existing.form === form &&
    existing.intensity === intensity &&
    existing.rules === rules &&
    existing.cancelledBy === ''
  ) {
    // Gleicher Vorschlag → unverändert zurückgeben
    return data;
  }

  // Anderer Vorschlag: ersetzen, proposedBy aktualisieren, Zustimmung und Absage resetten
  const updatedMeeting: Meeting = {
    matchId,
    place,
    date,
    time,
    form,
    intensity,
    rules,
    proposedBy: by,
    approved: [by],
    cancelledBy: '',
  };

  return {
    ...data,
    meetings: data.meetings.map(m => (m.matchId === matchId ? updatedMeeting : m)),
  };
}
