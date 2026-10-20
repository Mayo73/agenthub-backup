/* global jest */
// Native Module gibt es in Jest nicht: Bildschirmränder und Speicher durch Attrappen ersetzen.
jest.mock('react-native-safe-area-context', () => require('react-native-safe-area-context/jest/mock').default);
jest.mock('@react-native-async-storage/async-storage', () => require('@react-native-async-storage/async-storage/jest'));
