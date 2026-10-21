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
});
