#!/bin/bash

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
