package com.ruffinjy.starwave_gateway;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest(webEnvironment = WebEnvironment.NONE)
@TestPropertySource(properties = {
    "spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:9999",
    "spring.autoconfigure.exclude=org.springframework.cloud.gateway.config.GatewayAutoConfiguration"
})

class StarwaveApplicationTests {

    @Test
    void contextLoads() {}

}