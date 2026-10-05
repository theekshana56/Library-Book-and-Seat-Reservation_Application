package com.biblione.admin.controller;

import com.biblione.admin.dto.AdminStatsResponse;
import com.biblione.admin.dto.CreateHallRequest;
import com.biblione.admin.dto.CreateBookRequest;
import com.biblione.admin.dto.CreateSeatRequest;
import com.biblione.admin.dto.CreateTaskRequest;
import com.biblione.admin.dto.CreateUserRequest;
import com.biblione.admin.dto.UpdateTaskRequest;
import com.biblione.admin.dto.UpdateTaskStatusRequest;
import com.biblione.admin.dto.UpdateUserRequest;
import com.biblione.admin.dto.UpdateUserStatusRequest;
import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.Hall;
import com.biblione.admin.model.Shelf;
import com.biblione.admin.model.StaffTask;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.service.AdminService;
import com.biblione.auth.security.AuthContext;
import com.biblione.model.Book;
import com.biblione.model.Seat;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
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

    @GetMapping("/users/{id}")
    public AdminUser getUser(@PathVariable String id) {
        return adminService.getUser(id);
    }

    @PutMapping("/users/{id}")
    public AdminUser updateUser(@PathVariable String id, @Valid @RequestBody UpdateUserRequest request) {
        if (id.equals(AuthContext.getCurrentUser().id()) && !request.active()) {
            throw new com.biblione.exception.ApiException(HttpStatus.BAD_REQUEST, "You cannot deactivate your own account.");
        }
        return adminService.updateUser(id, request);
    }

    @PutMapping("/users/{id}/status")
    public AdminUser updateUserStatus(
            @PathVariable String id,
            @Valid @RequestBody UpdateUserStatusRequest request) {
        if (id.equals(AuthContext.getCurrentUser().id()) && !request.active()) {
            throw new com.biblione.exception.ApiException(HttpStatus.BAD_REQUEST, "You cannot deactivate your own account.");
        }
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

    @GetMapping("/books")
    public List<Book> getBooks() {
        return adminService.getBooks();
    }

    @GetMapping("/books/{id}")
    public Book getBook(@PathVariable String id) {
        return adminService.getBook(id);
    }

    @PostMapping("/books")
    @ResponseStatus(HttpStatus.CREATED)
    public Book createBook(@Valid @RequestBody CreateBookRequest request) {
        return adminService.createBook(request);
    }

    @PutMapping("/books/{id}")
    public Book updateBook(@PathVariable String id, @Valid @RequestBody CreateBookRequest request) {
        return adminService.updateBook(id, request);
    }

    @DeleteMapping("/books/{id}")
    public Book archiveBook(@PathVariable String id) {
        return adminService.archiveBook(id);
    }

    @PostMapping("/tasks")
    @ResponseStatus(HttpStatus.CREATED)
    public StaffTask createTask(@Valid @RequestBody CreateTaskRequest request) {
        return adminService.createTask(request);
    }

    @GetMapping("/tasks/staff/{staffId}")
    public List<StaffTask> getStaffTasks(@PathVariable String staffId) {
        return adminService.getStaffTasks(staffId, AuthContext.getCurrentUser());
    }

    @PutMapping("/tasks/{id}")
    public StaffTask updateTask(@PathVariable String id, @Valid @RequestBody UpdateTaskRequest request) {
        return adminService.updateTask(id, request);
    }

    @DeleteMapping("/tasks/{id}")
    public StaffTask cancelTask(@PathVariable String id) {
        return adminService.cancelTask(id);
    }

    @PutMapping("/tasks/{id}/status")
    public StaffTask updateTaskStatus(
            @PathVariable String id,
            @Valid @RequestBody UpdateTaskStatusRequest request) {
        return adminService.updateTaskStatus(id, request, AuthContext.getCurrentUser());
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

    @GetMapping("/shelves/active")
    public List<Shelf> getActiveShelves() {
        return adminService.getActiveShelves();
    }

    @PutMapping("/shelves/{id}")
    public Shelf updateShelf(@PathVariable String id, @Valid @RequestBody Shelf shelf) {
        return adminService.updateShelf(id, shelf);
    }

    @DeleteMapping("/shelves/{id}")
    public Shelf archiveShelf(@PathVariable String id) {
        return adminService.archiveShelf(id);
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

    @PutMapping("/halls/{id}")
    public Hall updateHall(@PathVariable String id, @Valid @RequestBody CreateHallRequest request) {
        return adminService.updateHall(id, request);
    }

    @DeleteMapping("/halls/{id}")
    public Hall archiveHall(@PathVariable String id) {
        return adminService.archiveHall(id);
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

    @PutMapping("/seats/{id}")
    public Seat updateSeat(@PathVariable String id, @Valid @RequestBody CreateSeatRequest request) {
        return adminService.updateSeat(id, request);
    }

    @DeleteMapping("/seats/{id}")
    public Seat archiveSeat(@PathVariable String id) {
        return adminService.archiveSeat(id);
    }
}
