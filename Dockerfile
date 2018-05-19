FROM ruby:2.4.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN gem install bundler

ARG RAILS_ENV=development
ENV RAILS_ENV $RAILS_ENV
ENV RAILS_SERVE_STATIC_FILES true

# Install phantomjs --no-check-certificate 
ENV PHANTOMJS_VERSION 2.1.1
RUN if [ "${RAILS_ENV}" = "test" ]; then mkdir -p /srv/var && \
  wget -q -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  tar -xjf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /tmp && \
  rm -f /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  mv /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/ /srv/var/phantomjs && \
  ln -s /srv/var/phantomjs/bin/phantomjs /usr/bin/phantomjs && \
  export PATH=$PATH:/usr/bin/phantomjs; fi

# Set an environment variable to store where the app is installed to inside
# of the Docker image. Create and set working directory to there
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

# Ensure gems are cached and only get updated when they change.
# This will drastically increase build times when your gems do not change.
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN if [ "${RAILS_ENV}" = "production" ]; then bundle install --without development test; else bundle install; fi

# Copy in the application code from your work station at the current directory
# over to the working directory.
COPY . .

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$INSTALL_PATH/public"]

# Expose port 3000 to the Docker host, so we can access it from the outside.
EXPOSE 3000

# Command sets SECRET_KEY_BASE and precompiles assets in production, and then resets database
RUN rake db:reset

# Starts the server
CMD if [ "${RAILS_ENV}" = "production" ]; then export SECRET_KEY_BASE=$(rails secret) && rails assets:precompile; fi && rails server -b 0.0.0.0