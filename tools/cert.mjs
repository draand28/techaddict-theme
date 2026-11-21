import tls from "node:tls";
for (const name of ["www.techaddict.ro", "techaddict.ro"]) {
	await new Promise((res) => {
		const s = tls.connect({ host: name === "www.techaddict.ro" ? "45.13.38.175" : "45.13.38.175", servername: name, port: 443, rejectUnauthorized: false }, () => {
			const c = s.getPeerCertificate();
			console.log(name, JSON.stringify({ subject: c.subject && c.subject.CN, issuer: c.issuer && c.issuer.O, issuerCN: c.issuer && c.issuer.CN, san: c.subjectaltname, valid_to: c.valid_to, authorized: s.authorized }));
			s.end(); res();
		});
		s.on("error", (e) => { console.log(name, "ERR", e.code, e.message); res(); });
	});
}