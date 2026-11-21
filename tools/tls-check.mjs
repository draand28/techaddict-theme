import tls from "node:tls";
for (const v of ["TLSv1", "TLSv1.1", "TLSv1.2"]) {
	await new Promise((res) => {
		const s = tls.connect({ host: "techaddict.ro", servername: "techaddict.ro", port: 443, minVersion: v, maxVersion: v, rejectUnauthorized: false }, () => {
			console.log(v, "accepted", s.getProtocol());
			s.end(); res();
		});
		s.on("error", (e) => { console.log(v, "rejected", e.code || e.message); res(); });
	});
}