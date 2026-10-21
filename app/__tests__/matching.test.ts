import { demoData } from '../src/logic/demoData';
import {
  like,
  pass,
  matchBetween,
  hasSwiped,
  isBlocked,
  matchesOf,
  otherId,
  isActive,
  likeKey,
  candidates,
  endMatch,
  block,
} from '../src/logic/matching';

describe('matching', () => {
  test('einseitiges Interesse ergibt kein Match', () => {
    const d = like(demoData(), 'p01', 'p02');
    expect(d.likes).toEqual(['p01>p02']);
    expect(d.matches).toHaveLength(0);
  });

  test('gegenseitiges Interesse ergibt genau ein Match', () => {
    const d = demoData();
    const afterFirstLike = like(d, 'p01', 'p02');
    const afterSecondLike = like(afterFirstLike, 'p02', 'p01');

    expect(afterSecondLike.matches).toHaveLength(1);
    expect(afterSecondLike.matches[0]).toEqual({
      id: 'm1',
      a: 'p01',
      b: 'p02',
      endedBy: '',
    });
    expect(afterSecondLike.nextMatchNo).toBe(2);

    const matchesP01 = matchesOf(afterSecondLike, 'p01');
    const matchesP02 = matchesOf(afterSecondLike, 'p02');
    const matchesP03 = matchesOf(afterSecondLike, 'p03');

    expect(matchesP01).toHaveLength(1);
    expect(matchesP02).toHaveLength(1);
    expect(matchesP03).toHaveLength(0);
  });

  test('doppeltes Interesse ändert nichts', () => {
    const d = demoData();
    const afterFirstLike = like(d, 'p01', 'p02');
    const afterSecondLike = like(afterFirstLike, 'p01', 'p02');

    expect(afterSecondLike.likes).toHaveLength(1);
    expect(afterSecondLike.matches).toHaveLength(0);
  });

  test('unterschiedliche Kampfsportarten können matchen', () => {
    const d = demoData();
    // p01 macht Jiu-Jitsu, p02 macht MMA
    const afterP01LikesP02 = like(d, 'p01', 'p02');
    const afterP02LikesP01 = like(afterP01LikesP02, 'p02', 'p01');

    expect(afterP02LikesP01.matches).toHaveLength(1);
    expect(afterP02LikesP01.matches[0]).toEqual({
      id: 'm1',
      a: 'p01',
      b: 'p02',
      endedBy: '',
    });
  });

  test('überspringen verhindert späteres Interesse', () => {
    const d = demoData();
    const afterPass = pass(d, 'p01', 'p03');
    const afterLike = like(afterPass, 'p01', 'p03');

    expect(afterLike.likes).toHaveLength(0);
    expect(hasSwiped(afterLike, 'p01', 'p03')).toBe(true);
  });

  test('sich selbst geht nicht (like)', () => {
    const d = demoData();
    const result = like(d, 'p01', 'p01');
    expect(result).toBe(d);
  });

  test('sich selbst geht nicht (pass)', () => {
    const d = demoData();
    const result = pass(d, 'p01', 'p01');
    expect(result).toBe(d);
  });

  test('blockiert verhindert Interesse', () => {
    const d = demoData();
    // p02 blockiert p01
    const dWithBlock = { ...d, blocks: ['p02>p01'] };
    const result = like(dWithBlock, 'p01', 'p02');

    expect(result.likes).toHaveLength(0);
  });

  test('Original bleibt unverändert', () => {
    const d = demoData();
    const originalLikes = [...d.likes];
    const result = like(d, 'p01', 'p02');

    expect(d.likes).toEqual(originalLikes);
    expect(result.likes).toEqual(['p01>p02']);
  });

  test('otherId gibt die andere Person zurück', () => {
    const match = { id: 'm1', a: 'p01', b: 'p02', endedBy: '' };
    expect(otherId(match, 'p02')).toBe('p01');
    expect(otherId(match, 'p01')).toBe('p02');
  });

  test('isActive true für aktives Match', () => {
    const match = { id: 'm1', a: 'p01', b: 'p02', endedBy: '' };
    expect(isActive(match)).toBe(true);
  });

  test('isActive false für beendete Match', () => {
    const match = { id: 'm1', a: 'p01', b: 'p02', endedBy: 'p01' };
    expect(isActive(match)).toBe(false);
  });

  test('likeKey erzeugt korrekten Schlüssel', () => {
    expect(likeKey('p01', 'p02')).toBe('p01>p02');
    expect(likeKey('p02', 'p01')).toBe('p02>p01');
  });

  describe('candidates', () => {
    test('Kandidaten am Anfang: candidates(demoData(), \'p01\') hat 7 Profile, das erste ist p02, p01 ist nicht dabei', () => {
      const d = demoData();
      const cands = candidates(d, 'p01');
      expect(cands).toHaveLength(7);
      expect(cands[0].id).toBe('p02');
      const hasP01 = cands.some(p => p.id === 'p01');
      expect(hasP01).toBe(false);
    });

    test('bewertete fallen weg: nach like und pass hat candidates(d, \'p01\') 5 Profile, erstes p04', () => {
      const d = demoData();
      const afterLike = like(d, 'p01', 'p02');
      const afterPass = pass(afterLike, 'p01', 'p03');
      const cands = candidates(afterPass, 'p01');
      expect(cands).toHaveLength(5);
      expect(cands[0].id).toBe('p04');
    });

    test('Match fällt weg: p01→p02 und p02→p01 → p02 nicht in candidates(d, \'p01\'), p01 nicht in candidates(d, \'p02\')', () => {
      const d = demoData();
      const afterFirst = like(d, 'p01', 'p02');
      const afterSecond = like(afterFirst, 'p02', 'p01');

      const candsP01 = candidates(afterSecond, 'p01');
      const hasP02forP01 = candsP01.some(p => p.id === 'p02');
      expect(hasP02forP01).toBe(false);

      const candsP02 = candidates(afterSecond, 'p02');
      const hasP01forP02 = candsP02.some(p => p.id === 'p01');
      expect(hasP01forP02).toBe(false);
    });

    test('Blockierte erscheinen nicht: block(demoData(), \'p03\', \'p01\') → p03 nicht in candidates(d, \'p01\') und p01 nicht in candidates(d, \'p03\')', () => {
      const d = demoData();
      const withBlock = block(d, 'p03', 'p01');

      const candsP01 = candidates(withBlock, 'p01');
      const hasP03forP01 = candsP01.some(p => p.id === 'p03');
      expect(hasP03forP01).toBe(false);

      const candsP03 = candidates(withBlock, 'p03');
      const hasP01forP03 = candsP03.some(p => p.id === 'p01');
      expect(hasP01forP03).toBe(false);
    });
  });

  describe('endMatch', () => {
    test('Match beenden: nach Match → endMatch(d, \'m1\', \'p02\') → endedBy \'p02\'', () => {
      const d = demoData();
      const afterFirst = like(d, 'p01', 'p02');
      const afterSecond = like(afterFirst, 'p02', 'p01');

      expect(afterSecond.matches).toHaveLength(1);
      expect(isActive(afterSecond.matches[0])).toBe(true);

      const ended = endMatch(afterSecond, 'm1', 'p02');
      expect(ended.matches[0].endedBy).toBe('p02');
      expect(isActive(ended.matches[0])).toBe(false);
    });

    test('endMatch mit \'p03\' oder unbekannter ID gibt dasselbe Objekt zurück (toBe)', () => {
      const d = demoData();
      const afterFirst = like(d, 'p01', 'p02');
      const afterSecond = like(afterFirst, 'p02', 'p01');

      // Person ist nicht an Match beteiligt
      const samePerson = endMatch(afterSecond, 'm1', 'p03');
      expect(samePerson).toBe(afterSecond);

      // Unbekannte ID
      const sameUnknownID = endMatch(afterSecond, 'm999', 'p01');
      expect(sameUnknownID).toBe(afterSecond);
    });
  });

  describe('block', () => {
    test('Blockieren beendet das Match: nach Match → block(d, \'p01\', \'p02\') → blocks [\'p01>p02\'], Match endedBy \'p01\', isBlocked(d, \'p02\', \'p01\') wahr', () => {
      const d = demoData();
      const afterFirst = like(d, 'p01', 'p02');
      const withMatch = like(afterFirst, 'p02', 'p01');

      expect(withMatch.matches).toHaveLength(1);

      const withBlock = block(withMatch, 'p01', 'p02');
      expect(withBlock.blocks).toEqual(['p01>p02']);
      expect(withBlock.matches[0].endedBy).toBe('p01');
      expect(isBlocked(withBlock, 'p02', 'p01')).toBe(true);
    });

    test('block mit from === to gibt unverändertes Datenobjekt zurück', () => {
      const d = demoData();
      const result = block(d, 'p01', 'p01');
      expect(result).toBe(d);
    });

    test('block wenn bereits blockiert gibt unverändertes Datenobjekt zurück', () => {
      const d = { ...demoData(), blocks: ['p01>p02'] };
      const result = block(d, 'p01', 'p02');
      expect(result).toBe(d);
    });

    test('block ohne Match fügt nur Blockierung hinzu', () => {
      const d = demoData();
      const withBlock = block(d, 'p03', 'p05');
      expect(withBlock.blocks).toEqual(['p03>p05']);
      expect(withBlock.matches).toHaveLength(0);
    });
  });
});
