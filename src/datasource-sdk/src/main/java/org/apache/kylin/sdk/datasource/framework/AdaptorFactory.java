/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.kylin.sdk.datasource.framework;

import java.lang.reflect.Constructor;

import org.apache.kylin.sdk.datasource.adaptor.AbstractJdbcAdaptor;
import org.apache.kylin.sdk.datasource.adaptor.AdaptorConfig;

public class AdaptorFactory {
    public static AbstractJdbcAdaptor createJdbcAdaptor(String adaptorClazz, AdaptorConfig jdbcConf) throws Exception {
        Constructor<?>[] list = Class.forName(adaptorClazz).getConstructors();
        System.out.println("AbstractJdbcAdaptor.list length: " + list.length);
        for (Constructor<?> c : list) {
            System.out.println("c.getParameterTypes().length == 1: " + c.getParameterTypes().length);
            if (c.getParameterTypes().length == 1) {
                if (c.getParameterTypes()[0] == AdaptorConfig.class) {
                    System.out.println("c.getParameterTypes()[0] == AdaptorConfig.class");
                    System.out.println("AbstractJdbcAdaptor jdbcConf.getOptions(): ");
                    jdbcConf.getOptions().entrySet().forEach(e -> System.out.println(e.getKey() + ": " + e.getValue()));

                    System.out.println("c.getName(): " + c.getName());

                    AbstractJdbcAdaptor adp = (AbstractJdbcAdaptor) c.newInstance(jdbcConf);

                    System.out.println("adp: " + adp.getJdbcDriver());

                    return adp; // adaptor with kylin AdaptorConfig
                } else {
                    System.out.println("c.getParameterTypes()[0] != AdaptorConfig.class");
                    // Compatible with old adaptors with kap AdaptorConfig
                    String configClassName = "org.apache.kylin.sdk.datasource.adaptor.AdaptorConfig";
                    AdaptorConfig conf = (AdaptorConfig) Class.forName(configClassName)
                            .getConstructor(String.class, String.class, String.class, String.class)
                            .newInstance(jdbcConf.url, jdbcConf.driver, jdbcConf.username, jdbcConf.password);
                    conf.poolMaxIdle = jdbcConf.poolMaxIdle;
                    conf.poolMinIdle = jdbcConf.poolMinIdle;
                    conf.poolMaxTotal = jdbcConf.poolMaxTotal;
                    conf.datasourceId = jdbcConf.datasourceId;

                    System.out.println("AbstractJdbcAdaptor jdbcConf.getOptions(): ");
                    jdbcConf.getOptions().entrySet().forEach(e -> System.out.println(e.getKey() + ": " + e.getValue()));

                    AbstractJdbcAdaptor adp = (AbstractJdbcAdaptor) c.newInstance(conf);

                    System.out.println("adp: " + adp.getJdbcDriver());

                    return (AbstractJdbcAdaptor) c.newInstance(conf);
                }
            }
        }
        throw new NoSuchMethodException();
    }
}
