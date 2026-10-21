module.exports = {
  preset: '@react-native/jest-preset',
  setupFiles: ['<rootDir>/jest.setup.js'],
  // Pakete, die nur als ES-Module ausgeliefert werden, muss Babel mit uebersetzen (node_modules ist eine Verknuepfung nach envs\sparring)
  transformIgnorePatterns: ['node_modules[\\\\/](?!((jest-)?react-native|@react-native(-community)?|@react-native-async-storage)[\\\\/])'],
  testMatch: ['<rootDir>/__tests__/**/*.test.ts', '<rootDir>/__tests__/**/*.test.tsx'],
};
