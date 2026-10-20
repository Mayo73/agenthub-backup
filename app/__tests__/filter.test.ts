import type { Filter, Profile } from '../src/logic/types';
import {
  DEMO_PROFILES,
  LEVELS,
} from '../src/logic/demoData';
import {
  emptyFilter,
  applyFilter,
  isFilterActive,
  toggle,
  describeFilter,
} from '../src/logic/filter';

describe('leerer Filter zeigt alle', () => {
  const f: Filter = emptyFilter();

  test('emptyFilter returns filter with empty lists', () => {
    expect(f).toEqual({ arts: [], levels: [] });
  });

  test('isFilterActive is false for empty filter', () => {
    expect(isFilterActive(f)).toBe(false);
  });

  test('describeFilter returns empty string for empty filter', () => {
    expect(describeFilter(f)).toBe('');
  });

  test('applyFilter with empty filter shows all 8 profiles', () => {
    const result = applyFilter(DEMO_PROFILES, f);
    expect(result).toHaveLength(8);
    expect(result).toEqual(DEMO_PROFILES);
  });
});

describe('nach Kampfsportart', () => {
  test('arts: [\'Boxen\'] returns Mira and Tarek', () => {
    const f: Filter = { arts: ['Boxen'], levels: [] };
    const result = applyFilter(DEMO_PROFILES, f);
    expect(result.map((p) => p.name)).toEqual(['Mira', 'Tarek']);
  });
});

describe('nach Erfahrung', () => {
  test('levels: [2] returns Sam, Lea, Tarek', () => {
    const f: Filter = { arts: [], levels: [2] };
    const result = applyFilter(DEMO_PROFILES, f);
    expect(result.map((p) => p.name)).toEqual(['Sam', 'Lea', 'Tarek']);
  });
});

describe('beides', () => {
  test('arts: [\'Jiu-Jitsu\'], levels: [2] returns only Lea', () => {
    const f: Filter = { arts: ['Jiu-Jitsu'], levels: [2] };
    const result = applyFilter(DEMO_PROFILES, f);
    expect(result.map((p) => p.name)).toEqual(['Lea']);
  });
});

describe('toggle', () => {
  test('toggle(["a"], "b") returns ["a", "b"]', () => {
    const list = ['a'];
    const result = toggle(list, 'b');
    expect(result).toEqual(['a', 'b']);
    expect(list).toEqual(['a']); // Input unchanged
  });

  test('toggle(["a", "b"], "a") returns ["b"]', () => {
    const list = ['a', 'b'];
    const result = toggle(list, 'a');
    expect(result).toEqual(['b']);
    expect(list).toEqual(['a', 'b']); // Input unchanged
  });

  test('toggle leaves input list unchanged in all cases', () => {
    const list: string[] = ['x', 'y'];
    toggle(list, 'z');
    toggle(list, 'x');
    expect(list).toEqual(['x', 'y']);
  });
});

describe('Beschreibung', () => {
  test('example from ticket: arts: [\'Jiu-Jitsu\', \'MMA\'], levels: [0] returns \'Jiu-Jitsu, MMA · Einsteiger\'', () => {
    const f: Filter = { arts: ['Jiu-Jitsu', 'MMA'], levels: [0] };
    expect(describeFilter(f)).toBe('Jiu-Jitsu, MMA · Einsteiger');
  });

  test('{ arts: [], levels: [1, 2] } returns \'Fortgeschritten, Erfahren\'', () => {
    const f: Filter = { arts: [], levels: [1, 2] };
    expect(describeFilter(f)).toBe('Fortgeschritten, Erfahren');
  });

  test('only arts: arts: [\'Boxen\'] returns \'Boxen\'', () => {
    const f: Filter = { arts: ['Boxen'], levels: [] };
    expect(describeFilter(f)).toBe('Boxen');
  });

  test('only levels: arts: [], levels: [0, 1] returns \'Einsteiger, Fortgeschritten\'', () => {
    const f: Filter = { arts: [], levels: [0, 1] };
    expect(describeFilter(f)).toBe('Einsteiger, Fortgeschritten');
  });
});
