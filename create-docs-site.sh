#!/bin/bash
TARGET_DIR=/home/websites/development.adaptris.net/docs/
SITE_DIR=_site
SITE_NAME=Interlok

source ${HOME}/.rvm/scripts/rvm

rm -rf ./${SITE_DIR}/${SITE_NAME}
rvm use 2.3.3
bundle exec jekyll build -d ${SITE_DIR}/${SITE_NAME}
rc=`echo $?`
if [ $rc -ne 0 ]
then
 echo Jekyll Failed
 exit $rc
else
 echo Deploying ${SITE_NAME} to ${TARGET_DIR}
 rm -rf ${TARGET_DIR}/${SITE_NAME}
 mv ${SITE_DIR}/${SITE_NAME} ${TARGET_DIR}
fi


