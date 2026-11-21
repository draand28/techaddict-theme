import puppeteer from "puppeteer-core";

const pw = process.env.WP_PW;
if (!pw) throw new Error("WP_PW not set");

const browser = await puppeteer.launch({ executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe", headless: "new" });
const page = await browser.newPage();
await page.setViewport({ width: 1440, height: 1000 });

await page.goto("https://techaddict.ro/wp-login.php", { waitUntil: "networkidle2" });
await page.type("#user_login", "draand28");
await page.type("#user_pass", pw);
await Promise.all([
	page.click("#wp-submit"),
	page.waitForNavigation({ waitUntil: "networkidle2" }),
]);
console.log("after login:", page.url(), "|", await page.title());
if (page.url().includes("wp-login.php")) {
	const err = await page.$eval("#login_error", (e) => e.textContent.trim()).catch(() => "unknown");
	console.log("login failed:", err);
	await browser.close();
	process.exit(1);
}

const notices = await page.evaluate(() =>
	[...document.querySelectorAll(".notice, .error, .updated")].map((n) => n.innerText.replace(/\s+/g, " ").trim()).filter(Boolean)
);
console.log("admin notices:", JSON.stringify(notices.slice(0, 10), null, 1));

await page.goto("https://techaddict.ro/wp-admin/site-health.php", { waitUntil: "networkidle2" });
await new Promise((r) => setTimeout(r, 4000));
await page.screenshot({ path: "shots/wp-site-health.png", fullPage: true });

const health = await page.evaluate(() => {
	const out = [];
	document.querySelectorAll(".health-check-body h2, .health-check-body h3, .health-check-accordion-trigger, .health-check-accordion-panel p, .site-health-count").forEach((el) => {
		const t = el.innerText.replace(/\s+/g, " ").trim();
		if (t) out.push(t);
	});
	return out.slice(0, 80);
});
console.log("site health:", JSON.stringify(health, null, 1));
await browser.close();
