package univ.lille.dto.role;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CustomRoleDTO {
    private Long id ;
    private String name ;
    private String description ;
    private Long organizationId ;
    private Integer userCount ;
    private LocalDateTime createdAt;

}