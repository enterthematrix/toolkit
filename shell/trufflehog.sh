#!/bin/bash
GITHUB_REPO=$1
trufflehog git ${GITHUB_REPO} --only-verified

# alias check='~/workspace/scratchpad/shell/trufflehog.sh'