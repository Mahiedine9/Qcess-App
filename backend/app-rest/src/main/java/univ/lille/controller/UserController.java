package univ.lille.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import univ.lille.application.usecase.CreateUserUseCase;
import univ.lille.dto.auth.user.CreateUserRequest;
import univ.lille.dto.auth.user.UserDTO;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    public final CreateUserUseCase createUserUseCase;

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/create-user")
    public ResponseEntity<UserDTO> createUser (@Valid @RequestBody CreateUserRequest createUserRequest) {


        UserDTO userDTO = createUserUseCase.createUser(createUserRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(userDTO);
    }



}
