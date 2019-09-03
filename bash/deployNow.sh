#!/bin/bash
sshpass -p "denied" scp www/install/steps/process/createDbUser.php root@10.10.1.42:/usr/share/centreon/www/install/steps/process/createDbUser.php
sshpass -p "denied" scp www/class/centreon-partition/partEngine.class.php root@10.10.1.42:/usr/share/centreon/www/class/centreon-partition/partEngine.class.php
sshpass -p "denied" scp cron/centAcl.php root@10.10.1.42:/usr/share/centreon/cron/centAcl.php
echo "done"
