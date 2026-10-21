import { describe, test, expect } from '@jest/globals';
import { demoData } from '../src/logic/demoData';
import type { AppData, MeetingDetails } from '../src/logic/types';
import { emptyDetails, missingFields, propose, meetingOf, approve, isConfirmed, cancel, meetingStatus } from '../src/logic/meetings';

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

  describe('approve – Zustimmungslogik', () => {
    test('erst nach beiden Zustimmungen bestätigt', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      expect(isConfirmed(step1, 'm1')).toBe(false);

      const step2 = approve(step1, 'm1', 'p02');
      expect(isConfirmed(step2, 'm1')).toBe(true);
    });

    test('Unbeteiligte: approve von p03 gibt dasselbe Objekt zurück', () => {
      const before = withMatch();
      const result = approve(before, 'm1', 'p03');
      expect(result).toBe(before);
    });

    test('nach Absage: approve gibt dasselbe Objekt zurück (unverändert)', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      const cancelled = cancel(step1, 'm1', 'p02');
      const result = approve(cancelled, 'm1', 'p01');
      expect(result).toBe(cancelled);
    });
  });

  describe('meetingStatus – Status aus verschiedenen Perspektiven', () => {
    test('Status nach Vorschlag von p01: für p01 und p02 unterschiedlich', () => {
      const afterProposal = propose(withMatch(), 'm1', 'p01', details());

      const statusP01 = meetingStatus(afterProposal, 'm1', 'p01');
      expect(statusP01).toBe('Wartet auf Zustimmung von Sam');

      const statusP02 = meetingStatus(afterProposal, 'm1', 'p02');
      expect(statusP02).toBe('Wartet auf deine Zustimmung');
    });

    test('Status nach beiden Zustimmungen: beide sehen Bestätigt', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      const step2 = approve(step1, 'm1', 'p02');

      const statusP01 = meetingStatus(step2, 'm1', 'p01');
      expect(statusP01).toBe('Bestätigt von beiden');

      const statusP02 = meetingStatus(step2, 'm1', 'p02');
      expect(statusP02).toBe('Bestätigt von beiden');
    });

    test('Status ohne Vorschlag: "Noch kein Vorschlag"', () => {
      const result = meetingStatus(withMatch(), 'm1', 'p01');
      expect(result).toBe('Noch kein Vorschlag');
    });
  });

  describe('Änderung nach Bestätigung', () => {
    test('bestätigt, dann neuer Vorschlag von p02 → nicht mehr bestätigt', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      const confirmed = approve(step1, 'm1', 'p02');

      expect(isConfirmed(confirmed, 'm1')).toBe(true);

      // p02 schlägt neuen Ort vor
      const newDetails = { ...details(), place: 'Stadtpark, kleine Wiese' };
      const changed = propose(confirmed, 'm1', 'p02', newDetails);

      expect(isConfirmed(changed, 'm1')).toBe(false);

      // p01 wartet auf neue Zustimmung von p02
      const statusP01 = meetingStatus(changed, 'm1', 'p01');
      expect(statusP01).toBe('Wartet auf deine Zustimmung');
    });
  });

  describe('cancel – Absagelogik', () => {
    test('Absage nach Bestätigung: isConfirmed falsch, Status korrekt', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      const confirmed = approve(step1, 'm1', 'p02');

      expect(isConfirmed(confirmed, 'm1')).toBe(true);

      // p02 sagt ab
      const cancelled = cancel(confirmed, 'm1', 'p02');

      expect(isConfirmed(cancelled, 'm1')).toBe(false);

      const statusP01 = meetingStatus(cancelled, 'm1', 'p01');
      expect(statusP01).toBe('Abgesagt von Sam');

      const statusP02 = meetingStatus(cancelled, 'm1', 'p02');
      expect(statusP02).toBe('Von dir abgesagt');
    });

    test('Unbeteiligte: cancel von p03 gibt dasselbe Objekt zurück', () => {
      const before = withMatch();
      const result = cancel(before, 'm1', 'p03');
      expect(result).toBe(before);
    });
  });

  describe('neuer Vorschlag nach Absage', () => {
    test('cancel gefolgt von propose: cancelledBy wird leer, approved nur Vorschlagende', () => {
      const step1 = propose(withMatch(), 'm1', 'p01', details());
      const confirmed = approve(step1, 'm1', 'p02');

      // p02 sagt ab
      const cancelled = cancel(confirmed, 'm1', 'p02');

      // p01 schlägt neuen Vorschlag vor
      const newDetails = { ...details(), place: 'Neuer Ort' };
      const afterProposal = propose(cancelled, 'm1', 'p01', newDetails);

      const meeting = meetingOf(afterProposal, 'm1')!;
      expect(meeting.cancelledBy).toBe('');
      expect(meeting.approved).toEqual(['p01']);
    });
  });
});
