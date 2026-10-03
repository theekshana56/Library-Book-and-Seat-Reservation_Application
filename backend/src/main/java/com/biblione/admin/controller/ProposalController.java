package com.biblione.admin.controller;

import com.biblione.admin.dto.CreateProposalRequest;
import com.biblione.admin.dto.ReviewProposalRequest;
import com.biblione.admin.model.PublisherProposal;
import com.biblione.admin.service.PublisherProposalService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class ProposalController {

    private final PublisherProposalService proposalService;

    @PostMapping("/publisher/proposals")
    @ResponseStatus(HttpStatus.CREATED)
    public PublisherProposal submit(@Valid @RequestBody CreateProposalRequest request) {
        return proposalService.submit(request);
    }

    @GetMapping("/publisher/proposals/vendor/{vendorId}")
    public List<PublisherProposal> getVendorProposals(@PathVariable String vendorId) {
        return proposalService.getVendorProposals(vendorId);
    }

    @GetMapping("/admin/proposals")
    public List<PublisherProposal> getAdminProposals() {
        return proposalService.getAllProposals();
    }

    @PutMapping("/admin/proposals/{id}/review")
    public PublisherProposal review(
            @PathVariable String id,
            @Valid @RequestBody ReviewProposalRequest request) {
        return proposalService.review(id, request);
    }
}
