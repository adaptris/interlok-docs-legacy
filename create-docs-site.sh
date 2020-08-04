#!/bin/bash
SITE_DIR=_site

source ${HOME}/.rvm/scripts/rvm
rm -rf ./${SITE_DIR} html-docs.zip
rvm use 2.7
gem install bundler
bundle install
bundle exec jekyll build -d ${SITE_DIR}
if [[ $? -ne 0 ]]; then
 echo Jekyll Failed
 exit 1
fi
(cd ./${SITE_DIR} && zip -9 -r ../html-docs.zip *)
