package com.biblione.admin.repository;

import com.biblione.admin.model.ProposalStatus;
import com.biblione.admin.model.PublisherProposal;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface PublisherProposalRepository extends MongoRepository<PublisherProposal, String> {
    List<PublisherProposal> findByVendorIdOrderByCreatedAtDesc(String vendorId);
    List<PublisherProposal> findAllByOrderByCreatedAtDesc();
    long countByStatus(ProposalStatus status);
}
