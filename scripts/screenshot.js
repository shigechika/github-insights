#!/usr/bin/env node
// Capture a fresh dashboard screenshot to docs/screenshot.png.
//
// Runs in the daily Actions cron after data is collected. Note the inherent
// 1-tick lag: GitHub Pages redeploys asynchronously after the data push, so
// the screenshot captures the *previous* run's data. Acceptable for what is
// effectively marketing imagery in README — the live link sits right above
// it for current data.

const { chromium } = require('playwright');

const owner = process.env.GITHUB_REPOSITORY_OWNER || 'shigechika';
const repo = (process.env.GITHUB_REPOSITORY || 'shigechika/github-insights').split('/')[1];
const url = `https://${owner}.github.io/${repo}/`;
const out = 'docs/screenshot.png';

(async () => {
  console.log(`Capturing ${url} -> ${out}`);
  const browser = await chromium.launch();
  try {
    const context = await browser.newContext({
      viewport: { width: 1280, height: 800 },
      deviceScaleFactor: 2,
      colorScheme: 'light',
    });
    const page = await context.newPage();
    await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });
    // Chart.js draws to <canvas> after fetching data. Wait for the canvases
    // to exist, then a short settle for animations.
    await page.waitForSelector('canvas');
    await page.waitForTimeout(2000);
    await page.screenshot({ path: out, fullPage: true });
    console.log(`Saved ${out}`);
  } finally {
    await browser.close();
  }
})();
