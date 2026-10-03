package com.biblione.user.service;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.auth.security.AuthenticatedUser;
import com.biblione.auth.service.AuthService;
import com.biblione.exception.ApiException;
import com.biblione.user.dto.ChangePasswordRequest;
import com.biblione.user.dto.UpdateProfileRequest;
import com.biblione.user.dto.UserResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserProfileServiceTest {

    @Mock
    private AdminUserRepository userRepository;

    @Mock
    private AuthService authService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserProfileService profileService;

    @Test
    void getCurrentProfile_success() {
        AuthenticatedUser currentUser = new AuthenticatedUser(
                "user-1", "IT20240001", "Jane Doe", "jane@biblione.edu",
                UserRole.STUDENT, "CS", "STUDENT", true, "hash-1"
        );

        AdminUser dbUser = AdminUser.builder()
                .id("user-1")
                .universityId("IT20240001")
                .fullName("Jane Doe")
                .email("jane@biblione.edu")
                .role(UserRole.STUDENT)
                .department("Computer Science")
                .userCategory("STUDENT")
                .active(true)
                .build();

        when(userRepository.findById("user-1")).thenReturn(Optional.of(dbUser));

        UserResponse res = profileService.getCurrentProfile(currentUser);

        assertThat(res.id()).isEqualTo("user-1");
        assertThat(res.fullName()).isEqualTo("Jane Doe");
        assertThat(res.department()).isEqualTo("Computer Science");
    }

    @Test
    void updateProfile_success() {
        AuthenticatedUser currentUser = new AuthenticatedUser(
                "user-1", "IT20240001", "Jane Doe", "jane@biblione.edu",
                UserRole.STUDENT, "CS", "STUDENT", true, "hash-1"
        );

        AdminUser dbUser = AdminUser.builder()
                .id("user-1")
                .universityId("IT20240001")
                .fullName("Jane Doe")
                .email("jane@biblione.edu")
                .role(UserRole.STUDENT)
                .active(true)
                .build();

        when(userRepository.findById("user-1")).thenReturn(Optional.of(dbUser));
        when(userRepository.findByEmailIgnoreCase("jane.new@biblione.edu")).thenReturn(Optional.empty());
        when(userRepository.save(any(AdminUser.class))).thenAnswer(i -> i.getArgument(0));

        UpdateProfileRequest req = new UpdateProfileRequest("Jane Updated", "jane.new@biblione.edu", "Data Science");
        UserResponse res = profileService.updateProfile(currentUser, req);

        assertThat(res.fullName()).isEqualTo("Jane Updated");
        assertThat(res.email()).isEqualTo("jane.new@biblione.edu");
        assertThat(res.department()).isEqualTo("Data Science");
    }

    @Test
    void updateProfile_failsOnDuplicateEmailByAnotherUser() {
        AuthenticatedUser currentUser = new AuthenticatedUser(
                "user-1", "IT20240001", "Jane Doe", "jane@biblione.edu",
                UserRole.STUDENT, "CS", "STUDENT", true, "hash-1"
        );

        AdminUser dbUser = AdminUser.builder()
                .id("user-1")
                .email("jane@biblione.edu")
                .active(true)
                .build();

        AdminUser otherUser = AdminUser.builder()
                .id("user-2")
                .email("taken@biblione.edu")
                .active(true)
                .build();

        when(userRepository.findById("user-1")).thenReturn(Optional.of(dbUser));
        when(userRepository.findByEmailIgnoreCase("taken@biblione.edu")).thenReturn(Optional.of(otherUser));

        UpdateProfileRequest req = new UpdateProfileRequest("Jane Updated", "taken@biblione.edu", null);

        assertThatThrownBy(() -> profileService.updateProfile(currentUser, req))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("email already exists");
    }

    @Test
    void changePassword_success() {
        AuthenticatedUser currentUser = new AuthenticatedUser(
                "user-1", "IT20240001", "Jane Doe", "jane@biblione.edu",
                UserRole.STUDENT, "CS", "STUDENT", true, "hash-1"
        );

        AdminUser dbUser = AdminUser.builder()
                .id("user-1")
                .email("jane@biblione.edu")
                .password("old-hash")
                .active(true)
                .build();

        when(userRepository.findById("user-1")).thenReturn(Optional.of(dbUser));
        when(passwordEncoder.matches("oldPass123", "old-hash")).thenReturn(true);
        when(passwordEncoder.encode("newPass123")).thenReturn("new-hash");

        ChangePasswordRequest req = new ChangePasswordRequest("oldPass123", "newPass123", "newPass123");
        profileService.changePassword(currentUser, req);

        assertThat(dbUser.getPassword()).isEqualTo("new-hash");
        verify(userRepository).save(dbUser);
        verify(authService).revokeAllSessionsForUser("user-1");
    }

    @Test
    void changePassword_failsOnWrongCurrentPassword() {
        AuthenticatedUser currentUser = new AuthenticatedUser(
                "user-1", "IT20240001", "Jane Doe", "jane@biblione.edu",
                UserRole.STUDENT, "CS", "STUDENT", true, "hash-1"
        );

        AdminUser dbUser = AdminUser.builder()
                .id("user-1")
                .password("old-hash")
                .active(true)
                .build();

        when(userRepository.findById("user-1")).thenReturn(Optional.of(dbUser));
        when(passwordEncoder.matches("wrongPass", "old-hash")).thenReturn(false);

        ChangePasswordRequest req = new ChangePasswordRequest("wrongPass", "newPass123", "newPass123");

        assertThatThrownBy(() -> profileService.changePassword(currentUser, req))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Current password is incorrect");
    }
}
