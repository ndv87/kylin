#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${DIR}
echo "build image in dir "${DIR}

# TODO: download from the official website
echo "package kylin in local for building image"
rm -rf ${DIR}/package/*
if [[ ! -d ${DIR}/package/ ]]; then
    mkdir -p ${DIR}/package/
fi
if [[ ! -d ${DIR}/package/libs ]]; then
    mkdir -p ${DIR}/package/libs
fi
${DIR}/../../../build/release/release.sh
cp ${DIR}/../../../dist/apache-kylin-*.tar.gz ${DIR}/package/

cp ~/.m2/repository/com/h2database/h2/1.4.196/h2-1.4.196.jar ${DIR}/package/libs
cp ../../metadata-server/target/kylin-metadata-server-5.0.0-beta.jar ${DIR}/package/libs
cp ../../modeling-service/target/kylin-modeling-service-5.0.0-beta.jar ${DIR}/package/libs
cp ../../common-service/target/kylin-common-service-5.0.0-beta.jar ${DIR}/package/libs
cp ../../core-metadata/target/kylin-core-metadata-5.0.0-beta.jar ${DIR}/package/libs

cp ~/.m2/repository/org/postgresql/postgresql/42.4.1/postgresql-42.4.1.jar ${DIR}/package/libs
cp ../../spark-project/source-jdbc/target/kylin-source-jdbc-5.0.0-beta.jar ${DIR}/package/libs
cp ../../datasource-sdk/target/kylin-datasource-sdk-5.0.0-beta.jar ${DIR}/package/libs
cp ../../datasource-service/target/kylin-datasource-service-5.0.0-beta.jar ${DIR}/package/libs
cp ../../spark-project/engine-spark/target/kylin-engine-spark-5.0.0-beta.jar ${DIR}/package/libs


echo "start to build Hadoop docker image"
docker build -f Dockerfile_hadoop -t hadoop3.2.1-all-in-one-for-kylin5 .
docker build -f Dockerfile_kylin -t apachekylin/apache-kylin-standalone:5.0.0-beta .
