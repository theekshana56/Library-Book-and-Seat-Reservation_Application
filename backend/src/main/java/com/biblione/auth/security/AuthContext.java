package com.biblione.auth.security;

public final class AuthContext {

    private static final ThreadLocal<AuthenticatedUser> CURRENT_USER = new ThreadLocal<>();

    private AuthContext() {}

    public static void setCurrentUser(AuthenticatedUser user) {
        CURRENT_USER.set(user);
    }

    public static AuthenticatedUser getCurrentUser() {
        return CURRENT_USER.get();
    }

    public static void clear() {
        CURRENT_USER.remove();
    }
}
