import React, { useRef } from 'react';
import { Animated, PanResponder, StyleSheet, Text } from 'react-native';
import { swipeDecision } from '../logic/swipe';
import { colors, sizes } from '../theme';

type Props = {
  children: React.ReactNode;
  onLike: () => void;
  onPass: () => void;
};

/** Karte, die dem Finger folgt: nach rechts gewischt Interesse, nach links Überspringen. */
export default function SwipeCard({ children, onLike, onPass }: Props) {
  const pan = useRef(new Animated.ValueXY()).current;
  // Aktuelle Handler über Refs, weil der PanResponder nur einmal angelegt wird.
  const handlers = useRef({ onLike, onPass });
  handlers.current = { onLike, onPass };

  const flyOut = (toX: number, done: () => void): void => {
    Animated.timing(pan, { toValue: { x: toX, y: 0 }, duration: 200, useNativeDriver: false }).start(() => {
      done();
      pan.setValue({ x: 0, y: 0 });
    });
  };

  const responder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (_e, g) => Math.abs(g.dx) > 10 && Math.abs(g.dx) > Math.abs(g.dy),
      onPanResponderMove: (_e, g) => pan.setValue({ x: g.dx, y: g.dy }),
      onPanResponderRelease: (_e, g) => {
        const decision = swipeDecision(g.dx, g.vx);
        if (decision === 'like') {
          flyOut(500, () => handlers.current.onLike());
        } else if (decision === 'pass') {
          flyOut(-500, () => handlers.current.onPass());
        } else {
          Animated.spring(pan, { toValue: { x: 0, y: 0 }, useNativeDriver: false }).start();
        }
      },
      onPanResponderTerminate: () => {
        Animated.spring(pan, { toValue: { x: 0, y: 0 }, useNativeDriver: false }).start();
      },
    }),
  ).current;

  const rotate = pan.x.interpolate({
    inputRange: [-200, 0, 200],
    outputRange: ['-12deg', '0deg', '12deg'],
    extrapolate: 'clamp',
  });
  const likeOpacity = pan.x.interpolate({ inputRange: [40, 120], outputRange: [0, 1], extrapolate: 'clamp' });
  const passOpacity = pan.x.interpolate({ inputRange: [-120, -40], outputRange: [1, 0], extrapolate: 'clamp' });

  return (
    <Animated.View
      testID="swipe-card"
      style={[styles.card, { transform: [{ translateX: pan.x }, { translateY: pan.y }, { rotate }] }]}
      {...responder.panHandlers}>
      {children}
      <Animated.View style={[styles.stamp, styles.stampLike, { opacity: likeOpacity }]} pointerEvents="none">
        <Text style={[styles.stampText, { color: colors.like }]}>INTERESSE</Text>
      </Animated.View>
      <Animated.View style={[styles.stamp, styles.stampPass, { opacity: passOpacity }]} pointerEvents="none">
        <Text style={[styles.stampText, { color: colors.pass }]}>WEITER</Text>
      </Animated.View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  card: {
    width: '100%',
  },
  stamp: {
    position: 'absolute',
    top: sizes.gap * 2,
    paddingVertical: 4,
    paddingHorizontal: sizes.gap,
    borderWidth: 3,
    borderRadius: sizes.radius / 2,
  },
  stampLike: {
    left: sizes.gap * 2,
    borderColor: colors.like,
    transform: [{ rotate: '-12deg' }],
  },
  stampPass: {
    right: sizes.gap * 2,
    borderColor: colors.pass,
    transform: [{ rotate: '12deg' }],
  },
  stampText: {
    fontSize: sizes.title,
    fontWeight: '800',
  },
});
