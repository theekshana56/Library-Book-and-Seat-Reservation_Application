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
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PublisherProposalService {

    private final PublisherProposalRepository proposalRepository;
    private final AdminUserRepository userRepository;
    private final BookRepository bookRepository;

    public PublisherProposal submit(CreateProposalRequest request) {
        AdminUser vendor = userRepository.findById(request.vendorId())
                .filter(user -> user.isActive() && user.getRole() == UserRole.VENDOR)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "The selected account is not an active vendor."));
        return proposalRepository.save(PublisherProposal.builder()
                .vendorId(vendor.getId())
                .vendorName(vendor.getFullName())
                .bookTitle(request.bookTitle().trim())
                .author(request.author().trim())
                .isbn(request.isbn())
                .category(request.category().trim())
                .description(request.description())
                .proposedPrice(request.proposedPrice())
                .vendorSupplyQty(request.vendorSupplyQty())
                .sampleCoverImageUrl(request.sampleCoverImageUrl())
                .status(ProposalStatus.PENDING_ADMIN_REVIEW)
                .createdAt(LocalDateTime.now())
                .build());
    }

    public List<PublisherProposal> getVendorProposals(String vendorId) {
        return proposalRepository.findByVendorIdOrderByCreatedAtDesc(vendorId);
    }

    public List<PublisherProposal> getAllProposals() {
        return proposalRepository.findAllByOrderByCreatedAtDesc();
    }

    public PublisherProposal review(String id, ReviewProposalRequest request) {
        PublisherProposal proposal = proposalRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Publisher proposal not found."));
        if (proposal.getStatus() != ProposalStatus.PENDING_ADMIN_REVIEW) {
            throw new ApiException(HttpStatus.CONFLICT, "This proposal has already been reviewed.");
        }
        if (request.approved()) {
            if (request.requestedLotQty() == null || request.requestedLotQty() > proposal.getVendorSupplyQty()) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "Requested lot quantity must be within vendor supply.");
            }
            proposal.setAdminRequestedLotQty(request.requestedLotQty());
            proposal.setStatus(ProposalStatus.APPROVED);
            proposal.setAdminMessage(request.message());
            Book book = Book.builder()
                    .id("proposal-book-" + proposal.getId())
                    .title(proposal.getBookTitle())
                    .author(proposal.getAuthor())
                    .publisher(proposal.getVendorName())
                    .edition("")
                    .category(proposal.getCategory())
                    .format("Print Copy")
                    .totalCopies(request.requestedLotQty())
                    .availableCopies(0)
                    .waitlistCount(0)
                    .loanPeriodDays(14)
                    .coverImageUrl(proposal.getSampleCoverImageUrl())
                    .description(proposal.getDescription())
                    .isbn(proposal.getIsbn())
                    .inventoryStatus("PENDING_SHELVING")
                    .proposalId(proposal.getId())
                    .build();
            bookRepository.save(book);
        } else {
            proposal.setStatus(ProposalStatus.REJECTED);
            proposal.setAdminMessage(request.message());
        }
        return proposalRepository.save(proposal);
    }
}
