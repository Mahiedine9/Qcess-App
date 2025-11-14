package univ.lille.domain.port.out;

public interface EmailPort {
    void sendWelcomeEmail(String to, String firstName , String loginCode);
    void sendAdminWelcomeEmail(String to, String fullName , String organizationName);

}
