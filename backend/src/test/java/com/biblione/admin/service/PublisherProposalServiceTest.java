package com.biblione.admin.service;

import com.biblione.admin.dto.CreateProposalRequest;
import com.biblione.admin.dto.ReviewProposalRequest;
import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.ProposalStatus;
import com.biblione.admin.model.PublisherProposal;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.admin.repository.PublisherProposalRepository;
import com.biblione.exception.ApiException;
import com.biblione.model.Book;
import com.biblione.repository.BookRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PublisherProposalServiceTest {

    @Mock
    private PublisherProposalRepository proposalRepository;
    @Mock
    private AdminUserRepository userRepository;
    @Mock
    private BookRepository bookRepository;

    @InjectMocks
    private PublisherProposalService service;

        @Test
        void submitCreatesPendingProposalForActiveVendor() {
        AdminUser vendor = AdminUser.builder().id("vendor-1").fullName("North Books")
            .role(UserRole.VENDOR).active(true).build();
        when(userRepository.findById("vendor-1")).thenReturn(Optional.of(vendor));
        when(proposalRepository.save(any(PublisherProposal.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        PublisherProposal proposal = service.submit(new CreateProposalRequest(
            "vendor-1", "Spring Boot Essentials", "A. Author", "9781234567890",
            "Computer Science", "A practical guide", 42.50, 20,
            "https://example.com/cover.jpg"));

        assertThat(proposal.getVendorName()).isEqualTo("North Books");
        assertThat(proposal.getDescription()).isEqualTo("A practical guide");
        assertThat(proposal.getStatus()).isEqualTo(ProposalStatus.PENDING_ADMIN_REVIEW);
        assertThat(proposal.getCreatedAt()).isNotNull();
        verify(proposalRepository).save(any(PublisherProposal.class));
        }

    @Test
    void approvalCreatesInventoryBookUnavailableUntilShelved() {
        PublisherProposal proposal = PublisherProposal.builder()
                .id("proposal-1")
                .bookTitle("Spring Boot Essentials")
                .author("A. Author")
                .vendorName("Biblione Books")
                .category("Computer Science")
                .vendorSupplyQty(20)
                .status(ProposalStatus.PENDING_ADMIN_REVIEW)
                .build();
        when(proposalRepository.findById("proposal-1")).thenReturn(Optional.of(proposal));
        when(bookRepository.save(any(Book.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(proposalRepository.save(any(PublisherProposal.class))).thenAnswer(invocation -> invocation.getArgument(0));

        PublisherProposal reviewed = service.review("proposal-1", new ReviewProposalRequest(true, 15, "Dispatch 15 copies."));

        ArgumentCaptor<Book> bookCaptor = ArgumentCaptor.forClass(Book.class);
        verify(bookRepository).save(bookCaptor.capture());
        assertThat(reviewed.getStatus()).isEqualTo(ProposalStatus.APPROVED);
        assertThat(reviewed.getAdminMessage()).isEqualTo("Dispatch 15 copies.");
        assertThat(bookCaptor.getValue().getTotalCopies()).isEqualTo(15);
        assertThat(bookCaptor.getValue().getAvailableCopies()).isZero();
        assertThat(bookCaptor.getValue().getInventoryStatus()).isEqualTo("PENDING_SHELVING");
    }

    @Test
    void approvalRejectsLotLargerThanVendorSupply() {
        PublisherProposal proposal = PublisherProposal.builder()
                .id("proposal-1")
                .vendorSupplyQty(4)
                .status(ProposalStatus.PENDING_ADMIN_REVIEW)
                .build();
        when(proposalRepository.findById("proposal-1")).thenReturn(Optional.of(proposal));

        assertThatThrownBy(() -> service.review("proposal-1", new ReviewProposalRequest(true, 5, "")))
                .isInstanceOf(ApiException.class);
    }
}
