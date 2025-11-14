package univ.lille.domain.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CustomRole {
    private Long id ;
    private String name ;
    private  String description ;
    private Organization organization ;
    private LocalDateTime createdAt;


}
