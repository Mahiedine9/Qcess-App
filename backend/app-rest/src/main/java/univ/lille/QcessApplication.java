package univ.lille;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;



@SpringBootApplication
@EnableJpaRepositories(basePackages = "univ.lille")
@EntityScan(basePackages = "univ.lille")
// @EnableKafka
// @EnableScheduling
public class QcessApplication {

    private static final Logger log = LoggerFactory.getLogger(QcessApplication.class);

    public static void main(String[] args) {
        ConfigurableApplicationContext ctx = SpringApplication.run(QcessApplication.class, args);

        log.info("Qcess backend started ");
        log.info("Active profiles: {}", String.join(", ", ctx.getEnvironment().getActiveProfiles()));
        log.info("Beans loaded: {}", ctx.getBeanDefinitionCount());
    }
}
