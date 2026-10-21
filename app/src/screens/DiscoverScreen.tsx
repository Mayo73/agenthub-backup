import React, { useState } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useAppData } from '../state/AppDataContext';
import { candidates, like, matchBetween, pass } from '../logic/matching';
import type { Profile } from '../logic/types';
import MatchOverlay from '../components/MatchOverlay';
import ProfileCard from '../components/ProfileCard';
import SwipeCard from '../components/SwipeCard';
import { colors, sizes } from '../theme';

type Props = {
  onOpenChat?: (matchId: string) => void;
};

export default function DiscoverScreen({ onOpenChat }: Props) {
  const { data, update } = useAppData();
  const [matchInfo, setMatchInfo] = useState<{ id: string; other: Profile } | null>(null);
  const me = data.activeId;
  const meProfile = data.profiles.find(p => p.id === me);
  const list = candidates(data, me);
  const top = list[0];

  const handlePass = () => {
    update(d => pass(d, me, top.id));
  };

  const handleLike = () => {
    const next = like(data, me, top.id);
    update(() => next);
    const match = matchBetween(next, me, top.id);
    if (match && !matchBetween(data, me, top.id)) {
      setMatchInfo({ id: match.id, other: top });
    }
  };

  const overlay =
    matchInfo && meProfile ? (
      <MatchOverlay
        visible={true}
        me={meProfile}
        other={matchInfo.other}
        onChat={() => {
          setMatchInfo(null);
          onOpenChat?.(matchInfo.id);
        }}
        onClose={() => setMatchInfo(null)}
      />
    ) : null;

  if (!top) {
    return (
      <View style={styles.emptyContainer} testID="discover-empty">
        <Text style={styles.emptyTitle}>Keine weiteren Testprofile</Text>
        <Text style={styles.emptySubtitle}>
          Wechsle im Profil die Demo-Perspektive, um die andere Seite eines Matches zu sehen.
        </Text>
        {overlay}
      </View>
    );
  }

  return (
    <View style={styles.container} testID="discover-container">
      <Text testID="discover-me" style={[styles.meLabel, { color: colors.demo }]}>
        Du bist: {meProfile?.name || 'Unbekannt'} (Demo)
      </Text>
      <SwipeCard key={top.id} onLike={handleLike} onPass={handlePass}>
        <ProfileCard profile={top} />
      </SwipeCard>
      <View style={styles.buttonRow}>
        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={[styles.roundButton, { borderColor: colors.pass }]}
            onPress={handlePass}
            testID="btn-pass"
            accessibilityLabel="Überspringen"
          >
            <Text style={{ color: colors.pass, fontSize: sizes.normal }}>✕</Text>
          </TouchableOpacity>
          <Text style={styles.buttonLabel}>Überspringen</Text>
        </View>
        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={[styles.roundButton, { borderColor: colors.like }]}
            onPress={handleLike}
            testID="btn-like"
            accessibilityLabel="Interesse"
          >
            <Text style={{ color: colors.like, fontSize: sizes.normal }}>♥</Text>
          </TouchableOpacity>
          <Text style={styles.buttonLabel}>Interesse</Text>
        </View>
      </View>
      {overlay}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: sizes.gap,
  },
  meLabel: {
    fontSize: sizes.small,
    textAlign: 'center',
    marginBottom: sizes.gap,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: sizes.gap * 2,
  },
  emptyTitle: {
    fontSize: sizes.title,
    fontWeight: '600',
    color: colors.text,
    marginBottom: sizes.gap,
  },
  emptySubtitle: {
    fontSize: sizes.normal,
    color: colors.muted,
    textAlign: 'center',
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: sizes.gap * 3,
    marginTop: sizes.gap,
  },
  buttonContainer: {
    alignItems: 'center',
    marginVertical: sizes.gap / 2,
  },
  roundButton: {
    width: sizes.roundButton,
    height: sizes.roundButton,
    borderRadius: sizes.roundButton / 2,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: sizes.small,
  },
  buttonLabel: {
    fontSize: sizes.small,
    color: colors.muted,
  },
});
