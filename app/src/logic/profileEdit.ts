import type { AppData, Profile } from './types';
import { ARTS } from './demoData';

/**
 * Prüft ein Profil auf gültige Angaben.
 * @returns Array mit Fehlermeldungen in spezifischer Reihenfolge.
 */
export function validateProfile(p: Profile): string[] {
  const messages: string[] = [];

  // Name muss 2 bis 20 Zeichen haben
  if (p.name.trim().length < 2 || p.name.trim().length > 20) {
    messages.push('Name muss 2 bis 20 Zeichen haben');
  }

  // Alter muss zwischen 18 und 99 liegen (ganze Zahl)
  if (!Number.isInteger(p.age) || p.age < 18 || p.age > 99) {
    messages.push('Alter muss zwischen 18 und 99 liegen');
  }

  // Trainingsjahre müssen zwischen 0 und 60 liegen (ganze Zahl)
  if (!Number.isInteger(p.years) || p.years < 0 || p.years > 60) {
    messages.push('Trainingsjahre müssen zwischen 0 und 60 liegen');
  }

  // Bitte eine Kampfsportart wählen (muss in ARTS sein)
  if (!ARTS.includes(p.art)) {
    messages.push('Bitte eine Kampfsportart wählen');
  }

  // Beschreibung höchstens 200 Zeichen
  if (p.bio.length > 200) {
    messages.push('Beschreibung höchstens 200 Zeichen');
  }

  return messages;
}

/**
 * Ändert ein Profil in den AppData.
 * @returns unveränderte AppData bei nicht gefundener ID oder wenn Validierung fehlschlägt
 */
export function updateProfile(
  data: AppData,
  id: string,
  changes: Partial<Omit<Profile, 'id'>>
): AppData {
  const profil = data.profiles.find(p => p.id === id);

  // Profil nicht gefunden -> unverändert zurückgeben
  if (!profil) {
    return data;
  }

  // Änderungen vorbereiten (name wird getrimmt)
  const updatedProfile: Profile = {
    ...profil,
    ...changes,
    name: changes.name?.trim() ?? profil.name,
  };

  // Validierung läuft – bei Fehlern unverändert zurückgeben
  const messages = validateProfile(updatedProfile);
  if (messages.length > 0) {
    return data;
  }

  // Profil ersetzen (Reihenfolge bleibt erhalten)
  const updatedProfiles = data.profiles.map(p =>
    p.id === id ? updatedProfile : p
  );

  return {
    ...data,
    profiles: updatedProfiles,
  };
}
