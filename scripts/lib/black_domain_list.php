<?php
//黑名单域名，即直接封杀主域名，效果就是只要是使用该域名及其下级所有域名的请求全部被阻挡，慎重使用

//这个文件主要定义针对hosts文件中不能泛域名解析而优化减少生成行数
//对于个性化屏蔽的域名，全部移动到block_domains.root.conf中管理
// Formatter: https://www.duplichecker.com/php-formatter

return [
  "188pi.com" => ["ad.api.188pi.com"],
  "ahdohpiechei.com" => ["ahdohpiechei.com"],
  "leyaoyao.com" => ["sentry-report.leyaoyao.com"],
  "sz-cooleasy.com" => [
    "ad.sz-cooleasy.com",
    "jdstore.sz-cooleasy.com",
  ],
  "wechat.com" => ["dns.wechat.com"],
];
