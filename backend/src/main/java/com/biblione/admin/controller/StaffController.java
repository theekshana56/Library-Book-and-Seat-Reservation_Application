package com.biblione.admin.controller;

import com.biblione.admin.dto.UpdateTaskStatusRequest;
import com.biblione.admin.model.Shelf;
import com.biblione.admin.model.StaffTask;
import com.biblione.admin.service.AdminService;
import com.biblione.auth.security.AuthContext;
import com.biblione.auth.security.AuthenticatedUser;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/staff")
@RequiredArgsConstructor
public class StaffController {

    private final AdminService adminService;

    @GetMapping("/tasks")
    public List<StaffTask> getMyTasks() {
        AuthenticatedUser user = AuthContext.getCurrentUser();
        return adminService.getStaffTasks(user.id(), user);
    }

    @PutMapping("/tasks/{id}/status")
    public StaffTask updateMyTaskStatus(
            @PathVariable String id,
            @Valid @RequestBody UpdateTaskStatusRequest request) {
        return adminService.updateTaskStatus(id, request, AuthContext.getCurrentUser());
    }

    @GetMapping("/shelves")
    public List<Shelf> getShelves() {
        return adminService.getShelves();
    }
}
