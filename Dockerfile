FROM jekyll/jekyll:minimal

WORKDIR /srv/jekyll
COPY Gemfile /srv/jekyll
# Do the bundle install now, rather than later to avoid overlay2 copy on write 
# slowness
RUN apk add --no-cache --update make gcc g++ libxml2-dev libxslt-dev && \
    chown -R jekyll.jekyll /usr/gem && \
    su-exec jekyll bundle install && \
    rm /srv/jekyll/Gemfile /srv/jekyll/Gemfile.lock

USER jekyll
