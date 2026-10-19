// Read/execute existing public shares and edit only local copies for controls.
// This script never creates or overwrites a remote share or GitHub issue.
import assert from 'node:assert/strict';
import { readFile, writeFile } from 'node:fs/promises';
import { chromium } from 'playwright';
const records = JSON.parse(await readFile(new URL('hosted.json', import.meta.url)));
const browser = await chromium.launch({
  headless: true, args: ['--no-sandbox'],
  ...(process.env.CHROMIUM_PATH ? { executablePath: process.env.CHROMIUM_PATH } : {})
});
const rows = [];
try {
  for (const record of records) {
    const context = await browser.newContext();
    const page = await context.newPage();
    const errors = [];
    let step = 'initial';
    page.on('pageerror', error => errors.push({ step, message: error.message }));
    // This is the site's ordinary Continue form, not a CAPTCHA.
    await page.goto('https://s.olid.uk/human-verification', { waitUntil: 'domcontentloaded' });
    await page.getByRole('button', { name: 'Continue to s.olid.uk', exact: true }).click();
    await page.waitForLoadState('domcontentloaded');
    await page.goto(record.url, { waitUntil: 'domcontentloaded' });
    const source = await readFile(new URL(record.name + '.tsx', import.meta.url), 'utf8');
    await page.waitForFunction(source => window.monaco?.editor.getModels().some(m => m.uri.path === '/main.tsx' && m.getValue() === source), source);
    const stored = await page.evaluate(async key => {
      const response = await fetch(`/api/storage/playgrounds/solidjs-repl/${key}`);
      if (!response.ok) throw new Error('Stored share not readable: ' + response.status);
      return response.json();
    }, record.storageKey);
    assert.equal(stored.state.files['main.tsx'], source);
    assert.equal(stored.state.solidVersion, 'mizulu/solid2@d2ad8b28');
    assert.equal(stored.state.devMode, true);
    assert.equal(stored.state.ssrEnabled, false);
    assert.equal(stored.state.tailwindEnabled, false);
    assert.ok(stored.state.prebuiltBundleCode);
    for (const url of Object.values(JSON.parse(stored.state.importMap).imports)) assert.ok(url.includes('@d2ad8b28'));
    const frame = page.frameLocator('iframe');
    const paragraph = frame.locator('p');
    async function build(changed = false) {
      // Rebuilding identical saved output may reuse the existing iframe. A
      // control changes the code and must navigate to a fresh document.
      const navigation = changed ? page.waitForEvent('framenavigated', { predicate: f => !!f.parentFrame(), timeout: 45000 }) : null;
      await page.getByRole('button', { name: 'Build', exact: true }).click();
      if (navigation) await navigation;
      await page.getByText('Compiling…', { exact: true }).waitFor({ state: 'hidden', timeout: 45000 });
      await paragraph.waitFor({ timeout: 45000 });
    }
    await build();
    const states = [{ step, text: await paragraph.innerText() }];
    assert.deepEqual(errors, []);
    async function clicks(into) {
      for (const label of ['1. Start update', '2. Recover', '3. Finish request']) {
        step = label;
        await frame.getByRole('button', { name: label, exact: true }).click();
        await page.waitForTimeout(100);
        into.push({ step, text: await paragraph.innerText() });
        if (label !== '3. Finish request') assert.deepEqual(errors, []);
      }
    }
    if (record.name === 'held-recovery') {
      assert.equal(states[0].text, 'Sum: 2');
      await clicks(states);
      assert.equal(states.at(-1).text, 'Sum: 2');
      assert.ok(errors.length > 0);
      assert.ok(errors.every(e => e.step === '3. Finish request' && e.message === '1'));
    } else {
      assert.equal(states[0].text, 'Value: [object Object]');
      assert.deepEqual(errors, []);
    }
    const failures = [...errors];
    const controlCode = record.name === 'held-recovery'
      ? source.replace('if (step() === 1) throw new Error("boom");', '')
      : source.replace('() => immediately(empty)', '() => empty');
    assert.notEqual(controlCode, source);
    step = 'control build';
    await page.evaluate(code => window.monaco.editor.getModels().find(m => m.uri.path === '/main.tsx').setValue(code), controlCode);
    await build(true);
    errors.length = 0;
    const control = [{ step, text: await paragraph.innerText() }];
    if (record.name === 'held-recovery') await clicks(control);
    assert.equal(control.at(-1).text, record.name === 'held-recovery' ? 'Sum: 3' : 'Value: undefined');
    assert.deepEqual(errors, []);
    rows.push({ name: record.name, url: record.url, sourceRoundTrip: true, hasSavedBuild: true, states, errors: failures, control });
    console.log(`Reopened ${record.url}: baseline failure reproduced; control passed.`);
    await context.close();
  }
  await writeFile(new URL('hosted-verification.json', import.meta.url), JSON.stringify({
    date: new Date().toISOString(), browser: await browser.version(), sourceCommit: records[0].sourceCommit, cases: rows
  }, null, 2) + '\n');
} finally { await browser.close(); }
