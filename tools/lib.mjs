// Shared screenshot helper. CDP screen metrics are needed because prosilver
// gates parts of its layout on (max-device-width: 900px), which headless Chrome
// reports as 800 unless the screen size is overridden too. The CDP session is
// kept for the page lifetime: detaching it would drop the overrides.
const sessions = new WeakMap();

async function apply(page, w, h, mobile) {
	let cdp = sessions.get(page);
	if (!cdp) {
		cdp = await page.createCDPSession();
		sessions.set(page, cdp);
	}
	await page.setViewport({ width: w, height: h, isMobile: mobile, hasTouch: mobile });
	await cdp.send("Emulation.setDeviceMetricsOverride", {
		width: w, height: h, deviceScaleFactor: 1, mobile, screenWidth: w, screenHeight: h,
	});
}

export async function shoot(page, path, width) {
	const mobile = width < 600;
	await apply(page, width, 900, mobile);
	const h1 = await page.evaluate(() => document.documentElement.scrollHeight);
	await apply(page, width, h1, mobile);
	const h2 = await page.evaluate(() => document.documentElement.scrollHeight);
	if (h2 > h1) await apply(page, width, h2, mobile);
	await new Promise((r) => setTimeout(r, 300));
	await page.screenshot({ path });
	return h2;
}
