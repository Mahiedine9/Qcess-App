package integration;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@ComponentScan(basePackages = "univ.lille")
@EnableJpaRepositories(basePackages = "univ.lille")
@EntityScan(basePackages = "univ.lille")
@EnableAsync
@EnableScheduling
public class TestMaintenanceApplication {}