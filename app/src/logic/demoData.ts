import type { AppData, Profile } from './types';

export const ARTS = ['Jiu-Jitsu', 'MMA', 'Boxen', 'Kickboxen', 'Muay Thai', 'Ringen', 'Judo'];
export const LEVELS = ['Einsteiger', 'Fortgeschritten', 'Erfahren'];
export const WEIGHT_CLASSES = ['leicht', 'mittel', 'schwer'];
export const DAYS = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
export const FORMS = ['Techniktraining', 'Drills', 'Leichtes Sparring', 'Konditionstraining'];
export const INTENSITIES = ['locker', 'mittel', 'intensiv'];

/** Acht fiktive, erwachsene Testpersonen. */
export const DEMO_PROFILES: Profile[] = [
  { id: 'p01', name: 'Alex', art: 'Jiu-Jitsu', level: 1, years: 4, age: 29, bio: 'Trainiert regelmäßig draußen und mag ein lockeres Tempo.', color: '#338CD9', weightClass: 1, days: ['Di', 'Do', 'Sa'], equipment: ['Mundschutz', 'Matte'] },
  { id: 'p02', name: 'Sam', art: 'MMA', level: 2, years: 7, age: 33, bio: 'Mag anspruchsvolle Einheiten und verschiedene Techniken.', color: '#D95940', weightClass: 2, days: ['Mo', 'Mi', 'Fr'], equipment: ['Handschuhe', 'Schienbeinschoner', 'Mundschutz'] },
  { id: 'p03', name: 'Mira', art: 'Boxen', level: 1, years: 3, age: 26, bio: 'Freut sich auf Boxstunden mit guter Aufsicht von außen.', color: '#BF4DA6', weightClass: 0, days: ['Sa', 'So'], equipment: ['Handschuhe', 'Pratzen'] },
  { id: 'p04', name: 'Jonas', art: 'Kickboxen', level: 0, years: 1, age: 22, bio: 'Neu dabei und lernt gerne die Grundlagen draußen.', color: '#4DB366', weightClass: 1, days: ['Mi', 'Sa'], equipment: [] },
  { id: 'p05', name: 'Lea', art: 'Jiu-Jitsu', level: 2, years: 9, age: 35, bio: 'Erfahrene Sportlerin mit Fokus auf Technik.', color: '#E6A633', weightClass: 0, days: ['Mo', 'Do'], equipment: ['Matte'] },
  { id: 'p06', name: 'Deniz', art: 'Muay Thai', level: 1, years: 5, age: 30, bio: 'Mag Muay-Thai-Einheiten und trainiert gerne draußen.', color: '#40A6B3', weightClass: 1, days: ['Di', 'Fr', 'So'], equipment: ['Handschuhe', 'Schienbeinschoner'] },
  { id: 'p07', name: 'Kim', art: 'Ringen', level: 0, years: 2, age: 24, bio: 'Einsteiger im Ringen mit Interesse an Bodenarbeit.', color: '#8C73D9', weightClass: 2, days: ['Sa'], equipment: ['Mundschutz', 'Matte'] },
  { id: 'p08', name: 'Tarek', art: 'Boxen', level: 2, years: 11, age: 38, bio: 'Langjähriger Boxer mit Fokus auf Kondition und Technik.', color: '#99994D', weightClass: 2, days: ['Mo', 'Di', 'Mi', 'Do', 'Fr'], equipment: ['Handschuhe', 'Mundschutz', 'Pratzen'] },
];

/** Dokumentierter Ausgangszustand: aktive Person Alex (p01), noch keine Interessen, Matches oder Nachrichten. */
export function demoData(): AppData {
  return {
    version: 1,
    activeId: 'p01',
    profiles: DEMO_PROFILES.map(p => ({ ...p, days: [...p.days], equipment: [...p.equipment] })),
    likes: [],
    passes: [],
    blocks: [],
    matches: [],
    messages: [],
    meetings: [],
    nextMatchNo: 1,
  };
}

export function profileById(data: AppData, id: string): Profile | undefined {
  return data.profiles.find(p => p.id === id);
}
