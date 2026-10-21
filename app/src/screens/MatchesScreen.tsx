import React from 'react';
import { View, Text, FlatList, Pressable, StyleSheet } from 'react-native';
import Avatar from '../components/Avatar';
import type { Profile } from '../logic/types';
import { matchesOf } from '../logic/matching';
import { lastMessage } from '../logic/chat';
import { useAppData } from '../state/AppDataContext';
import { colors, sizes } from '../theme';

type Props = {
  onOpenChat: (matchId: string) => void;
};

function renderMatchRow(m: { id: string; a: string; b: string; endedBy: string }, data: any, activeId: string, onOpenChat: (matchId: string) => void): React.ReactNode {
  const otherId = m.a === activeId ? m.b : m.a;
  const profile = data.profiles.find((p: Profile) => p.id === otherId);
  if (!profile) {
    return null;
  }

  const msg = lastMessage(data, m.id);
  const lastMsgText = msg ? msg.text : '';

  return (
    <Pressable
      style={styles.matchRow}
      testID={`match-row-${m.id}`}
      onPress={() => onOpenChat(m.id)}
      key={m.id}>
      <Avatar profile={profile} size={48} />
      <View style={styles.textContainer}>
        <Text
          style={styles.rowTop}
          testID={`match-name-${m.id}`}>
          {profile.name} — {profile.art}
        </Text>
        <Text
          numberOfLines={1}
          style={[styles.lastMessage, m.endedBy !== '' && styles.ended]}>
          {lastMsgText || 'Noch keine Nachrichten'}
        </Text>
      </View>
      {m.endedBy !== '' && (
        <View style={[styles.badge, { backgroundColor: colors.pass }]}>
          <Text style={styles.badgeText}>Beendet</Text>
        </View>
      )}
    </Pressable>
  );
}

export default function MatchesScreen({ onOpenChat }: Props) {
  const { data } = useAppData();

  const matches = matchesOf(data, data.activeId);
  const hasMatches = matches.length > 0;

  return (
    <View style={styles.container}>
      <Text style={[styles.title, { fontSize: sizes.title }]}>Deine Matches</Text>
      {!hasMatches ? (
        <View testID="matches-empty">
          <Text>Noch keine Matches</Text>
          <Text>Bekunde unter Entdecken Interesse. Ein Match entsteht erst, wenn beide Interesse haben.</Text>
        </View>
      ) : (
        <FlatList
          data={matches}
          renderItem={({ item: m }) => renderMatchRow(m, data, data.activeId, onOpenChat)}
          keyExtractor={(m) => m.id}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: sizes.gap },
  title: { color: colors.text, fontWeight: '700', marginBottom: sizes.gap },
  matchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.card,
    borderRadius: sizes.radius,
    paddingVertical: sizes.gap,
    minHeight: sizes.button,
    marginBottom: sizes.gap,
  },
  textContainer: { flex: 1, marginLeft: sizes.gap },
  rowTop: { color: colors.text, fontWeight: '600' },
  lastMessage: { color: colors.muted, fontSize: sizes.small, marginTop: 4 },
  ended: { fontWeight: '700', color: colors.pass },
  badge: { paddingHorizontal: 8, paddingVertical: 4, borderRadius: sizes.radius, marginLeft: 'auto' },
  badgeText: { color: colors.text, fontSize: sizes.small, fontWeight: '600' },
});
