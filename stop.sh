#!/bin/bash

# Last update: 2021-04-19
# Stops every website process
# 1) Stop task queue process
# 2) Stop Redis server
# 3) Stop database
# 4) Stop WSGI server
# 5) Stop frontend
# 6) Deactivate Python environment

task-worker-stop
redis-stop-stable
service postgresql start
flask-stop
react-stop
deactivate