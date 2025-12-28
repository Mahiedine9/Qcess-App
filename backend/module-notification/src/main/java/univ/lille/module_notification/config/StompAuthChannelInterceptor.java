package univ.lille.module_notification.config;

import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import univ.lille.infrastructure.adapter.security.JwtService;
import org.springframework.security.core.userdetails.UserDetailsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.security.core.userdetails.UserDetails;
import univ.lille.infrastructure.adapter.security.QcessUserPrincipal;

import java.security.Principal;
import java.util.List;


@Component
@RequiredArgsConstructor
public class StompAuthChannelInterceptor implements ChannelInterceptor {

    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        if (accessor == null) return message;

        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            List<String> authHeaders = accessor.getNativeHeader("Authorization");
            String token = null;
            if (authHeaders != null && !authHeaders.isEmpty()) {
                var h = authHeaders.get(0);
                if (h != null && h.startsWith("Bearer ")) {
                    token = h.substring(7);
                }
            }

            if (token == null) {
                List<String> tokens = accessor.getNativeHeader("token");
                if (tokens != null && !tokens.isEmpty()) token = tokens.get(0);
            }

            if (token == null) {
                Object attr = accessor.getSessionAttributes() != null ? accessor.getSessionAttributes().get("__jwt_token") : null;
                if (attr instanceof String s) token = s;
            }

            if (token != null && jwtService.validateToken(token)) {
                String email = jwtService.extractEmail(token);
                UserDetails ud = userDetailsService.loadUserByUsername(email);
                final String principalName;
                if (ud instanceof QcessUserPrincipal qup) {
                    principalName = qup.getId() != null ? String.valueOf(qup.getId()) : qup.getUsername();
                } else {
                    principalName = ud.getUsername();
                }
                Principal principal = () -> principalName;
                accessor.setUser(principal);
            }
        }
        return message;
    }
}
