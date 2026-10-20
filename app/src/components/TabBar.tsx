import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { TABS, type Tab } from '../navigation';
import { colors, sizes } from '../theme';

type Props = { tab: Tab; onSelect: (tab: Tab) => void; bottomInset: number };

/** Reiterleiste unten; testID je Reiter: "tab-entdecken", "tab-matches", "tab-profil". */
export default function TabBar({ tab, onSelect, bottomInset }: Props) {
  return (
    <View style={[styles.bar, { paddingBottom: bottomInset }]}>
      {TABS.map(t => {
        const active = t.tab === tab;
        return (
          <Pressable
            key={t.tab}
            testID={`tab-${t.tab}`}
            accessibilityRole="tab"
            accessibilityState={{ selected: active }}
            onPress={() => onSelect(t.tab)}
            style={styles.item}>
            <Text style={[styles.label, active && styles.active]}>{t.label}</Text>
            <View style={[styles.marker, active && styles.markerActive]} />
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  bar: { flexDirection: 'row', backgroundColor: colors.card },
  item: { flex: 1, minHeight: sizes.button, alignItems: 'center', justifyContent: 'center' },
  label: { color: colors.muted, fontSize: sizes.normal },
  active: { color: colors.text, fontWeight: '700' },
  marker: { height: 3, width: 32, marginTop: 4, borderRadius: 2, backgroundColor: 'transparent' },
  markerActive: { backgroundColor: colors.accent },
});
