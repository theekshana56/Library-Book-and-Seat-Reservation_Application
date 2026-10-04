package com.biblione.admin.dto;

public record AdminStatsResponse(
        long totalRegisteredUsers,
        long activeStaffTasks,
        long pendingPublisherProposals,
        long totalShelfCapacity,
        long activeUsers) {
}
