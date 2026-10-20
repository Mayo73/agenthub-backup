import { describe, test, expect } from '@jest/globals';
import type { AppData } from '../src/logic/types';
import { demoData, ARTS } from '../src/logic/demoData';
import { validateProfile, updateProfile } from '../src/logic/profileEdit';
import { switchPerspective, activeProfile } from '../src/logic/perspective';

describe('profileEdit', () => {
  test('gültiges Demoprofil', () => {
    const d: AppData = demoData();
    const messages = validateProfile(d.profiles[0]);
    expect(messages).toEqual([]);
  });

  test('ungültige Angaben', () => {
    const d: AppData = demoData();
    // Name 'A' (zu kurz), Alter 17 (unter 18), Jahre 61 (über 60), Kampfsportart 'Fechten' (nicht in ARTS),
    // Beschreibung mit 201 Zeichen
    const invalidProfile = {
      ...d.profiles[0],
      name: 'A',
      age: 17,
      years: 61,
      art: 'Fechten',
      bio: 'a'.repeat(201),
    };
    const messages = validateProfile(invalidProfile);
    expect(messages).toEqual([
      'Name muss 2 bis 20 Zeichen haben',
      'Alter muss zwischen 18 und 99 liegen',
      'Trainingsjahre müssen zwischen 0 und 60 liegen',
      'Bitte eine Kampfsportart wählen',
      'Beschreibung höchstens 200 Zeichen',
    ]);
  });

  test('Profil ändern', () => {
    const d: AppData = demoData();
    const updated = updateProfile(d, 'p01', { name: '  Alexa ', years: 5 });
    expect(updated.profiles[0].name).toBe('Alexa');
    expect(updated.profiles[0].years).toBe(5);
    expect(updated.profiles[0].id).toBe('p01');
    // Andere Profile unverändert
    expect(updated.profiles[1].name).toBe(d.profiles[1].name);
  });

  test('ungültige Änderung wird abgelehnt', () => {
    const d: AppData = demoData();
    const original = d.profiles[0];
    const updated = updateProfile(d, 'p01', { age: 12 });
    // Bei ungültiger Änderung (Alter 12 < 18) wird unveränderte AppData zurückgegeben
    expect(updated.profiles[0]).toBe(original);
    expect(updated).toBe(d);
  });

  test('unbekannte ID', () => {
    const d: AppData = demoData();
    const original = d;
    const updated = updateProfile(d, 'p99', { years: 2 });
    // Bei nicht gefundener ID wird unveränderte AppData zurückgegeben
    expect(updated).toBe(original);
  });
});

describe('perspective', () => {
  test('Perspektive wechseln', () => {
    const d: AppData = demoData();
    const switched = switchPerspective(d, 'p02');
    expect(switched.activeId).toBe('p02');
    // activeProfile davon ist Sam
    expect(activeProfile(switched).name).toBe('Sam');
  });

  test('unbekannte ID bei Perspektive wechseln', () => {
    const d: AppData = demoData();
    const original = d;
    const switched = switchPerspective(d, 'p99');
    // Bei nicht gefundener ID wird unveränderte AppData zurückgegeben
    expect(switched).toBe(original);
  });
});
