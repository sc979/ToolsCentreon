#!/bin/bash

# script to execute 19.10.0-beta1 migration

NC='\033[0m' # No Color
YELLOW='\033[1;33m'

echo -e "${YELLOW}preparing repos and updating${NC}\n"
yum install yum-utils http://yum.centreon.com/standard/19.10/el7/stable/noarch/RPMS/centreon-release-19.10-1.el7.centos.noarch.rpm
#http://yum.centreon.com/standard/19.10/el7/stable/noarch/RPMS/centreon-release-19.10-1.el7.centos.noarch.rpm
yum-config-manager --enable 'centreon-testing*'
yum clean all
yum update -y centreon\*

printf "${YELLOW}starting new services${NC}\n"
echo date.timezone = Europe/Paris > /etc/opt/rh/rh-php72/php.d/php-timezone.ini
systemctl disable rh-php71-php-fpm
systemctl stop rh-php71-php-fpm
systemctl start rh-php72-php-fpm
systemctl enable rh-php72-php-fpm
systemctl restart httpd24-httpd
hostnamectl set-hostname centreon-central
printf "\n${YELLOW}last part, to be done manually : \n"
printf "su - centreon \n"
printf "/opt/rh/rh-php72/root/bin/php /usr/share/centreon/cron/centreon-partitioning.php \n"
printf "return to root ie: exit\n"
printf "systemctl restart cbd ${NC}\n"i
