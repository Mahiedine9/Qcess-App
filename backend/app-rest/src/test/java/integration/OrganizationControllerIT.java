package integration;

import jakarta.servlet.http.Cookie;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.context.annotation.Import;
import org.testcontainers.junit.jupiter.Testcontainers;

import com.jayway.jsonpath.JsonPath;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Testcontainers
@SpringBootTest(classes = testsupport.GenericTestApplication.class, properties = {
    "app.mail.enabled=false"
})
@AutoConfigureMockMvc
class OrganizationControllerIT extends testsupport.AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    private Cookie registerAndLoginAdmin() throws Exception {
        String email = "admin_" + java.util.UUID.randomUUID() + "@test.com";
        String registerJson = String.format("""
            {
              \"email\": \"%s\",
              \"password\": \"Password1!\",
              \"organizationName\": \"ORG\",
              \"fullName\": \"Admin User\"
            }
        """, email);
        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(registerJson))
            .andExpect(status().isOk());
        String loginJson = String.format("""
            {
              \"email\": \"%s\",
              \"password\": \"Password1!\",
              \"rememberMe\": true
            }
        """, email);
        var loginResult = mockMvc.perform(post("/api/auth/login/web")
                .contentType(MediaType.APPLICATION_JSON)
                .content(loginJson))
            .andExpect(status().isOk())
            .andReturn();
        String setCookie = loginResult.getResponse().getHeader("Set-Cookie");
        String qcessToken = null;
        if (setCookie != null) {
            for (String cookie : setCookie.split(";")) {
                if (cookie.trim().startsWith("qcess_token=")) {
                    qcessToken = cookie.trim().substring("qcess_token=".length());
                    break;
                }
            }
        }
        org.assertj.core.api.Assertions.assertThat(qcessToken).isNotNull();
        return new Cookie("qcess_token", qcessToken);
    }

    @Test
    void should_update_org_details() throws Exception {
        Cookie authCookie = registerAndLoginAdmin();
        String updateJson = """
            {
              \"organizationId\": 1,
              \"name\": \"ORG_UPDATED\"
            }
        """;
        mockMvc.perform(patch("/api/organizations/update-details")
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateJson)
                .cookie(authCookie))
            .andExpect(status().isOk())
            .andExpect(content().string(containsString("updated successfully")));
    }

    @Test
    void should_get_custom_roles() throws Exception {
        Cookie authCookie = registerAndLoginAdmin();
        mockMvc.perform(get("/api/organizations/roles")
                .cookie(authCookie))
            .andExpect(status().isOk())
            .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON));
    }

    @Test
    void should_create_and_update_custom_role() throws Exception {
        Cookie authCookie = registerAndLoginAdmin();
        String createJson = """
            {
              \"name\": \"Manager\",
              \"description\": \"Manager role\"
            }
        """;
        var createResult = mockMvc.perform(post("/api/organizations/create-custom-role")
                .contentType(MediaType.APPLICATION_JSON)
                .content(createJson)
                .cookie(authCookie))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("Manager"))
            .andReturn();
        String response = createResult.getResponse().getContentAsString();
        Integer roleId = JsonPath.read(response, "$.id");
        String updateJson = """
            {
              \"name\": \"ManagerUpdated\",
              \"description\": \"Updated desc\"
            }
        """;
        mockMvc.perform(patch("/api/organizations/update-custom-role/" + roleId)
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateJson)
                .cookie(authCookie))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("ManagerUpdated"));
    }
}
