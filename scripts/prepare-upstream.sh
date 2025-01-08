#!/bin/bash

source /etc/profile
set -o errexit

cd "$(cd "$(dirname "$0")"; pwd)"
[ -e './raw-sources' ] && rm -rf ./raw-sources
mkdir ./raw-sources
rm -rf ./origin-files/*.txt

easylist=(
	'https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt'
)
hosts=(
	'https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt'
)

# The script uses '^[a-zA-Z0-9\.-]+\.[a-zA-Z]+$' to match a domain in many cases
# Some punny code (top) domains, like 'example.xn--q9jyb4c', will be ignored

for i in "${!easylist[@]}"; do
	echo "Start to download easylist-${i}..."
	tMark="$(date +'%Y-%m-%d %H:%M:%S %Z')"
	curl -o "./raw-sources/easylist-${i}.txt" --connect-timeout 60 -s "${easylist[$i]}"
	echo -e "! easylist-${i} $tMark\n! ${easylist[$i]}" >>./origin-files/upstream-easylist.txt
	tr -d '\r' <"./raw-sources/easylist-${i}.txt" |
		grep -E '^(@@)?\|\|?[a-zA-Z0-9\.\*-]+\.[a-zA-Z\*]+\^(\$[^=]+)?$' |
		sed -e "/\^\$elemhide$/d" -e "/\^\$generichide$/d" |
		LC_ALL=C sort -u >>./origin-files/upstream-easylist.txt
done

Hosts-Processer() {
	sed -e 's/[[:space:]]*#.*//g' -e 's/[[:space:]][[:space:]][[:space:]]*/ /g' -e 's/0\.0\.0\.0/127.0.0.1/g' -e 's/::/127.0.0.1/g' |
		grep -E '^127\.0\.0\.1 [a-zA-Z0-9\.-]+\.[a-zA-Z]+$' | LC_ALL=C sort -u
}

for i in "${!hosts[@]}"; do
	echo "Start to download hosts-${i}..."
	tMark="$(date +'%Y-%m-%d %H:%M:%S %Z')"
	curl -o "./raw-sources/hosts-${i}.txt" --connect-timeout 60 -s "${hosts[$i]}"
	echo -e "# hosts-${i} $tMark\n# ${hosts[$i]}" >>./origin-files/upstream-hosts.txt
	tr -d '\r' <"./raw-sources/hosts-${i}.txt" | Hosts-Processer >>./origin-files/upstream-hosts.txt
done

# Comment next line to track raw sources lists
rm -rf ./raw-sources/

sed -r -e '/^!/d' -e 's=^\|\|?=||=' ./origin-files/upstream-easylist.txt |
	grep -E '^\|\|[a-zA-Z0-9\.-]+\.[a-zA-Z]+\^(\$[^~]+)?$' | LC_ALL=C sort -u >./origin-files/base-src-easylist.txt
sed -r -e '/^!/d' -e 's=^\|\|?=||=' ./origin-files/upstream-easylist.txt |
	grep -E '\|\|([a-zA-Z0-9\.\*-]+)?\*([a-zA-Z0-9\.\*-]+)?\^(\$[^~]+)?$' | LC_ALL=C sort -u >./origin-files/wildcard-src-easylist.txt
sed -r -e '/^!/d' -e 's=^@@\|\|?=@@||=' ./origin-files/upstream-easylist.txt |
	grep -E '^@@\|\|[a-zA-Z0-9\.-]+\.[a-zA-Z]+\^' | LC_ALL=C sort -u >./origin-files/whiterule-src-easylist.txt
sed '/^#/d' ./origin-files/upstream-hosts.txt | LC_ALL=C sort -u >./origin-files/base-src-hosts.txt
touch ./origin-files/base-src-strict-hosts.txt
touch ./origin-files/base-dead-hosts.txt

cd ../
