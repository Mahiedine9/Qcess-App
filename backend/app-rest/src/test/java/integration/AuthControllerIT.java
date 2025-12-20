package integration;

import jakarta.servlet.http.Cookie;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.boot.test.mock.mockito.MockBean;
import univ.lille.domain.port.out.EmailPort;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.UUID;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Testcontainers
@SpringBootTest(classes = testsupport.GenericTestApplication.class)
@AutoConfigureMockMvc
class AuthControllerIT extends testsupport.AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private EmailPort emailPort;

    /* =========================
       UTILS
       ========================= */

    private String registerUser() throws Exception {
        String email = "admin_" + UUID.randomUUID() + "@test.com";

        String json = String.format("""
            {
              "email": "%s",
              "password": "Password1!",
              "organizationName": "ORG",
              "fullName": "Admin User"
            }
        """, email);

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
            .andExpect(status().isOk());

        return email;
    }

    private Cookie loginAndGetCookie(String email) throws Exception {
        String json = String.format("""
            {
              "email": "%s",
              "password": "Password1!",
              "rememberMe": true
            }
        """, email);

        var result = mockMvc.perform(post("/api/auth/login/web")
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
            .andExpect(status().isOk())
            .andExpect(header().exists("Set-Cookie"))
            .andReturn();

        return result.getResponse().getCookie("qcess_token");
    }

    /* =========================
       TESTS
       ========================= */

    @Test
    void should_register_user() throws Exception {
        String email = registerUser();

        assert email != null;
    }

    @Test
    void should_login_user() throws Exception {
        String email = registerUser();

        Cookie cookie = loginAndGetCookie(email);

        assert cookie != null;
    }

    @Test
    void should_logout_user() throws Exception {
        String email = registerUser();
        Cookie authCookie = loginAndGetCookie(email);

        mockMvc.perform(post("/api/auth/logout")
                .cookie(authCookie))
            .andExpect(status().isOk())
            .andExpect(header().string("Set-Cookie", containsString("qcess_token=")));
    }

    @Test
    void should_forgot_password_even_if_user_exists() throws Exception {
        String email = registerUser();

        String json = String.format("""
            {
              "email": "%s"
            }
        """, email);

        mockMvc.perform(post("/api/auth/forgot-password")
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
            .andExpect(status().isOk())
            .andExpect(content().string(
                    containsString("email de réinitialisation")
            ));
    }
}
