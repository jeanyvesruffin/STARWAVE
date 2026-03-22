package com.ruffinjy.starwave_backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
// Disable security for context loading test:
@TestPropertySource(properties = {
    "spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:9999",
    "spring.batch.job.enabled=false",
    "spring.kafka.bootstrap-servers=localhost:9092"
})
class StarwaveApplicationTests {
    @Test
    void contextLoads() {}
}