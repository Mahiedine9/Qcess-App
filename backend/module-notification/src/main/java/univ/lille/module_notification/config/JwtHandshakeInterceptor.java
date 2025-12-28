package univ.lille.module_notification.config;

import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;
import org.springframework.util.StringUtils;
import jakarta.servlet.http.Cookie;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.stereotype.Component;

import java.util.Map;


@Component
public class JwtHandshakeInterceptor implements HandshakeInterceptor {

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                   WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {

        String token = null;

        if (request instanceof ServletServerHttpRequest servletReq) {
            var http = servletReq.getServletRequest();

            String auth = http.getHeader("Authorization");
            if (StringUtils.hasText(auth) && auth.startsWith("Bearer ")) {
                token = auth.substring(7);
            }

            if (token == null) {
                Cookie[] cookies = http.getCookies();
                if (cookies != null) {
                    for (Cookie c : cookies) {
                        if ("qcess_token".equals(c.getName())) {
                            token = c.getValue();
                            break;
                        }
                    }
                }
            }

            if (token == null && http.getParameter("token") != null) {
                token = http.getParameter("token");
            }
        }

        if (token != null && !token.isBlank()) {
            attributes.put("__jwt_token", token);
        }

        return true;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
                               WebSocketHandler wsHandler, Exception exception) {
    }
}
