import React, { useEffect, useRef, useState } from 'react';
import { BackHandler, StatusBar, StyleSheet, View } from 'react-native';
import { SafeAreaProvider, useSafeAreaInsets } from 'react-native-safe-area-context';
import DemoBanner from './src/components/DemoBanner';
import TabBar from './src/components/TabBar';
import { back, current, initialNav, selectTab, type NavState } from './src/navigation';
import Placeholder from './src/screens/Placeholder';
import { colors } from './src/theme';

export function AppShell() {
  const insets = useSafeAreaInsets();
  const [nav, setNav] = useState<NavState>(initialNav());
  const navRef = useRef(nav);
  navRef.current = nav;

  useEffect(() => {
    const sub = BackHandler.addEventListener('hardwareBackPress', () => {
      const r = back(navRef.current);
      if (r.handled) {
        setNav(r.nav);
      }
      return r.handled;
    });
    return () => sub.remove();
  }, []);

  const route = current(nav);
  let screen: React.ReactNode;
  if (route) {
    screen = <Placeholder title={route.screen} />;
  } else if (nav.tab === 'entdecken') {
    screen = <Placeholder title="Entdecken" />;
  } else if (nav.tab === 'matches') {
    screen = <Placeholder title="Matches" />;
  } else {
    screen = <Placeholder title="Profil" />;
  }

  return (
    <View style={[styles.root, { paddingTop: insets.top }]}>
      <StatusBar barStyle="light-content" />
      <DemoBanner />
      <View style={styles.content}>{screen}</View>
      <TabBar tab={nav.tab} onSelect={t => setNav(selectTab(nav, t))} bottomInset={insets.bottom} />
    </View>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <AppShell />
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  content: { flex: 1 },
});
