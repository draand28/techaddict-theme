#!/bin/bash
# Compare form token session with cookie session, 6 fresh attempts.
PW="$1"
for i in 1 2 3 4 5 6; do
	rm -f /tmp/cj.txt
	curl -s -L -c /tmp/cj.txt "https://techaddict.ro/forum/ucp.php?mode=login" -o /tmp/login.html
	TOK=$(grep -o 'name="form_token" value="[^"]*"' /tmp/login.html | head -1 | sed 's/.*value="//;s/"//')
	CT=$(grep -o 'name="creation_time" value="[^"]*"' /tmp/login.html | head -1 | sed 's/.*value="//;s/"//')
	SID=$(grep -o 'name="sid" value="[^"]*"' /tmp/login.html | head -1 | sed 's/.*value="//;s/"//')
	CSID=$(grep -o '_sid[[:space:]]*[^[:space:]]*$' /tmp/cj.txt | awk '{print $NF}')
	CODE=$(curl -s -b /tmp/cj.txt -c /tmp/cj.txt -o /tmp/post.html -w '%{http_code}' \
		-d "username=ta_acp_preview" -d "password=$PW" -d "login=Login" \
		-d "creation_time=$CT" -d "form_token=$TOK" -d "sid=$SID" -d "redirect=index.php" \
		"https://techaddict.ro/forum/ucp.php?mode=login&sid=$SID")
	echo "run $i code=$CODE invalid=$(grep -c 'submitted form was invalid' /tmp/post.html) form=${SID:0:6} cookie=${CSID:0:6} tok=$([ -n "$TOK" ] && echo yes || echo no)"
	sleep 1
done
