package com.st_ones.configuration;

import com.st_ones.common.interceptor.AttributeInterceptor;
import com.st_ones.common.interceptor.ScreenInterceptor;
import com.st_ones.common.interceptor.SessionInterceptor;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class EverMvcConfiguration implements WebMvcConfigurer {

    private final ApplicationContext applicationContext;

    public EverMvcConfiguration(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {

        SessionInterceptor sessionInterceptor = new SessionInterceptor();
        sessionInterceptor.setNoSessionRedirectUrl("/");
        registry.addInterceptor(sessionInterceptor)
                .addPathPatterns("/logout", "/home", "/common/**", "/grid/**", "/eversrm/**", "/evermp/**")
                .excludePathPatterns("/");

        ScreenInterceptor screenInterceptor = new ScreenInterceptor(this.applicationContext);
        registry.addInterceptor(screenInterceptor)
                .addPathPatterns("/**/view");

        AttributeInterceptor attributeInterceptor = new AttributeInterceptor();
        registry.addInterceptor(attributeInterceptor)
                .addPathPatterns("/**/view");

        WebMvcConfigurer.super.addInterceptors(registry);
    }
}
