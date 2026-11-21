import puppeteer from "puppeteer-core";
import { mkdir } from "node:fs/promises";
import { shoot } from "./lib.mjs";

const CHROME = "C:/Program Files/Google/Chrome/Application/chrome.exe";
const OUT = new URL("../shots/", import.meta.url).pathname.replace(/^\//, "");
const args = process.argv.slice(2);
const targets = args.length
	? args.map((u) => [u.replace(/\W+/g, "-").slice(0, 40), u])
	: [
		["index", "https://techaddict.ro/forum/"],
		["topic", "https://techaddict.ro/forum/viewtopic.php?t=1"],
		["login", "https://techaddict.ro/forum/ucp.php?mode=login"],
		["forum", "https://techaddict.ro/forum/viewforum.php?f=4"],
	];

await mkdir(OUT, { recursive: true });
const browser = await puppeteer.launch({ executablePath: CHROME, headless: "new", args: ["--no-sandbox"] });

for (const [name, url] of targets) {
	for (const [tag, width] of [["desktop", 1440], ["mobile", 390]]) {
		const page = await browser.newPage();
		const errors = [];
		page.on("console", (m) => m.type() === "error" && errors.push(m.text()));
		page.on("pageerror", (e) => errors.push(String(e)));
		const res = await page.goto(url, { waitUntil: "networkidle2", timeout: 45000 });
		const h = await shoot(page, `${OUT}${name}-${tag}.png`, width);
		console.log(JSON.stringify({ name, tag, status: res.status(), h, errors: errors.slice(0, 3) }));
		await page.close();
	}
}
await browser.close();
