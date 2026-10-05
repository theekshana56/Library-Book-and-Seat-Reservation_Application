package com.biblione.admin.controller;

import com.biblione.admin.dto.AdminStatsResponse;
import com.biblione.admin.dto.CreateHallRequest;
import com.biblione.admin.dto.CreateSeatRequest;
import com.biblione.admin.dto.CreateTaskRequest;
import com.biblione.admin.dto.CreateUserRequest;
import com.biblione.admin.dto.UpdateTaskStatusRequest;
import com.biblione.admin.dto.UpdateUserStatusRequest;
import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.Hall;
import com.biblione.admin.model.Shelf;
import com.biblione.admin.model.StaffTask;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.service.AdminService;
import com.biblione.model.Book;
import com.biblione.model.Seat;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @PostMapping("/users")
    @ResponseStatus(HttpStatus.CREATED)
    public AdminUser createUser(@Valid @RequestBody CreateUserRequest request) {
        return adminService.createUser(request);
    }

    @GetMapping("/users")
    public List<AdminUser> getUsers(
            @RequestParam(required = false) UserRole role,
            @RequestParam(required = false) Boolean active) {
        return adminService.getUsers(role, active);
    }

    @PutMapping("/users/{id}/status")
    public AdminUser updateUserStatus(
            @PathVariable String id,
            @Valid @RequestBody UpdateUserStatusRequest request) {
        return adminService.updateUserStatus(id, request);
    }

    @GetMapping("/stats")
    public AdminStatsResponse getStats() {
        return adminService.getStats();
    }

    @GetMapping("/books/pending-shelving")
    public List<Book> getPendingShelvingBooks() {
        return adminService.getPendingShelvingBooks();
    }

    @PostMapping("/tasks")
    @ResponseStatus(HttpStatus.CREATED)
    public StaffTask createTask(@Valid @RequestBody CreateTaskRequest request) {
        return adminService.createTask(request);
    }

    @GetMapping("/tasks/staff/{staffId}")
    public List<StaffTask> getStaffTasks(@PathVariable String staffId) {
        return adminService.getStaffTasks(staffId);
    }

    @PutMapping("/tasks/{id}/status")
    public StaffTask updateTaskStatus(
            @PathVariable String id,
            @Valid @RequestBody UpdateTaskStatusRequest request) {
        return adminService.updateTaskStatus(id, request);
    }

    @PostMapping("/shelves")
    @ResponseStatus(HttpStatus.CREATED)
    public Shelf createShelf(@Valid @RequestBody Shelf shelf) {
        return adminService.createShelf(shelf);
    }

    @GetMapping("/shelves")
    public List<Shelf> getShelves() {
        return adminService.getShelves();
    }

    @PutMapping("/shelves/{id}")
    public Shelf updateShelf(@PathVariable String id, @Valid @RequestBody Shelf shelf) {
        return adminService.updateShelf(id, shelf);
    }

    @PostMapping("/halls")
    @ResponseStatus(HttpStatus.CREATED)
    public Hall createHall(@Valid @RequestBody CreateHallRequest request) {
        return adminService.createHall(request);
    }

    @GetMapping("/halls")
    public List<Hall> getHalls() {
        return adminService.getHalls();
    }

    @PostMapping("/seats")
    @ResponseStatus(HttpStatus.CREATED)
    public Seat createSeat(@Valid @RequestBody CreateSeatRequest request) {
        return adminService.createSeat(request);
    }

    @GetMapping("/seats")
    public List<Seat> getSeats() {
        return adminService.getSeats();
    }
}
