#!/usr/bin/bash
/usr/bin/php -r 'umask(022);$phar=new Phar($argv[1]);$phar->extractTo($argv[2],null,true);echo "success";' $1 $2 
