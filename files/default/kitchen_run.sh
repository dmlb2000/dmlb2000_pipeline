#!/bin/bash -xe

cd /var/lib/buildbot/slave/kitchen/${FROM_COOKBOOK}_kitchen/build
kitchen test
