import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { colors, sizes } from '../theme';

/** Kopfzeile: kennzeichnet die App dauerhaft als Prototyp mit Testprofilen. */
export default function DemoBanner() {
  return (
    <View style={styles.banner} testID="demo-banner">
      <Text style={styles.text}>Prototyp · nur fiktive Testprofile</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  banner: { backgroundColor: colors.demo, paddingVertical: 4, alignItems: 'center' },
  text: { color: colors.bg, fontSize: sizes.small, fontWeight: '600' },
});
