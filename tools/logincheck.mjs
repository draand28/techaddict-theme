import puppeteer from "puppeteer-core";
import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";
const pw = readFileSync(process.env.TEMP + "/ta_admin_pw.txt", "utf8").trim();
const browser = await puppeteer.launch({ executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe", headless: "new" });
const page = await browser.newPage();
await page.setViewport({ width: 1440, height: 1000 });
for (let i = 0; i < 5; i++) {
	await page.goto("https://techaddict.ro/forum/ucp.php?mode=login", { waitUntil: "networkidle2" });
	await page.type("#username", "ta_acp_preview");
	await page.type("#password", pw);
	await Promise.all([page.click("input[type=submit][name=login]"), page.waitForNavigation({ waitUntil: "networkidle2" })]);
	if (!page.url().includes("mode=login")) break;
}
const cookies = await page.cookies("https://techaddict.ro/forum/");
const sidCookie = cookies.find((c) => /_sid$/.test(c.name));
const urlSid = new URL(page.url()).searchParams.get("sid");
console.log("url sid", urlSid, "cookie sid", sidCookie && sidCookie.value);
const sid = (sidCookie && sidCookie.value) || urlSid;
console.log(execSync(`ssh root@192.168.45.133 "bash /tmp/set-admin-session.sh ${sid}"`).toString());
await page.goto("https://techaddict.ro/forum/adm/index.php?sid=" + sid, { waitUntil: "networkidle2" });
console.log("acp", page.url(), await page.title());
console.log((await page.evaluate(() => document.body.innerText.replace(/\n+/g, " | ").slice(0, 260))));
await browser.close();