<?php
//white_domain_list
//白名单机制...，白名单是
//@date 2018年12月23日
//value=-1,代表失效本条规则，暂只支持单域名（针对引入外部白名单时的精确控制）,当处于strict_mode时，排除此key，单条关闭strict_mode
//value=0,代表仅加白单条域名
//value=1,代表其下级域名全部加白（例如3级域名，则其4级子域名全部加白）
//value=2,代表仅加白主域名及其子域名，即如果是主域名，加白全部，如果是子域名，加白命中的单条
// Formatter: https://www.duplichecker.com/php-formatter

return [];