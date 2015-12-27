#!/bin/bash
set -e

# /var/git/create_repo.sh

LOCAL_GIT_DIR="/var/git"
SCRIPT_NAME=`basename $0`
E_OPTERROR=65

function usage()
{
	echo "USAGE:"
	echo "    $SCRIPT_NAME [repo_name]"
	echo "OPTIONS:"
	echo "    repo_name - name of the new Git repository."
	exit $E_OPTERROR
}

function fatal_error()
{
	echo "$1" > /dev/stderr
	exit 1
}

# Проверить входные параметры.
if [ $# -ne 1 ]; then
	echo "Wrong number of arguments specified."
	usage
fi

REPO_NAME=$1

cd ${LOCAL_GIT_DIR}
if [ -d "${REPO_NAME}" ]; then
	fatal_error "Error: the repository already exists!"
fi

# Создать чистый репозиторий.
mkdir ${REPO_NAME}
cd ${REPO_NAME}
git --bare init
git update-server-info -f

# Установить хук синхронизирующий Redmine копию репозитория с данным.
cd ..
cp ./post-update "${REPO_NAME}/hooks/"
chmod 755 "${REPO_NAME}/hooks/post-update"
chown -R nginx:nginx ${REPO_NAME}

echo "Git repository successfully created."
exit 0
