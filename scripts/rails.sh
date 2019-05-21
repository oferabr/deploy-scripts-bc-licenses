#!/bin/sh

set -e

SCRIPT_PATH=$(dirname $(readlink -f $0))

if [ "$PROJECT_ENVIRONMENT" = "" ]; then
	echo "No PROJECT_ENVIRONMENT supplied to java deploy script"
	exit
fi

. $SCRIPT_PATH/../app-config.sh
. $SCRIPT_PATH/../$PROJECT_ENVIRONMENT/config.sh

mkdir -p $SCRIPT_PATH/../work/deploy-repo
cd $SCRIPT_PATH/../work/repo
git --work-tree=../deploy-repo --git-dir=.git checkout -f
cd $SCRIPT_PATH/../work/deploy-repo/config
mkdir -p deploy
cd deploy/
PID_PATH='$HOME/sites/$SERVICE_NAME/$PROJECT_ENVIRONMENT/$SERVICE_NAME.pid'
SOCKET_PATH='unix://$HOME/sites/$SERVICE_NAME/$PROJECT_ENVIRONMENT/current/tmp/$SERVICE_NAME.sock'
if [ "$SERVICE_PORT" = "" ]; then
	COMMAND='$HOME/.rbenv/bin/rbenv exec bundle exec puma -C config/puma.rb --environment=$PROJECT_ENVIRONMENT --bind=$SOCKET_PATH --pidfile=$PID_PATH --daemon && sleep 4'
else
	COMMAND='$HOME/.rbenv/bin/rbenv exec bundle exec puma -C config/puma.rb --environment=$PROJECT_ENVIRONMENT -p $SERVICE_PORT --pidfile=$PID_PATH --daemon && sleep 4'
fi
cat $SCRIPT_PATH/../app-config.sh $SCRIPT_PATH/../$PROJECT_ENVIRONMENT/config.sh > config.sh
echo "PID_PATH=\"$PID_PATH\"" >> config.sh
echo "SOCKET_PATH=\"$SOCKET_PATH\"" >> config.sh
echo "START_COMMAND=\"$COMMAND\"" >> config.sh
cp $SCRIPT_PATH/run.sh ./
cd $SCRIPT_PATH/../work/deploy-repo
git init
git config user.name "deployer"
git config user.email "techgroup@loanstreet.com.my"
git add .
git commit . -m "files for deployment"
