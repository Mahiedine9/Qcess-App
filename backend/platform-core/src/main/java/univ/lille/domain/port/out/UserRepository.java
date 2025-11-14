package univ.lille.domain.port.out;

import univ.lille.domain.model.User;
import java.util.Optional;
import java.util.List;

public interface UserRepository {
    User save(User user);
    Optional<User> findById(Long id);
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findAll();
    List<User> findByOrganizationId(Long organizationId);

    void deleteUser(User user);



}
