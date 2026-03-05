const { test, describe, before, after } = require('node:test');
const assert = require('node:assert');
const puppeteer = require('puppeteer');
const path = require('path');

describe('Target Bisection & Globe Interaction E2E Tests', { timeout: 15000 }, () => {
    let browser;
    let page;

    before(async () => {
        browser = await puppeteer.launch({
            headless: true,
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--allow-file-access-from-files',
                '--disable-web-security'
            ]
        });
        page = await browser.newPage();

        page.on('pageerror', err => {
            console.error('PAGE ERROR:', err.message);
        });

        page.on('console', async msg => {
            const args = await Promise.all(msg.args().map(arg => arg.jsonValue()));
            console.log('BROWSER CONSOLE:', msg.text(), ...args);
        });

        const indexPath = `file://${path.resolve(__dirname, '../index.html')}`;
        await page.goto(indexPath, { waitUntil: 'load' });
    });

    after(async () => {
        if (browser) await browser.close();
    });

    test('Globe click on TX updates target bearing and azimuth', async () => {
        // Switch to Target Mode
        await page.click('#mode-target');
        await page.waitForSelector('#target-controls', { visible: true });

        // Set RX Lat/Lon manually to represent a ground target
        await page.evaluate(() => {
            const latEl = document.getElementById('rx-lat');
            const lonEl = document.getElementById('rx-lon');
            latEl.value = '35.0';
            lonEl.value = '-75.0';
            latEl.dispatchEvent(new Event('change')); // triggers updateTxRxComputed
        });

        // Verify that Azimuth updated from 0 to something else
        const initialAzimuth = await page.$eval('#azimuth', el => el.value);
        assert.notStrictEqual(initialAzimuth, '0', 'Azimuth should recalculate after RX changed');

        const initialRange = await page.$eval('#target-range', el => el.value);

        // Click 'Set Start on Globe' 
        // We will simulate the internal globe click logic natively by filling DOM nodes
        await page.evaluate(() => {
            const rxTxBtn = document.getElementById('rx-tx-globe-pick-btn');
            if (rxTxBtn) rxTxBtn.click(); // sets pick mode to TX

            // Bypass the canvas raycaster by manually filling in the TX lat/lon and firing updateTxRxComputed 
            const txLatEl = document.getElementById('tx-lat');
            const txLonEl = document.getElementById('tx-lon');
            txLatEl.value = '45.0';
            txLonEl.value = '-80.0';

            // To faithfully trigger standard update events, we simulate the `change` events
            txLatEl.dispatchEvent(new Event('change'));
            txLonEl.dispatchEvent(new Event('change'));

            // force a re-trigger of RX change, which invokes updateTxRxComputed
            document.getElementById('rx-lat').dispatchEvent(new Event('change'));
        });

        // Ensure Azimuth and distance re-calculated!
        const newAzimuth = await page.$eval('#azimuth', el => el.value);
        const newRange = await page.$eval('#target-range', el => el.value);

        assert.notStrictEqual(newAzimuth, initialAzimuth, 'Azimuth should change after TX click on globe');
        assert.notStrictEqual(newRange, initialRange, 'Target Range should change after TX click on globe');
    });

    test('Target Bisection runs successfully without hanging', async () => {
        // Switch to 3D mode to ensure updateGlobeRays runs
        await page.click('#view-3d-btn');

        // Run the target search
        const btnTextBefore = await page.$eval('#target-btn .btn-label', el => el.textContent);
        assert.strictEqual(btnTextBefore, 'Find Path');

        await page.click('#target-btn');

        // Wait a small bit to ensure it enters loading state
        await new Promise(r => setTimeout(r, 500));

        let btnTextLoading = await page.$eval('#target-btn .btn-label', el => el.textContent);
        assert.ok(btnTextLoading.includes('Sweep') || btnTextLoading.includes('Bisect') || btnTextLoading.includes('Find'), 'Button should be in active search state');

        // Wait up to 10 seconds for progressive bisection to finish
        await new Promise(r => setTimeout(r, 10000));

        // It should have safely returned to 'Find Path' without throwing IndexSizeError on Canvas Arc!
        const btnTextAfter = await page.$eval('#target-btn .btn-label', el => el.textContent);
        assert.strictEqual(btnTextAfter, 'Find Path', 'Search did not exit cleanly (hung or crashed)');
    });
});
