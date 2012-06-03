#!/bin/bash

. "/etc/profile.d/rvm.sh"
rvm use 1.9.2

cd /home/deploy/applications/trails_forward/current
nice stalk lib/jobs/jobs.rb
