#!/bin/bash
set -e

pr=$1
production=production/5.5.z

echo making a MR for $production from PR $PR

git checkout -b "cherry_$pr" $production

commits=$(wget -O - https://api.github.com/repos/ManageIQ/manageiq/pulls/$1/commits | jq -r 'map(.sha) | @sh' | tr "'" " ")

git cherry-pick $commits

echo run "'git push production-my cherry_$pr:cherry_$pr'" when happy with the result
