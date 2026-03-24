package com.ruffinjy.starwave_gateway.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

/**
 * Configuration Spring Security – profil DEV
 *
 * Règles :
 *  - /actuator/**  → public (healthcheck Docker + scrape Prometheus)
 *  - tout le reste → JWT Bearer token obligatoire (Keycloak)
 */
@Configuration
@EnableWebFluxSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        http
            // CSRF désactivé – API REST stateless
            .csrf(csrf -> csrf.disable())

            // Règles d'autorisation
            .authorizeExchange(exchanges -> exchanges
                // Actuator : public en DEV (healthcheck + Prometheus)
                .pathMatchers(
                    "/actuator/**",
                    "/api/actuator/**",
                    "/actuator/health/**",
                    "/api/actuator/health/**",
                    "/actuator/prometheus",
                    "/api/actuator/prometheus"
                ).permitAll()
                // Tout le reste : JWT requis
                .anyExchange().authenticated()
            )

            // Validation JWT via Keycloak (JWKS auto-récupéré)
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> {}));

        return http.build();
    }
}
