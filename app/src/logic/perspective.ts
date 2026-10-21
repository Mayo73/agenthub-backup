import type { AppData, Profile } from './types';
import { profileById } from './demoData';

/**
 * Wechselt die aktive Testperson.
 * @returns unveränderte AppData bei nicht vorhandener ID
 */
export function switchPerspective(data: AppData, id: string): AppData {
  // Profil existiert -> activeId ändern
  if (profileById(data, id) !== undefined) {
    return {
      ...data,
      activeId: id,
    };
  }

  // Unverändert zurückgeben
  return data;
}

/**
 * Gibt das aktive Profil zurück.
 * @return Das Profil mit data.activeId oder das erste Profil
 */
export function activeProfile(data: AppData): Profile {
  const profil = profileById(data, data.activeId);
  if (profil !== undefined) {
    return profil;
  }
  // Fallback: erstes Profil
  return data.profiles[0];
}
