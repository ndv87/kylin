***Создание проекта***

1) создать папку $KYLIN_HOME/sample_project2
2) создать папку $KYLIN_HOME/sample_project2/template/_global
3) создать папку $KYLIN_HOME/sample_project2/template/<project_name>

4) создать файл $KYLIN_HOME/sample_project2/template/_global/<project_name.json>
5) отредактировать и внеси в файл информацию (заполнить <project_name> и поправить данные полдклбчения в опциях kylin.source.jdbc):
{
"uuid" : "cc087b95-78b9-f3f6-ee2d-8b4bdc4fbb2a",
"last_modified" : 1632293787433,
"create_time" : 1632293787433,
"version" : "%default_version%",
"name" : "<project_name>",
"owner" : "ADMIN",
"status" : "ENABLED",
"create_time_utc" : 1632293787433,
"default_database" : "PUBLIC",
"description" : "",
"principal" : null,
"keytab" : null,
"maintain_model_type" : "MANUAL_MAINTAIN",
"override_kylin_properties" : {
"kylin.metadata.semi-automatic-mode" : "false",
"kylin.query.metadata.expose-computed-column" : "true",
"kylin.source.default" : "8",
"kylin.source.jdbc.pass" : "123456",
"kylin.source.jdbc.source.name" : "market_explorer",
"kylin.source.jdbc.source.enable" : "true",
"kylin.source.jdbc.connection-url" : "jdbc:postgresql://127.0.0.1:5432/market_explorer",
"kylin.source.jdbc.user" : "admin2",
"kylin.source.jdbc.driver" : "org.postgresql.Driver",
"kylin.source.jdbc.dialect": "postgresql",
"kylin.source.jdbc.convert-to-lowercase":"true",
"kylin.source.jdbc.source.enable": "true"
}
}

6) создать файл в $KYLIN_HOME/bin/sample2.sh

с содержимым:

function help(){
echo "Usage: $0  [--client <hive_client_mode>] [--dir <hdfs_tmp_dir> ] [--params <beeline_params>] [--conf <hive_conf_properties> ]"
exit 1
}

while [[ $# != 0 ]]; do
if [[ $# != 1 ]]; then
if [[ $1 == "--client" ]]; then
hive_client_mode=$2
elif [[ $1 == "--dir" ]]; then
hdfs_tmp_dir=$2
elif [[ $1 == "--params" ]]; then
beeline_params=$2
elif [[ $1 == "--conf" ]]; then
hive_conf_properties=$2
else
help
fi
shift
else
case $1 in
--client|--dir|--params|--conf) break
;;
*)
help
;;
esac
fi
shift
done

source $(cd -P -- "$(dirname -- "$0")" && pwd -P)/../sbin/header.sh

source ${KYLIN_HOME}/sbin/prepare-hadoop-conf-dir.sh


## FusionInsight platform C60.
if [[ -z $hive_client_mode && -n "$FI_ENV_PLATFORM" ]]; then
hive_client_mode=beeline
elif [[ -z $hive_client_mode && -z "$FI_ENV_PLATFORM" ]]; then
hive_client_mode=hive
fi

#set default properties
if [[ -z $hdfs_tmp_dir ]]; then
hdfs_tmp_dir=/tmp/kylin
fi

mkdir -p ${KYLIN_HOME}/sample_project2/sample_model/metadata
rm -rf ${KYLIN_HOME}/sample_project2/sample_model/metadata/*
cp -rf ${KYLIN_HOME}/sample_project2/template/* ${KYLIN_HOME}/sample_project2/sample_model/metadata
rm -rf ${KYLIN_HOME}/sample_project2/sample_model/metadata/learn_kylin2/*


function turn_on_maintain_mode() {
echo "enter maintenance mode."
${KYLIN_HOME}/bin/kylin.sh org.apache.kylin.tool.MaintainModeTool -on -reason 'metastore tool' -hidden-output true
ret=$?
if [[ $ret != 0 ]]; then
exit $ret
fi
}

function turn_off_maintain_mode() {
echo "exit maintenance mode."
${KYLIN_HOME}/bin/kylin.sh org.apache.kylin.tool.MaintainModeTool -off -hidden-output true
}

function printImportResult() {
error=$1
if [[ $error == 0 ]]; then
echo -e "${YELLOW}Sample model is created successfully in project 'learn_kylin'. Detailed Message is at \"logs/shell.stderr\".${RESTORE}"
else
echo -e "${YELLOW}Sample model is created failed in project 'learn_kylin'. Detailed Message is at \"logs/shell.stderr\".${RESTORE}"
fi
}

function importProject() {
turn_on_maintain_mode
${KYLIN_HOME}/bin/kylin.sh org.apache.kylin.tool.SampleProjectTool -dir ${KYLIN_HOME}/sample_project2/sample_model/metadata -project learn_kylin2 -model sample_ssb2
printImportResult $?
turn_off_maintain_mode
}

importProject



7) Скопировать библиотеки
docker cp src/spark-project/source-jdbc/target/kylin-source-jdbc-5.0.0-beta.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/lib/ext

docker cp src/datasource-sdk/target/kylin-datasource-sdk-5.0.0-beta.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/lib/ext

//это постгрес драйвер jdbc
docker cp /home/pc/.local/share/DBeaverData/drivers/maven/maven-central/org.postgresql/postgresql-42.2.25.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/lib/ext


8) если на заведется то докинуть эти библиотеки
docker cp src/datasource-service/target/kylin-datasource-service-5.0.0-beta.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/lib/ext

docker cp src/metadata-server/target/kylin-metadata-server-5.0.0-beta.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/server/jars

docker cp src/modeling-service/target/kylin-modeling-service-5.0.0-beta.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/server/jars

docker cp src/common-service/target/kylin-common-service-5.0.0-beta.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/server/jars

docker cp src/core-metadata/target/kylin-core-metadata-5.0.0-beta.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/server/jars

docker cp src/spark-project/engine-spark/target/kylin-engine-spark-5.0.0-beta.jar angry_jennings:/home/kylin/apache-kylin-5.0.0-bin/lib/ext 

