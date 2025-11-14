package univ.lille.infrastructure.utils;

import org.springframework.stereotype.Service;
import java.security.SecureRandom;
public class CodeGenerator {

    private static  final SecureRandom random = new SecureRandom();

    public static String generateLoginCode() {
        return String.format("%06d", random.nextInt(1000000));
    }
    /*public static String generateOrganizationCode(String orgName) {
        String prefix = orgName.replaceAll("[^A-Z0-9]", "")
                .substring(0, Math.min(4, orgName.length()))
                .toUpperCase();
        return prefix + String.format("%04d", random.nextInt(10000));
    }**/
}
