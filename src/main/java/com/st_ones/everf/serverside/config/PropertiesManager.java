/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @author Suhyeong Lee <azure@st-ones.com>
 * @LastModified 17. 11. 22 오전 10:01
 */
package com.st_ones.everf.serverside.config;

import org.apache.commons.configuration.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;

import java.io.*;
import java.util.*;

public class PropertiesManager {

    private static Logger logger = LoggerFactory.getLogger(PropertiesManager.class);
    private static Set<File> resourceFiles = new HashSet<File>();
    private static CompositeConfiguration configuration = new CompositeConfiguration();

    static {

        if (resourceFiles.isEmpty()) {

            configuration.addConfiguration(new SystemConfiguration());
            ResourcePatternResolver pathMatchingResourcePatternResolver = new PathMatchingResourcePatternResolver();
            Resource[] resources;
//            System.err.println("=====================================================================================1");
            try {

                resources = pathMatchingResourcePatternResolver.getResources("classpath*:/*.properties");
                for (Resource resource : resources) {
//                	System.err.println("===============================resource===========1"+resource.getFilename());

                    InputStream inputStream = resource.getInputStream();
                    InputStreamReader inputStreamReader = new InputStreamReader(inputStream);

                    File resourceFile = new File(resource.getFilename());
                    FileWriter fw = new FileWriter(resourceFile);
                    int i;
                    while((i = inputStreamReader.read()) != -1) {
                        fw.write(i);
                    }

                    fw.flush();

                    PropertiesConfiguration propertiesConfiguration = new PropertiesConfiguration(resourceFile);
                    propertiesConfiguration.setEncoding("UTF-8");
                    configuration.addConfiguration(propertiesConfiguration);

                    if (!resourceFiles.contains(resourceFile)) {
                        resourceFiles.add(resourceFile);
                    }
                }

            } catch (IOException e) {
                logger.error(e.getMessage(), e);
            } catch (ConfigurationException e) {
                logger.error(e.getMessage(), e);
            }
        }
    }

    public PropertiesManager() {
        configuration.addConfiguration(new SystemConfiguration());
    }

    public void setLocation(Resource location) {
        this.setLocations(location);
    }

    public void setLocations(Resource... resources) {


//    	System.err.println("===============================setLocations===========2");

        for (Resource resource : resources) {

//        	System.err.println("===============================resource===========2"+resource.getFilename());
        	try {
	            InputStream inputStream = resource.getInputStream();
	            InputStreamReader inputStreamReader = new InputStreamReader(inputStream);

	            File resourceFile = new File(resource.getFilename());
	            FileWriter fw = new FileWriter(resourceFile);
	            int i;
	            while((i = inputStreamReader.read()) != -1) {
	                fw.write(i);
	            }

	            fw.flush();

	            PropertiesConfiguration propertiesConfiguration = new PropertiesConfiguration(resourceFile);
	            propertiesConfiguration.setEncoding("UTF-8");
	            configuration.addConfiguration(propertiesConfiguration);

	            if (!resourceFiles.contains(resourceFile)) {
	                resourceFiles.add(resourceFile);
	            }
            } catch (IOException e) {
                logger.error(e.getMessage(), e);
            } catch (ConfigurationException e) {
                logger.error(e.getMessage(), e);
            }

        }
    }

    public static int getInt(String propName) {
        return getConfiguration().getInt(propName);
    }

    public static int getInt(String propName, int defaultValue) {
        return getConfiguration().getInt(propName, defaultValue);
    }

    public static Integer getInteger(String propName, Integer defaultValue) {
        return getConfiguration().getInteger(propName, defaultValue);
    }

    public static long getLong(String propName) {
        return getConfiguration().getLong(propName);
    }

    public static long getLong(String propName, long defaultValue) {
        return getConfiguration().getLong(propName, defaultValue);
    }

    public static String getString(String propName) {
        return getConfiguration().getString(propName);
    }

    public static String getString(String propName, String defaultValue) {
        return getConfiguration().getString(propName, defaultValue);
    }

    public static boolean getBoolean(String propName) {
        return getConfiguration().getBoolean(propName);
    }

    public static boolean getBoolean(String propName, boolean defaultValue) {
        return getConfiguration().getBoolean(propName, defaultValue);
    }

    private static Configuration getConfiguration() {
        return configuration;
    }

    public static void refresh() {

        if(!resourceFiles.isEmpty()) {

            configuration = new CompositeConfiguration();
            configuration.addConfiguration(new SystemConfiguration());

            for (File resourceFile : resourceFiles) {

                try {

                    logger.info("Reloading properties file: {}", resourceFile.getAbsolutePath());
                    PropertiesConfiguration propertiesConfiguration = new PropertiesConfiguration(resourceFile);
                    propertiesConfiguration.setEncoding("UTF-8");
                    configuration.addConfiguration(propertiesConfiguration);

                } catch (ConfigurationException e) {
                    logger.error(e.getMessage(), e);
                }
            }
        }
    }

    public static Map<String, String> getPropertiesAsMap() {

        Iterator<String> keys = getConfiguration().getKeys();
        HashMap props = new HashMap();

        while (keys.hasNext()) {
            String key = keys.next();
            props.put(key, getString(key));
        }

        return props;
    }

    public static Map<String, String> getPropertiesByPrefixAsMap(String prefix) {
        Iterator<String> keys = getConfiguration().getKeys(prefix);
        HashMap props = new HashMap();

        while (keys.hasNext()) {
            String key = keys.next();
            props.put(key, getString(key));
        }

        return props;
    }
}