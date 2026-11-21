import puppeteer from "puppeteer-core";
const browser = await puppeteer.launch({ executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe", headless: "new" });
const page = await browser.newPage();
await page.setViewport({ width: 1440, height: 1000, deviceScaleFactor: 2 });
const shots = [
	["crop-header", "https://techaddict.ro/forum/", async () => ({ x: 0, y: 0, width: 1440, height: 320 })],
	["crop-cat", "https://techaddict.ro/forum/", async () => {
		const r = await page.$(".forabg");
		const b = await r.boundingBox();
		return { x: b.x - 8, y: b.y - 8, width: b.width + 16, height: Math.min(b.height + 16, 560) };
	}],
	["crop-login", "https://techaddict.ro/forum/", async () => {
		const r = await page.$("form.headerspace");
		const b = await r.boundingBox();
		return { x: b.x - 8, y: b.y - 40, width: b.width + 16, height: b.height + 60 };
	}],
	["crop-post", "https://techaddict.ro/forum/viewtopic.php?t=1", async () => {
		const r = await page.$(".post");
		const b = await r.boundingBox();
		return { x: b.x - 8, y: b.y - 8, width: b.width + 16, height: b.height + 16 };
	}],
	["crop-toolbar", "https://techaddict.ro/forum/viewtopic.php?t=1", async () => {
		const r = await page.$(".action-bar.bar-top");
		const b = await r.boundingBox();
		return { x: b.x - 8, y: b.y - 60, width: b.width + 16, height: b.height + 80 };
	}],
];
for (const [name, url, clip] of shots) {
	await page.goto(url, { waitUntil: "networkidle2" });
	await page.screenshot({ path: `shots/${name}.png`, clip: await clip() });
}
await browser.close();
