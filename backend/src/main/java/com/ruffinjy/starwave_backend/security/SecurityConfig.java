package com.ruffinjy.starwave_backend.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Configuration Spring Security – profil DEV
 *
 * Règles :
 *  - /actuator/**  → public (healthcheck Docker + scrape Prometheus)
 *  - tout le reste → JWT Bearer token obligatoire (Keycloak)
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
 
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // Pas de session HTTP – API stateless
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
 
            // CSRF désactivé – API REST stateless
            .csrf(csrf -> csrf.disable())
 
            // Règles d'autorisation
            .authorizeHttpRequests(auth -> auth
                // ── Actuator : public en DEV (healthcheck + Prometheus) ──
                .requestMatchers("/actuator/**").permitAll()
                .requestMatchers("/actuator/health/**").permitAll()
                .requestMatchers("/actuator/prometheus").permitAll()
                // ── Tout le reste : JWT requis ──
                .anyRequest().authenticated()
            )
 
            // Validation JWT via Keycloak (JWKS auto-récupéré)
            .oauth2ResourceServer(oauth2 ->
                oauth2.jwt(jwt -> {}));
 
        return http.build();
    }
}
