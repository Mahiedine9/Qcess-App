package univ.lille.application.utils;

import java.util.Arrays;

public class NameUtils {

    public static String buildFullName(String firstName, String lastName) {
        return (firstName.trim() + " " + lastName.trim()).trim();
    }

    public static String[] splitFullName(String fullName) {
        String[] parts = fullName.trim().split("\\s+");
        if (parts.length == 1) {
            return new String[]{parts[0], ""};
        }
        String firstName = parts[0];
        String lastName = String.join(" ", Arrays.copyOfRange(parts, 1, parts.length));
        return new String[]{firstName, lastName};
    }
}
