const path = require('path');
const fs = require('fs');
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

// node_modules ist eine Verknüpfung nach AgentHub\envs\sparring\node_modules.
// Metro folgt ihr nicht von selbst: echten Ordner beobachten und dort Pakete suchen.
const modules = fs.realpathSync(path.join(__dirname, 'node_modules'));

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const config = {
  watchFolders: [modules],
  resolver: { nodeModulesPaths: [modules] },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
