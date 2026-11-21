import { readFileSync } from "node:fs";
const s = readFileSync("C:/Users/draan/.secrets/secrets.ps1", "utf8");
const i = s.indexOf("param(");
console.log(s.slice(i, i + 700));