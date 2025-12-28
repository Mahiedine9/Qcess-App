package univ.lille.module_maintenance.infrastructure.jpa;

import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import univ.lille.module_maintenance.domain.model.Ticket;
import univ.lille.module_maintenance.domain.port.out.TicketRepositoryPort;
import univ.lille.module_maintenance.infrastructure.dao.TicketDao;
import univ.lille.module_maintenance.infrastructure.mapper.TicketMapper;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TicketRepositoryAdapter implements TicketRepositoryPort {

    private final TicketRepositoryJpa jpa;

    @Override
    @Transactional
    public Ticket save(@NonNull Ticket ticket) {
        TicketDao ticketDao = TicketMapper.toDao(ticket);
        TicketDao savedDao = jpa.save(ticketDao);
        return TicketMapper.toDomain(savedDao);
    }

    @Override
    @NonNull
    public Optional<Ticket> findById(@NonNull Long id) {
        return jpa.findById(id)
                .map(TicketMapper::toDomain);
    }

    @Override
    @NonNull
    public List<Ticket> findByUserId(@NonNull Long userId) {
        List<TicketDao> ticketDaos = jpa.findByCreatedByUserId(userId);
        return TicketMapper.toDomainList(ticketDaos);
    }

    @Override
    @NonNull
    public List<Ticket> findByOrganizationId(@NonNull Long organizationId) {
        List<TicketDao> ticketDaos = jpa.findByOrganizationId(organizationId);
        return TicketMapper.toDomainList(ticketDaos);
    }

    @Override
    @Transactional
    public void deleteById(@NonNull Long id) {
        jpa.deleteById(id);
    }
}