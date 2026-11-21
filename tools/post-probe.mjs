import puppeteer from "puppeteer-core";
const browser = await puppeteer.launch({ executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe", headless: "new" });
const page = await browser.newPage();
const errs = [];
page.on("console", (m) => m.type() === "error" && errs.push(m.text()));
page.on("pageerror", (e) => errs.push(String(e)));
await page.setViewport({ width: 1440, height: 1000 });
await page.goto("https://techaddict.ro/20-de-euro-gratuit/", { waitUntil: "networkidle2" });
await new Promise((r) => setTimeout(r, 3000));
const info = await page.evaluate(() => {
	const img = document.querySelector("img.wp-post-image");
	if (!img) return { missing: true };
	const cs = getComputedStyle(img);
	const r = img.getBoundingClientRect();
	return { complete: img.complete, naturalWidth: img.naturalWidth, currentSrc: img.currentSrc, opacity: cs.opacity, visibility: cs.visibility, display: cs.display, filter: cs.filter, transform: cs.transform, box: [r.width, r.height], parentClass: img.parentElement.className, parentOpacity: getComputedStyle(img.parentElement).opacity };
});
console.log(JSON.stringify({ info, errs: errs.slice(0, 10) }, null, 1));
await page.screenshot({ path: "shots/post-image.png", fullPage: false });
await browser.close();