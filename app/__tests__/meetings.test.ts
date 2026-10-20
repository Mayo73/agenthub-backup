import { describe, test, expect } from '@jest/globals';
import { demoData } from '../src/logic/demoData';
import type { AppData, MeetingDetails } from '../src/logic/types';
import { emptyDetails, missingFields, propose, meetingOf } from '../src/logic/meetings';

/** Hilfsfunktion: Demo-Daten mit einem Match hinzufügen */
function withMatch(): AppData {
  const d = demoData();
  return {
    ...d,
    matches: [
      ...d.matches,
      { id: 'm1', a: 'p01', b: 'p02', endedBy: '' },
    ],
  };
}

/** Hilfsfunktion: vollständige Details für Tests */
function details(): MeetingDetails {
  return {
    place: 'Stadtpark, große Wiese',
    date: '24.10.2026',
    time: '10:00',
    form: 'Techniktraining',
    intensity: 'locker',
    rules: 'Nur Technik, kein Vollkontakt',
  };
}

describe('meetings', () => {
  describe('missingFields', () => {
    test('vollständige Angaben', () => {
      expect(missingFields(details())).toHaveLength(0);
    });

    test('fehlende Angaben', () => {
      const result = missingFields(emptyDetails());
      expect(result).toEqual(['Ort', 'Datum', 'Uhrzeit']);
    });

    test('ungültige Werte: Datum 32.10.2026', () => {
      const d: MeetingDetails = {
        ...details(),
        date: '32.10.2026',
      };
      expect(missingFields(d)).toContain('Datum');
    });

    test('ungültige Werte: Datum 1.10.2026 (nur einstelliger Tag)', () => {
      const d: MeetingDetails = {
        ...details(),
        date: '1.10.2026',
      };
      expect(missingFields(d)).toContain('Datum');
    });

    test('ungültige Werte: Uhrzeit 24:00 (Stunde zu hoch)', () => {
      const d: MeetingDetails = {
        ...details(),
        time: '24:00',
      };
      expect(missingFields(d)).toContain('Uhrzeit');
    });

    test('ungültige Werte: Uhrzeit 9:5 (falsches Format)', () => {
      const d: MeetingDetails = {
        ...details(),
        time: '9:5',
      };
      expect(missingFields(d)).toContain('Uhrzeit');
    });

    test('ungültige Werte: Trainingsform nicht in FORMS', () => {
      const d: MeetingDetails = {
        ...details(),
        form: 'Unbekannte Form',
      };
      expect(missingFields(d)).toContain('Trainingsform');
    });

    test('ungültige Werte: Intensität nicht in INTENSITIES', () => {
      const d: MeetingDetails = {
        ...details(),
        intensity: 'unbekannt',
      };
      expect(missingFields(d)).toContain('Intensität');
    });
  });

  describe('Vorschlag anlegen', () => {
    test('approved, proposedBy, cancelledBy sind korrekt', () => {
      const result = propose(withMatch(), 'm1', 'p01', details());
      const meeting = meetingOf(result, 'm1');
      expect(meeting).toBeDefined();
      expect(meeting!.proposedBy).toBe('p01');
      expect(meeting!.approved).toEqual(['p01']);
      expect(meeting!.cancelledBy).toBe('');
    });

    test('unvollständig wird abgelehnt', () => {
      const before = withMatch();
      const result = propose(before, 'm1', 'p01', emptyDetails());
      expect(result).toBe(before);
    });
  });

  describe('Unbeteiligte und beendete Matches', () => {
    test('Vorschlag von unbeteiligter Person p03 wird abgelehnt', () => {
      const before = withMatch();
      const result = propose(before, 'm1', 'p03', details());
      expect(result).toBe(before);
    });

    test('beendetes Match (endedBy: p01) wird nicht angenommen', () => {
      const d = demoData();
      const endedMatch: AppData = {
        ...d,
        matches: [
          ...d.matches,
          { id: 'm2', a: 'p01', b: 'p02', endedBy: 'p01' },
        ],
      };
      const result = propose(endedMatch, 'm2', 'p01', details());
      expect(result).toBe(endedMatch);
    });
  });

  describe('Änderung setzt Zustimmung zurück', () => {
    test('p02 ändert time, approved wird auf [p02] gesetzt', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      const meetingAfterStep1 = meetingOf(step1, 'm1')!;

      // Kopie erstellen und approved ändern
      const dataWithApproval: AppData = {
        ...step1,
        meetings: step1.meetings.map(m =>
          m.matchId === 'm1' ? { ...m, approved: ['p01', 'p02'] } : m
        ),
      };

      const timeDifferent = { ...details(), time: '11:00' };
      const step2 = propose(dataWithApproval, 'm1', 'p02', timeDifferent);

      const meetingAfterStep2 = meetingOf(step2, 'm1')!;
      expect(meetingAfterStep2.approved).toEqual(['p02']);
      expect(meetingAfterStep2.time).toBe('11:00');
      expect(meetingAfterStep2.proposedBy).toBe('p02');
      expect(meetingAfterStep2.cancelledBy).toBe('');
      // Weiterhin nur ein Meeting
      expect(step2.meetings).toHaveLength(1);
    });
  });

  describe('gleicher Vorschlag ändert nichts', () => {
    test('zweimal derselbe Vorschlag von p01 → zweites Mal unverändert zurückgegeben', () => {
      const before = withMatch();
      const afterFirst = propose(before, 'm1', 'p01', details());

      // Zweiter Vorschlag mit exakt denselben Werten
      const afterSecond = propose(afterFirst, 'm1', 'p01', details());

      expect(afterSecond).toBe(afterFirst);
    });

    test('bestehender gültiger Vorschlag ohne Änderung bleibt gleich', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      // Nochmal derselbe Vorschlag von p01 (selbe Person)
      const step2 = propose(step1, 'm1', 'p01', details());
      expect(step2).toBe(step1);
    });

    test('bestehender Vorschlag mit anderer Uhrzeit → ersetzt, approved auf [p02]', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      const differentTime = { ...details(), time: '12:00' };
      const step2 = propose(step1, 'm1', 'p02', differentTime);

      const meeting = meetingOf(step2, 'm1')!;
      expect(meeting.time).toBe('12:00');
      expect(meeting.proposedBy).toBe('p02');
      expect(meeting.approved).toEqual(['p02']);
    });
  });
});
