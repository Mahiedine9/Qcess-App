package univ.lille.module_maintenance.domain.port.out;

import org.springframework.lang.NonNull;
import univ.lille.module_maintenance.domain.model.Ticket;
import java.util.List;
import java.util.Optional;

public interface TicketRepositoryPort {
    
    Ticket save(@NonNull Ticket ticket);
    
    @NonNull
    Optional<Ticket> findById(@NonNull Long id);
    
    @NonNull
    List<Ticket> findByUserId(@NonNull Long userId);
    
    @NonNull
    List<Ticket> findByOrganizationId(@NonNull Long organizationId);
        
    void deleteById(@NonNull Long id);
}