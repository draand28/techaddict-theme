import puppeteer from "puppeteer-core";
import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";
import { shoot } from "./lib.mjs";

const pw = readFileSync(process.env.TEMP + "/ta_admin_pw.txt", "utf8").trim();
const browser = await puppeteer.launch({ executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe", headless: "new" });
const page = await browser.newPage();
await page.setViewport({ width: 1440, height: 1000 });

for (let i = 0; i < 4; i++) {
	await page.goto("https://techaddict.ro/forum/ucp.php?mode=login", { waitUntil: "networkidle2" });
	await page.type("#username", "ta_acp_preview");
	await page.type("#password", pw);
	await Promise.all([page.click("input[type=submit][name=login]"), page.waitForNavigation({ waitUntil: "networkidle2" })]);
	if (!page.url().includes("mode=login")) break;
	console.log("login retry", i + 1);
}

const sid = new URL(page.url()).searchParams.get("sid");
console.log("sid", sid);
execSync(`ssh root@192.168.45.133 "bash /tmp/set-admin-session.sh ${sid}"`, { stdio: "inherit" });

await page.goto("https://techaddict.ro/forum/adm/index.php", { waitUntil: "networkidle2" });
console.log("acp ->", page.url(), "|", await page.title());
await shoot(page, "shots/acp-index.png", 1440);

const links = await page.evaluate(() =>
	[...document.querySelectorAll("#menu a")].map((a) => ({ text: a.textContent.trim(), href: a.href }))
);
const wanted = ["Board settings", "Manage forums", "Manage users", "Styles", "Attachments"];
const picks = wanted.map((w) => links.find((l) => l.text === w)).filter(Boolean);
for (const link of picks) {
	await page.goto(link.href, { waitUntil: "networkidle2" });
	await shoot(page, `shots/acp-${link.text.toLowerCase().replace(/\s+/g, "-")}.png`, 1440);
	console.log("shot", link.text, await page.title());
}
await browser.close();
