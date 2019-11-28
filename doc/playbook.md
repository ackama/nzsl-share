NZSL Share Playbook
====

What is this document?

This document outlines scenarios where something could go wrong with the NZSL Share application,
along with any suggestions or steps to address the problem.

_This is a living document. If there is an outage or failure of some kind, consider: could the
solution be added to this playbook_

#### Redis down

* Symptom: Sidekiq status page (`/sidekiq`) shows no connection to Redis
* Symptom: 500 error pages on pages that enqueue jobs.
* Symptom: Errors about connecting to URL with a port of 6789 (Connection refused, Connection timed out etc)
* Suggestion: Check https://status.heroku.com/, specifically for Redis or general unavailability issues.
* Suggestion: Run `heroku run bash` and try using `telnet`, `ping`, etc to connect to the Redis URL specified in `heroku config`.
* Suggestion: Log in to the Redis management dashboard (avilable from the "Resources" tab of the Heroku application) and
  check that it is healthy (we have a reasonably small quota of key space for example).

#### PostgreSQL down

* Symptom: 500 error pages on pretty much all pages
* Symptom: log files warn of failing to establish database connection
* Suggestion: Check https://status.heroku.com/ for Postgres or general unavailablity issues
* Log into the Heroku console, check that `DATABASE_URL` is correct and that the Heroku Postgres dashboard
  under 'Resources' is healthy, available and no billing issues.

#### Database connection pool exhausted

* Symptom: intermittent 500 on random pages (e.g. not the same route)
* Symptom: large batch of jobs recently enqueued
* Symptom: escalation of failed jobs with database connectivity issues
* Suggestion: tweak database configuration pool size
* Suggestion: wait - this has happened before when we've enqueued >1000 jobs at once.
  While the jobs initially error, they retry eventually and work through.

#### Video encoding failures

* Symptom: newly-uploaded signs never become processed
* Symptom: escalation of failed jobs in the `thumbnail_generation` and `video_encoding` queues.
* Suggestion: enable debug logs `LOG_LEVEL=debug` and take note of the ffmpeg output when a video encoding job runs.
* Suggestion: scope the problem - is it a problem with ffmpeg itself, or just with a single video
* Suggestion: If it is a problem with ffmpeg, check the buildpack is up to date and working (`heroku buildpacks`). Run `heroku run bash` and then `ffmpeg` and check that it can run without errors.
* Suggestion: If it appears to be a problem with a particular file, pull the file from S3, and replicate locally. The debug logs include the entire ffmpeg command that was run which should help to replicate.

#### S3 availability/permission issues

* Symptoms: attachments (videos/usage examples/illustations, etc) are failing to serve. May fail with a 403 or 500 status.
* Symptoms: escalation of failed jobs due to S3 permission errors (`AccessDenied`).
* Suggestion: run `heroku config` and check that the bucket name, access key ID and secret access key are all correct. You can check these in the S3 dashboard (for the bucket name), and IAM (for the access key ID and secret access key).
* Suggestion: try uploading a file using these credentials. `PutObject` and multipart uploads should work fine.
* Suggestion: check https://status.aws.amazon.com/ to see if there are any availability issues reported, specifically in ap-southeast-2.

#### Basic auth is on when it shouldn't be/is not on when it should be

* Symptoms: visitors are greeted with a basic auth prompt
* Suggestion: check Heroku config for `HTTP_BASIC_AUTH_USERNAME` and `HTTP_BASIC_AUTH_PASSWORD`. If both of these
  variables are present in `ENV`, then basic auth will be enabled.
