package com.st_ones;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletComponentScan;

@MapperScan
@ServletComponentScan
@SpringBootApplication
public class KakaoPmsSpringBootApplication {

    public static void main(String[] args) {
        SpringApplication.run(KakaoPmsSpringBootApplication.class, args);
    }

}
