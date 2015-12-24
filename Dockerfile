FROM phusion/passenger-full

ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf

ENV APP_HOME /home/app

RUN ruby-switch --set ruby2.2

RUN rm /etc/nginx/sites-enabled/default

ENV RAILS_ASSETS_PRECOMPILE=1

CMD ["/sbin/my_init"]


RUN su app -c 'mkdir /home/app/{bundle,bundle-cache}'


# Install bundle (assuming bundle packaged to vendor/cache)
COPY vendor/cache /home/app/bundle-cache/vendor/cache
COPY Gemfile /home/app/bundle-cache/Gemfile
COPY Gemfile.lock /home/app/bundle-cache/Gemfile.lock
RUN chown -R app /home/app/bundle-cache
RUN su app -c 'cd /home/app/bundle-cache && \
                       bundle install \
                            --jobs=4 \
                            --path=/home/app/bundle \
                            --no-cache'

WORKDIR $APP_HOME

ADD . $APP_HOME

RUN su -c 'RAILS_ENV=production bundle exec rake assets:precompile'
