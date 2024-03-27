package com.st_ones.configuration;//package com.st_ones.configuration;
//
//import com.zaxxer.hikari.HikariConfig;
//import com.zaxxer.hikari.HikariDataSource;
//import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.mapping.VendorDatabaseIdProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Properties;

//import org.mybatis.spring.SqlSessionFactoryBean;
//import org.mybatis.spring.SqlSessionTemplate;
//import org.springframework.boot.context.properties.ConfigurationProperties;
//import org.springframework.context.ApplicationContext;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//
//import javax.sql.DataSource;
//
//import org.springframework.context.annotation.PropertySource;
//
//import javax.sql.DataSource;
//import java.sql.Connection;
//import java.util.Properties;
//
@Configuration
public class MybatisConfiguration {

    @Bean
    public VendorDatabaseIdProvider getVendorDatabaseIdProvider() {

        VendorDatabaseIdProvider vendorDatabaseIdProvider = new VendorDatabaseIdProvider();

        Properties properties = new Properties();
        properties.put("SQL Server", "mssql");
        properties.put("Oracle", "oracle");
        properties.put("MySQL", "mysql");
        vendorDatabaseIdProvider.setProperties(properties);

        return vendorDatabaseIdProvider;
    }


//
//    private final ApplicationContext applicationContext;
//
//    public MybatisConfiguration(ApplicationContext applicationContext) {
//        this.applicationContext = applicationContext;
//    }
//
//    @Bean
//    @ConfigurationProperties(prefix = "spring.datasource.hikari")
//    public HikariConfig hikariConfig() {
//        return new HikariConfig();
//    }
//
//    @Bean
//    public DataSource dataSource() throws Exception {
//        DataSource dataSource = new HikariDataSource(hikariConfig());
//        return dataSource;
//    }
//
//    @Bean
//    public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
//
//        SqlSessionFactoryBean sqlSessionFactory = new SqlSessionFactoryBean();
//        sqlSessionFactory.setDataSource(dataSource);
//        sqlSessionFactory.setMapperLocations(applicationContext.getResource("classpath:mappers/**/*.xml"));
//
//        VendorDatabaseIdProvider vendorDatabaseIdProvider = new VendorDatabaseIdProvider();
//        Properties prop = new Properties();
//        prop.put("mysql", "mysql");
//        vendorDatabaseIdProvider.setProperties(prop);
//        sqlSessionFactory.setDatabaseIdProvider(vendorDatabaseIdProvider);
//
//        return sqlSessionFactory.getObject();
//    }
//
//    @Bean
//    public SqlSessionTemplate sqlSessionTemplate(SqlSessionFactory sqlSessionFactory) {
//        return new SqlSessionTemplate(sqlSessionFactory);
//    }
}
