#!/bin/bash

source /etc/profile

cd $(cd "$(dirname "$0")";pwd)

easylist=(
  "https://easylist.to/easylist/easylist.txt"
  "https://easylist.to/easylist/easyprivacy.txt"
  "https://easylist-downloads.adblockplus.org/easylistchina.txt"
  "https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt"
  "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"
  "https://raw.githubusercontent.com/Cats-Team/AdRules/main/dns.txt"
)

hosts=(
  "https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts"
)

dead_hosts=(
  "https://raw.githubusercontent.com/notracking/hosts-blocklists-scripts/master/domains.dead.txt"
  "https://raw.githubusercontent.com/notracking/hosts-blocklists-scripts/master/hostnames.dead.txt"
)

rm -f ./origin-files/*

for i in "${!easylist[@]}"
do
  echo "开始下载 easylist${i}..."
  curl -o "./origin-files/easylist${i}.txt" --connect-timeout 60 -s "${easylist[$i]}"
  # shellcheck disable=SC2181
  if [ $? -ne 0 ];then
    echo '下载失败，请重试'
    exit 1
  fi
done

for i in "${!hosts[@]}"
do
  echo "开始下载 hosts${i}..."
  curl -o "./origin-files/hosts${i}.txt" --connect-timeout 60 -s "${hosts[$i]}"
  # shellcheck disable=SC2181
  if [ $? -ne 0 ];then
    echo '下载失败，请重试'
    exit 1
  fi
done

for i in "${!dead_hosts[@]}"
do
  echo "开始下载 dead-hosts${i}..."
  curl -o "./origin-files/dead-hosts${i}.txt" --connect-timeout 60 -s "${dead_hosts[$i]}"
  # shellcheck disable=SC2181
  if [ $? -ne 0 ];then
    echo '下载失败，请重试'
    exit 1
  fi
done


cd origin-files

cat hosts*.txt | grep -v -E "^((#.*)|(\s*))$" \
 | grep -v -E "^[0-9\.:]+\s+(ip6\-)?(localhost|loopback)$" \
 | sed s/0.0.0.0/127.0.0.1/g | sed s/::/127.0.0.1/g | sort \
 | uniq >base-src-hosts.txt

cat dead-hosts*.txt | grep -v -E "^(#|\!)" \
 | sort \
 | uniq >base-dead-hosts.txt


cat easylist*.txt | grep -E "^\|\|[^\*\^]+?\^" | sort | uniq >base-src-easylist.txt
cat easylist*.txt | grep -E "^\|\|?([^\^=\/:]+)?\*([^\^=\/:]+)?\^" | sort | uniq >wildcard-src-easylist.txt
cat easylist*.txt | grep -E "^@@\|\|?[^\^=\/:]+?\^([^\/=\*]+)?$" | sort | uniq >whiterule-src-easylist.txt

cd ../
