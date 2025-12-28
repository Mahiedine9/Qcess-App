package univ.lille.module_dashboard.application.usecase;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import univ.lille.domain.model.AccessLog;
import univ.lille.domain.model.User;
import univ.lille.domain.model.Zone;
import univ.lille.domain.port.out.AccessLogRepository;
import univ.lille.domain.port.out.UserRepository;
import univ.lille.domain.port.out.ZoneRepository;
import univ.lille.dto.DashboardStatsDTO;
import univ.lille.enums.UserRole;
import univ.lille.enums.UserStatus;
import univ.lille.module_dashboard.domain.port.DashboardPort;
import univ.lille.module_maintenance.domain.model.Priority;
import univ.lille.module_maintenance.domain.model.Status;
import univ.lille.module_maintenance.domain.model.Ticket;
import univ.lille.module_maintenance.domain.port.out.TicketRepositoryPort;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardUseCase implements DashboardPort {
    
    private final AccessLogRepository accessLogRepository;
    private final UserRepository userRepository;
    private final ZoneRepository zoneRepository;
    private final TicketRepositoryPort ticketRepository;

    @Override
    public DashboardStatsDTO getDashboardStats(Long organizationId) {
        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        LocalDateTime endOfToday = LocalDate.now().atTime(LocalTime.MAX);
        LocalDateTime startOfYesterday = LocalDate.now().minusDays(1).atStartOfDay();
        LocalDateTime endOfYesterday = LocalDate.now().minusDays(1).atTime(LocalTime.MAX);
        
        List<AccessLog> accessLogs = accessLogRepository.findByOrganizationId(organizationId);
        
        long accessToday = accessLogs.stream()
            .filter(log -> log.getTimestamp().isAfter(startOfToday) && log.getTimestamp().isBefore(endOfToday))
            .count();
            
        long accessYesterday = accessLogs.stream()
            .filter(log -> log.getTimestamp().isAfter(startOfYesterday) && log.getTimestamp().isBefore(endOfYesterday))
            .count();
            
        double percentageChange = 0.0;
        if (accessYesterday > 0) {
            percentageChange = ((double) (accessToday - accessYesterday) / accessYesterday) * 100;
        }
        
        // Utilisateurs actifs (ceux qui ont le statut ACTIVE et ne sont pas ADMIN)
        List<User> allUsers = userRepository.findByOrganizationId(organizationId);
        long activeUsers = allUsers.stream()
            .filter(user -> user.getUserStatus() == UserStatus.ACTIVE)
            .filter(user -> user.getRole() != UserRole.ADMIN)
            .count();
        
        // Nouveaux utilisateurs cette semaine (hors ADMIN)
        LocalDateTime startOfWeek = LocalDate.now().with(java.time.DayOfWeek.MONDAY).atStartOfDay();
        long newUsersThisWeek = allUsers.stream()
            .filter(user -> user.getRole() != UserRole.ADMIN)
            .filter(user -> user.getCreatedAt() != null && user.getCreatedAt().isAfter(startOfWeek))
            .count();
        
        // Tickets ouverts et urgents
        List<Ticket> tickets = ticketRepository.findByOrganizationId(organizationId);
        
        long openTickets = tickets.stream()
            .filter(t -> t.getStatus() == Status.OPEN || t.getStatus() == Status.IN_PROGRESS)
            .count();
            
        long urgentTickets = tickets.stream()
            .filter(t -> (t.getStatus() == Status.OPEN || t.getStatus() == Status.IN_PROGRESS))
            .filter(t -> t.getPriority() == Priority.HIGH)
            .count();
        
        // Zones configurées et top 3
        List<Zone> zones = zoneRepository.findByOrganizationId(organizationId);
        long configuredZones = zones.size();
        
        // Top 3 zones par nombre d'accès
        Map<String, Long> zoneAccessCount = accessLogs.stream()
            .filter(log -> log.getZoneName() != null)
            .collect(Collectors.groupingBy(AccessLog::getZoneName, Collectors.counting()));
        
        String topZones = zoneAccessCount.entrySet().stream()
            .sorted((e1, e2) -> Long.compare(e2.getValue(), e1.getValue()))
            .limit(3)
            .map(entry -> entry.getKey() + " (" + entry.getValue() + ")")
            .collect(Collectors.joining(", "));
        
        return DashboardStatsDTO.builder()
            .accessToday(accessToday)
            .accessYesterday(accessYesterday)
            .accessPercentageChange(percentageChange)
            .activeUsers(activeUsers)
            .newUsersThisWeek(newUsersThisWeek)
            .openTickets(openTickets)
            .urgentTickets(urgentTickets)
            .configuredZones(configuredZones)
            .topZones(topZones)
            .build();
    }
}
