const { test, describe, before, after } = require('node:test');
const assert = require('node:assert');
const puppeteer = require('puppeteer');
const path = require('path');

describe('Basic Raytracing UI E2E Tests', { timeout: 15000 }, () => {
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

        const indexPath = `file://${path.resolve(__dirname, '../index.html')}`;
        await page.goto(indexPath, { waitUntil: 'load' });
    });

    after(async () => {
        if (browser) await browser.close();
    });

    test('Loads the app and defaults to Fan Sweep mode', async () => {
        const activeModeId = await page.evaluate(() => {
            return document.querySelector('.mode-btn.active').id;
        });
        assert.strictEqual(activeModeId, 'mode-fan', 'Should default to fan sweep mode');

        const titleText = await page.$eval('h1', el => el.textContent);
        assert.ok(titleText.includes('Ray Tracer'), 'Header title should contain "Ray Tracer"');
    });

    test('Can switch to Target Location mode and see quick bounds', async () => {
        await page.click('#mode-target');

        const activeModeId = await page.evaluate(() => {
            return document.querySelector('.mode-btn.active').id;
        });
        assert.strictEqual(activeModeId, 'mode-target', 'Should have switched to target location mode');

        const btnTextBefore = await page.$eval('#target-btn .btn-label', el => el.textContent);
        assert.ok(btnTextBefore.includes('Find'), 'Find Path button should be ready');

        // Target range
        await page.evaluate(() => {
            const rangeEl = document.getElementById('target-range');
            rangeEl.value = '1500';
            rangeEl.dispatchEvent(new Event('input'));
        });

        const newDisplay = await page.$eval('#target-range', el => el.value);
        assert.strictEqual(newDisplay, '1500', 'Target range display should update when input range changes');
    });

    test('Standard trace button runs and completes', async () => {
        // Switch back to fan view to use standard trace button
        await page.click('#mode-fan');

        // Run a simple trace
        await page.click('#trace-btn');

        // Wait for it to finish (button text returns to Trace Rays)
        await page.waitForFunction(() => {
            return document.querySelector('#trace-btn .btn-label').textContent.includes('Trace');
        }, { timeout: 10000 });

        const btnTextAfter = await page.$eval('#trace-btn .btn-label', el => el.textContent);
        assert.ok(btnTextAfter.includes('Trace'), 'Button should return to Trace mode after completion');
    });
});
