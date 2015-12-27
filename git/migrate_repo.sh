#!/bin/bash
set -e

# /var/git/migrate_repo.sh

LOCAL_GIT_DIR="/var/git"
REDMINE_GIT_DIR="/var/www/redmine.example.com/data/git"
SCRIPT_NAME=`basename $0`
E_OPTERROR=65

function usage()
{
	echo "USAGE:"
	echo "    $SCRIPT_NAME [repo_name]"
	echo "OPTIONS:"
	echo "    repo_name - name of the existing Git repository."
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

if [ ! -d "${LOCAL_GIT_DIR}/${REPO_NAME}" ]; then
	fatal_error "Error: the repository does not exists!"
fi

# Проверить, что ничего не будет сломано.
if [ -f "${LOCAL_GIT_DIR}/${REPO_NAME}/hooks/post-update" ]; then
	fatal_error "Error: post-update hook already exists! The repository already migrated or should be migrated manually."
fi

if [ -d "${REDMINE_GIT_DIR}/${REPO_NAME}" ]; then
	fatal_error "Error: redmine already contains the repository with the same name!"
fi

# Установить хук синхронизирующий Redmine копию репозитория с данным.
cp "${LOCAL_GIT_DIR}/post-update" "${LOCAL_GIT_DIR}/${REPO_NAME}/hooks/"
chown nginx:nginx "${LOCAL_GIT_DIR}/${REPO_NAME}/hooks/post-update"
chmod 755 "${LOCAL_GIT_DIR}/${REPO_NAME}/hooks/post-update"

# Создать Redmine копию репозитория.
cd "${REDMINE_GIT_DIR}"
git clone --mirror "${LOCAL_GIT_DIR}/${REPO_NAME}" ${REPO_NAME}

echo "Git repository successfully migrated."
exit 0
