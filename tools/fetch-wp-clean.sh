#!/bin/bash
set -e
mkdir -p /root/techaddict-cleanup
cd /root/techaddict-cleanup
if [ ! -f wp.tar.gz ]; then
	curl -sS -o wp.tar.gz https://wordpress.org/wordpress-7.1.3.tar.gz
fi
if [ ! -d wordpress ]; then
	tar -xzf wp.tar.gz
fi
echo "clean tree: $(du -sh wordpress | cut -f1)"
