ds_format() {
	if [ "$1" = "" ]; then
		error "format: spring-boot: java: Too few arguments given"
	fi

	cd "$1"
	. "./$DS_DIR/config.sh"

	if [ "$SERVICE_PORT" = "" ]; then
		error "package: java: config.sh must specify a SERVICE_PORT"
	fi

	printf "Preparing spring boot deployment ... "
	PATH_TO_JAR=$DEPLOYMENT_DIR'/current/$WARFILE'
	echo "PATH_TO_JAR=\"$PATH_TO_JAR\"" >> deploy-config.sh
	LOG_DIR=$DEPLOYMENT_DIR'/current/logs'
	echo "LOG_DIR=\"$LOG_DIR\"" >> deploy-config.sh
	COMMAND='nohup java -Dspring.profiles.active=$PROJECT_ENVIRONMENT -jar $PATH_TO_JAR --server.port=$SERVICE_PORT /tmp 2>> $LOG_DIR/stderr.log >> $LOG_DIR/stdout.log'
	echo "START_COMMAND=\"$COMMAND\"" >> deploy-config.sh

	cat deploy-config.sh >> ./$DS_DIR/config.sh
	success 'done'
}
