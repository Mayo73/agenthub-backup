// Datenmodell der Sparring-App. Alle Daten sind fiktive, lokale Testdaten.

/** 0 Einsteiger, 1 Fortgeschritten, 2 Erfahren */
export type Level = 0 | 1 | 2;

/** 0 leicht, 1 mittel, 2 schwer */
export type WeightClass = 0 | 1 | 2;

export type Profile = {
  id: string; // "p01" … "p08"
  name: string;
  art: string; // Kampfsportart, eine aus ARTS
  level: Level;
  years: number; // Trainingsjahre
  age: number; // mindestens 18
  bio: string;
  color: string; // Avatarfarbe, z. B. "#3B82F6"
  weightClass: WeightClass;
  days: string[]; // Trainingstage, z. B. ["Di", "Do"]
  equipment: string[];
};

export type Match = {
  id: string; // "m1", "m2", …
  a: string; // Profil-ID
  b: string; // Profil-ID
  endedBy: string; // "" solange aktiv, sonst die ID der Person, die beendet hat
};

export type Message = {
  n: number; // fortlaufende Nummer, beginnt bei 1
  matchId: string;
  from: string; // Profil-ID
  text: string;
};

export type Meeting = {
  matchId: string;
  place: string; // Outdoor-Ort als Text
  date: string; // "TT.MM.JJJJ"
  time: string; // "HH:MM"
  form: string; // eine aus FORMS
  intensity: string; // eine aus INTENSITIES
  rules: string; // gemeinsam vereinbarte Regeln, darf leer sein
  proposedBy: string; // Profil-ID
  approved: string[]; // Profil-IDs, die zugestimmt haben
  cancelledBy: string; // "" oder Profil-ID
};

export type AppData = {
  version: 1;
  activeId: string; // aktive Testperson (Demo-Perspektivwechsel)
  profiles: Profile[];
  likes: string[]; // Schlüssel "von>an", z. B. "p01>p02"
  passes: string[]; // Schlüssel "von>an"
  blocks: string[]; // Schlüssel "von>an"
  matches: Match[];
  messages: Message[];
  meetings: Meeting[];
  nextMatchNo: number; // nächste Match-Nummer, beginnt bei 1
};
