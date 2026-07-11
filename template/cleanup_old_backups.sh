#!/usr/bin/env bash

# cleanup_old_backups.sh
# 备份成功后 30 分钟执行,删除最旧的 1 个备份,但保留至少 4 个最新
# 由 init.sh 生成的 cron 触发 (每天 4:30)

GH_PAT=
GH_BACKUP_USER=
GH_EMAIL=
GH_REPO=
TEMP_DIR=/tmp/cleanup_backups

########

# version: 2026.06.30

warning() { echo -e "\033[31m\033[01m$*\033[0m"; }
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; }
info() { echo -e "\033[32m\033[01m$*\033[0m"; }
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }

trap "rm -rf $TEMP_DIR; echo -e '\n' ;exit" INT QUIT TERM EXIT

mkdir -p $TEMP_DIR

if [[ -z "$GH_REPO" || -z "$GH_BACKUP_USER" || -z "$GH_PAT" ]]; then
  warning "\n Backup variables not set. Skip cleanup. \n"
  exit 0
fi

IS_PRIVATE="$(wget -qO- --header="Authorization: token $GH_PAT" https://api.github.com/repos/$GH_BACKUP_USER/$GH_REPO | sed -n '/"private":/s/.*:[ ]*\([^,]*\),/\1/gp')"
if [ "$?" != 0 ]; then
  warning "\n Could not connect to Github. Skip cleanup. \n"
  exit 0
elif [ "$IS_PRIVATE" != true ]; then
  warning "\n This is not exist nor a private repository. Skip cleanup. \n"
  exit 0
fi

[ -d /tmp/$GH_REPO-cleanup ] && rm -rf /tmp/$GH_REPO-cleanup
git clone https://$GH_PAT@github.com/$GH_BACKUP_USER/$GH_REPO.git --depth 1 --quiet /tmp/$GH_REPO-cleanup

if [ ! -d /tmp/$GH_REPO-cleanup ]; then
  warning "\n Failed to clone backup repo. Skip cleanup. \n"
  exit 0
fi

cd /tmp/$GH_REPO-cleanup

BACKUP_COUNT=$(find ./ -name '*.gz' | wc -l)
echo "[cleanup] Current backup count: $BACKUP_COUNT"

if [ "$BACKUP_COUNT" -le 4 ]; then
  info "\n Only $BACKUP_COUNT backups (<= 4), keep all. \n"
  exit 0
fi

OLDEST=$(find ./ -name '*.gz' | sort | head -n 1)
if [ -n "$OLDEST" ]; then
  rm -f "$OLDEST"
  info "\n [cleanup] Deleted oldest backup: $OLDEST (count was $BACKUP_COUNT, kept 4+) \n"

  [ -e ./.git/index.lock ] && rm -f ./.git/index.lock
  git config --global user.name $GH_BACKUP_USER
  git config --global user.email $GH_EMAIL
  git add -A
  git commit -m "cleanup: delete oldest backup at $(date '+%F %T')" --quiet
  git push -f -u origin HEAD:main --quiet
  IS_UPLOAD="$?"

  if [ "$IS_UPLOAD" = 0 ]; then
    info "\n [cleanup] Successfully pushed cleanup to GitHub. \n"
  else
    warning "\n [cleanup] Failed to push cleanup to GitHub. \n"
  fi
else
  hint "\n [cleanup] No oldest backup found. \n"
fi

cd ..
rm -rf $GH_REPO-cleanup
