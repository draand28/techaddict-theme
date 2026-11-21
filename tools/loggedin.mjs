import puppeteer from "puppeteer-core";
import { readFileSync } from "node:fs";
import { shoot } from "./lib.mjs";

const pw = readFileSync(process.env.TEMP + "/ta_preview_pw.txt", "utf8").trim();
const browser = await puppeteer.launch({ executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe", headless: "new" });
const page = await browser.newPage();
const errors = [];
page.on("response", (r) => r.status() >= 400 && errors.push(r.status() + " " + r.url()));
await page.setViewport({ width: 1440, height: 1000 });
await page.goto("https://techaddict.ro/forum/ucp.php?mode=login", { waitUntil: "networkidle2" });
await page.type("#username", "ta_preview");
await page.type("#password", pw);
await Promise.all([page.click("input[type=submit][name=login]"), page.waitForNavigation({ waitUntil: "networkidle2" })]);

const pages = [
	["ucp", "https://techaddict.ro/forum/ucp.php"],
	["posting", "https://techaddict.ro/forum/posting.php?mode=reply&t=1"],
	["memberlist", "https://techaddict.ro/forum/memberlist.php"],
	["search", "https://techaddict.ro/forum/search.php?search_id=active_topics"],
];
for (const [name, url] of pages) {
	await page.goto(url, { waitUntil: "networkidle2" });
	await shoot(page, `shots/in-${name}.png`, 1440);
	console.log(name, await page.title(), errors.slice(-2));
}
await page.goto("https://techaddict.ro/forum/posting.php?mode=reply&t=1", { waitUntil: "networkidle2" });
await shoot(page, "shots/in-posting-mobile.png", 390);
await browser.close();
