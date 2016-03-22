#!/bin/bash
set -e

pr=$1
production=production/5.5.z

echo making a MR for $production from PR $PR

git checkout -b "cherry_$pr" $production

token=$(cat ~/.github-fetch-pullrequest-token)
user=martinpovolny

commits=$(wget --user $USER --password "$TOKEN" -O - https://api.github.com/repos/ManageIQ/manageiq/pulls/$1/commits | jq -r 'map(.sha) | @sh' | tr "'" " ")

git cherry-pick $commits

BRANCH=cherry_$pr
echo run "'git push production-my $BRANCH:$BRANCH'" when happy with the result

GITLAB_USER=mpovolny

SRC_ID=142
TGT_ID=59
google-chrome-stable "http://gitlab.cloudforms.lab.eng.rdu2.redhat.com/$GITLAB_USER/cfme/merge_requests/new?merge_request[source_branch]=$BRANCH&merge_request[source_project_id]=$SRC_ID&merge_request[target_branch]=5.5.z&merge_request[target_project_id]=$TGT_ID"
