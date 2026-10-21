/** Mindestweg in Pixeln, ab dem ein Wischen als Entscheidung zählt. */
export const SWIPE_DISTANCE = 120;

export type SwipeDecision = 'like' | 'pass' | null;

/** Entscheidet beim Loslassen nach Weg `dx` und Tempo `vx`: rechts Interesse, links Überspringen. */
export function swipeDecision(dx: number, vx: number): SwipeDecision {
  if (dx >= SWIPE_DISTANCE || (dx > 40 && vx >= 0.8)) {
    return 'like';
  }
  if (dx <= -SWIPE_DISTANCE || (dx < -40 && vx <= -0.8)) {
    return 'pass';
  }
  return null;
}
