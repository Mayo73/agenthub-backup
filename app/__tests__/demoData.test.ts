import { ARTS, DEMO_PROFILES, demoData, profileById } from '../src/logic/demoData';

describe('demoData', () => {
  test('acht erwachsene Testprofile mit eindeutigen IDs', () => {
    expect(DEMO_PROFILES).toHaveLength(8);
    expect(new Set(DEMO_PROFILES.map(p => p.id)).size).toBe(8);
    DEMO_PROFILES.forEach(p => expect(p.age).toBeGreaterThanOrEqual(18));
  });

  test('Jiu-Jitsu, MMA und Boxen sind vertreten', () => {
    const arts = DEMO_PROFILES.map(p => p.art);
    ['Jiu-Jitsu', 'MMA', 'Boxen'].forEach(a => expect(arts).toContain(a));
    arts.forEach(a => expect(ARTS).toContain(a));
  });

  test('Ausgangszustand ist leer und Alex ist aktiv', () => {
    const d = demoData();
    expect(d.activeId).toBe('p01');
    expect(d.likes).toEqual([]);
    expect(d.matches).toEqual([]);
    expect(d.messages).toEqual([]);
    expect(d.meetings).toEqual([]);
    expect(d.nextMatchNo).toBe(1);
  });

  test('demoData liefert eine unabhängige Kopie', () => {
    const d = demoData();
    d.profiles[0].days.push('So');
    d.profiles[0].name = 'Geändert';
    expect(demoData().profiles[0].name).toBe('Alex');
    expect(DEMO_PROFILES[0].days).toEqual(['Di', 'Do', 'Sa']);
  });

  test('profileById findet Profile', () => {
    expect(profileById(demoData(), 'p02')?.name).toBe('Sam');
    expect(profileById(demoData(), 'x')).toBeUndefined();
  });
});
