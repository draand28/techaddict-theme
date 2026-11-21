import tls from "node:tls";
await new Promise((res) => {
	const s = tls.connect({ host: "www.techaddict.ro", servername: "www.techaddict.ro", port: 443, rejectUnauthorized: false }, () => {
		const c = s.getPeerCertificate();
		console.log(JSON.stringify({ authorized: s.authorized, subject: c.subject && c.subject.CN, issuer: c.issuer && c.issuer.CN, san: c.subjectaltname }));
		s.end(); res();
	});
	s.on("error", (e) => { console.log("ERR", e.code, e.message); res(); });
});