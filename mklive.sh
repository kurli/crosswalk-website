#!/bin/bash

git diff-files --quiet --ignore-submodules || {
	echo "Can't go live with uncommitted changes."
	git diff-files --name-status -r --ignore-submodules
	exit 1
}

git diff-index --cached --quiet HEAD --ignore-submodules || {
	echo "Can't go live with uncommitted changes."
	git diff-index --cached --name-status -r --ignore-submodules HEAD
	exit 1
}

git branch | grep -q '\* live' || {
	echo ""
	echo "mklive.sh can only be run in the 'live' branch."
	echo "$ git checkout live"
	echo ""
	exit
}

require_clean_work_tree "Can't go live."

./cleanup.sh
./generate.sh
cat << EOF > .htaccess
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} -f
RewriteRule ^(\..*) %{REQUEST_URI}$1 [R=404]
EOF