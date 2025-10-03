#!/usr/bin/env bash
set -eu

REPO=cloudve
BRANCH=$(git branch --show-current)

while [[ $# -gt 0 ]] ; do
	case $1 in
		-r|--repo) REPO=$2 ; shift ;;
		-b|--branch) BRANCH=$2 ; shift ;;
		-h|--help|help)
			echo "$(basename $(realpath $0)) [-b|--branch BRANCH] [-r|--repo REPO] "
			exit 0
			;;
		*) 
			echo "Invalid option $1"
			exit 1;
			;;
	esac
	shift
done
helm repo index . --url https://raw.githubusercontent.com/$REPO/helm-charts/$BRANCH/