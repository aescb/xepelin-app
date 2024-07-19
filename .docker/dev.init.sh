#!/bin/bash
set -e

echo "Installing gems if missing"
bundle config set force_ruby_platform true
bundle install
echo "Executing db setup if necessary"
rake db:migrate 2>/dev/null || rake db:setup
echo "Executing app"
rm -f tmp/pids/server.pid
bundle exec rails s -p 3000 -b 0.0.0.0
