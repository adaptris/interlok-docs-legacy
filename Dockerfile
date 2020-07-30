FROM jekyll/jekyll:latest

RUN apk add --no-cache --update make gcc g++ libxml2-dev libxslt-dev

