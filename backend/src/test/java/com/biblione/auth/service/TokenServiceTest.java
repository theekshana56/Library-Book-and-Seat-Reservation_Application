package com.biblione.auth.service;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class TokenServiceTest {

    private final TokenService service = new TokenService();

    @Test
    void generateTokenCreatesAUniqueUrlSafeToken() {
        String first = service.generateToken();
        String second = service.generateToken();

        assertThat(first).isNotBlank().doesNotContain("=", "+", "/");
        assertThat(first).hasSize(43);
        assertThat(second).isNotEqualTo(first);
    }

    @Test
    void hashTokenIsDeterministicAndTrimsInput() {
        String hash = service.hashToken("  secret-token  ");

        assertThat(hash)
                .isEqualTo(service.hashToken("secret-token"))
                .hasSize(64)
                .matches("[0-9a-f]+");
    }

    @Test
    void hashTokenReturnsEmptyForNullOrBlankInput() {
        assertThat(service.hashToken(null)).isEmpty();
        assertThat(service.hashToken("   ")).isEmpty();
    }
}
