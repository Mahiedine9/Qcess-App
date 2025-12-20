package integration;

import jakarta.servlet.http.Cookie;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.boot.test.mock.mockito.MockBean;
import univ.lille.domain.port.out.EmailPort;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.junit.jupiter.Testcontainers;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@Testcontainers
@SpringBootTest(classes = testsupport.GenericTestApplication.class, properties = {"app.mail.enabled=false"})
@AutoConfigureMockMvc
class TicketControllerIT extends testsupport.AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private univ.lille.infrastructure.adapter.persistence.repository.OrganizationJpaRepository organizationRepo;
    @Autowired
    private univ.lille.infrastructure.adapter.persistence.repository.UserJpaRepository userRepo;
    @Autowired
    private univ.lille.infrastructure.adapter.security.JwtService jwtService;

    @MockBean
    private EmailPort emailPort;

    private static class TestContext {
        Cookie adminCookie;
        String userToken;
    }

        private TestContext createAdminAndUser() {
        TestContext context = new TestContext();

        var org = univ.lille.infrastructure.adapter.persistence.entity.OrganizationEntity.builder()
            .name("ORG-" + java.util.UUID.randomUUID())
            .build();
        org = organizationRepo.save(org);

        var admin = univ.lille.infrastructure.adapter.persistence.entity.UserEntity.builder()
            .email("admin_" + java.util.UUID.randomUUID() + "@test.com")
            .fullName("Admin Test")
            .role(univ.lille.enums.UserRole.ADMIN)
            .status(univ.lille.enums.UserStatus.ACTIVE)
            .organization(org)
            .build();
        admin = userRepo.save(admin);

        var user = univ.lille.infrastructure.adapter.persistence.entity.UserEntity.builder()
            .email("user_" + java.util.UUID.randomUUID() + "@test.com")
            .firstName("User")
            .lastName("Test")
            .role(univ.lille.enums.UserRole.USER)
            .status(univ.lille.enums.UserStatus.ACTIVE)
            .organization(org)
            .build();
        user = userRepo.save(user);

        var orgDomain = univ.lille.domain.model.Organization.builder()
            .id(org.getId())
            .name(org.getName())
            .build();

        var adminDomain = univ.lille.domain.model.User.builder()
            .id(admin.getId())
            .email(admin.getEmail())
            .fullName(admin.getFullName())
            .role(univ.lille.enums.UserRole.ADMIN)
            .organization(orgDomain)
            .build();
        var userDomain = univ.lille.domain.model.User.builder()
            .id(user.getId())
            .email(user.getEmail())
            .firstName("User")
            .lastName("Test")
            .role(univ.lille.enums.UserRole.USER)
            .organization(orgDomain)
            .build();

        String adminJwt = jwtService.generateToken(adminDomain, true);
        String userJwt = jwtService.generateToken(userDomain);

        context.adminCookie = new Cookie("qcess_token", adminJwt);
        context.userToken = userJwt;
        return context;
        }

    private String createUserAndGetTokenViaAdmin() {
        return createAdminAndUser().userToken;
    }
    private Cookie registerAdminAndGetCookie() {
        return createAdminAndUser().adminCookie;
    }

    @Test
    void user_can_create_and_get_own_ticket() throws Exception {
        String token = createUserAndGetTokenViaAdmin();
        String createJson = """
                {
                    \"title\": \"Problème ascenseur\",
                    \"description\": \"L'ascenseur est en panne\",
                    \"priority\": \"NORMAL\"
                }
        """;
        var createResult = mockMvc.perform(post("/api/maintenance/tickets")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(createJson))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.title").value("Problème ascenseur"))
            .andReturn();
        mockMvc.perform(get("/api/maintenance/tickets/me")
                .header("Authorization", "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].title").value("Problème ascenseur"));
    }

    @Test
    void admin_can_get_organization_tickets() throws Exception {
        Cookie adminCookie = registerAdminAndGetCookie();
        mockMvc.perform(get("/api/maintenance/tickets/organization")
                .cookie(adminCookie))
            .andExpect(status().isOk());
    }

    @Test
    void user_can_cancel_own_ticket() throws Exception {
        String token = createUserAndGetTokenViaAdmin();
                String createJson = """
                        {
                            \"title\": \"Problème chauffage\",
                            \"description\": \"Le chauffage ne fonctionne plus\",
                            \"priority\": \"NORMAL\"
                        }
                """;
        var createResult = mockMvc.perform(post("/api/maintenance/tickets")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(createJson))
            .andExpect(status().isCreated())
            .andReturn();
        Number ticketIdNum = com.jayway.jsonpath.JsonPath.read(createResult.getResponse().getContentAsString(), "$.id");
        Long ticketId = ticketIdNum.longValue();
        mockMvc.perform(delete("/api/maintenance/tickets/" + ticketId)
                .header("Authorization", "Bearer " + token))
            .andExpect(status().isOk());
    }

    @Test
    void admin_can_update_ticket_status() throws Exception {
        TestContext context = createAdminAndUser();
                String createJson = """
                        {
                            \"title\": \"Problème lumière\",
                            \"description\": \"La lumière ne marche pas\",
                            \"priority\": \"NORMAL\"
                        }
                """;
        var createResult = mockMvc.perform(post("/api/maintenance/tickets")
                .header("Authorization", "Bearer " + context.userToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(createJson))
            .andExpect(status().isCreated())
            .andReturn();
        Number ticketIdNum = com.jayway.jsonpath.JsonPath.read(createResult.getResponse().getContentAsString(), "$.id");
        Long ticketId = ticketIdNum.longValue();
        
        String updateStatusJson = """
            {
              \"newStatus\": \"RESOLVED\"
            }
        """;
        mockMvc.perform(put("/api/maintenance/tickets/" + ticketId + "/update-status")
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateStatusJson)
                .cookie(context.adminCookie))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("RESOLVED"));
    }
}
