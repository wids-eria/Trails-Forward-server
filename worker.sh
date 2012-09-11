#!/bin/bash

. "/etc/profile.d/rvm.sh"
rvm use 1.9.2

cd /home/deploy/applications/trails_forward/current
RAILS_ENV=staging nice stalk lib/jobs/jobs.rb
