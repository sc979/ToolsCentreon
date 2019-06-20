#!/bin/bash
echo "generating Localized translations"
cd /usr/share/centreon/lang/
pwd
REPLY=( $(ls) )
for i in ${REPLY[@]}; do
	cd $i/LC_MESSAGES/
	pwd
	msgfmt messages.po -o messages.mo
	msgfmt help.po -o help.mo
	chmod +x *.mo
	yes | mv messages.mo /usr/share/centreon/www/locale/$i/LC_MESSAGES/
	yes | mv help.mo /usr/share/centreon/www/locale/$i/LC_MESSAGES/

	cd ../..
	echo $i" done"
done
