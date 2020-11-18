#!/bin/bash
#

function config_mysql {
    if [ $DB_PORT != 3306 ]; then
        if [ ! "$(cat /etc/my.cnf | grep port=)" ]; then
            sed -i "10i port=$DB_PORT" /etc/my.cnf
        else
            sed -i "s/port=.*/port=$DB_PORT/g" /etc/my.cnf
        fi
    fi
}

if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
    config_mysql
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
    mysqld --daemonize --user=mysql --defaults-file=/etc/my.cnf
    sleep 5s
    mysql -uroot -e "set global validate_password_policy=LOW; create database $DB_NAME default charset 'utf8' collate 'utf8_bin';grant all on $DB_NAME.* to '$DB_USER'@'%' identified by '$DB_PASSWORD';flush privileges;";
    mysql --version
    tail -f /var/log/mysqld.log
else
    config_mysql
    mysqld --daemonize --user=mysql --defaults-file=/etc/my.cnf
    mysql --version
    tail -f /var/log/mysqld.log
fi
