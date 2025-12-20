package testsupport;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
public abstract class AbstractIntegrationTest {
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    @DynamicPropertySource
    static void overrideProps(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
        registry.add("hibernate.hbm2ddl.auto", () -> "create-drop");
        registry.add("spring.jpa.database-platform", () -> "org.hibernate.dialect.PostgreSQLDialect");
        registry.add("jwt.secret", () -> "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF");
        registry.add("jwt.expiration", () -> "3600000");
        registry.add("jwt.expiration-remember-me", () -> "604800000");
        registry.add("app.mail.from", () -> "no-reply@test.local");
        registry.add("app.mail.fromName", () -> "QCess Test");
        registry.add("app.mail.enabled", () -> "false");
    }
}
