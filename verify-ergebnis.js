// Wertet den Jest-Lauf aus (verify.cmd) und gibt genau eine Ergebniszeile aus.
// Aufruf: node verify-ergebnis.js <jest.json> <Exit-Code der Typpruefung>
'use strict';
const fs = require('fs');
const path = require('path');

const [, , jsonFile, tscCode] = process.argv;
let report;
try {
  report = JSON.parse(fs.readFileSync(jsonFile, 'utf8'));
} catch (e) {
  console.log('== Kein Jest-Ergebnis gefunden: Der Testlauf ist nicht bis zum Ende gekommen ==');
  process.exit(1);
}

let ok = 0;
let failed = 0;
for (const suite of report.testResults) {
  const file = path.basename(suite.name);
  if (suite.status === 'failed' && suite.assertionResults.length === 0) {
    failed += 1;
    console.log(`  FEHLER  ${file}: Testdatei konnte nicht ausgefuehrt werden`);
    console.log(String(suite.message || '').split('\n').slice(0, 15).join('\n'));
    continue;
  }
  for (const t of suite.assertionResults) {
    const name = `${file}::${t.fullName}`;
    if (t.status === 'passed') {
      ok += 1;
      console.log(`  OK      ${name}`);
    } else if (t.status === 'failed') {
      failed += 1;
      console.log(`  FEHLER  ${name}`);
      for (const m of t.failureMessages || []) {
        console.log(String(m).split('\n').slice(0, 12).join('\n'));
      }
    } else {
      // uebersprungene Tests (skip, todo) zaehlen als Fehler: Tests nicht abschalten
      failed += 1;
      console.log(`  FEHLER  ${name}: uebersprungen (${t.status})`);
    }
  }
}
if (tscCode !== '0') {
  failed += 1;
  console.log('  FEHLER  Typpruefung (tsc): siehe Meldungen oben');
}
console.log(`ERGEBNIS: ${ok} ok, ${failed} fehlgeschlagen`);
process.exit(failed === 0 && ok > 0 ? 0 : 1);
