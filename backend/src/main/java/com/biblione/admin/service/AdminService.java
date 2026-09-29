package com.biblione.admin.service;

import com.biblione.admin.dto.AdminStatsResponse;
import com.biblione.admin.dto.CreateTaskRequest;
import com.biblione.admin.dto.CreateUserRequest;
import com.biblione.admin.dto.UpdateTaskStatusRequest;
import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.Shelf;
import com.biblione.admin.model.StaffTask;
import com.biblione.admin.model.TaskStatus;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.admin.repository.PublisherProposalRepository;
import com.biblione.admin.repository.ShelfRepository;
import com.biblione.admin.repository.StaffTaskRepository;
import com.biblione.admin.dto.UpdateUserStatusRequest;
import com.biblione.exception.ApiException;
import com.biblione.model.Book;
import com.biblione.repository.BookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final AdminUserRepository userRepository;
    private final PublisherProposalRepository proposalRepository;
    private final StaffTaskRepository taskRepository;
    private final ShelfRepository shelfRepository;
    private final BookRepository bookRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminUser createUser(CreateUserRequest request) {
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new ApiException(HttpStatus.CONFLICT, "An account with this email already exists.");
        }
        return userRepository.save(AdminUser.builder()
                .fullName(request.fullName().trim())
                .email(email)
                .password(passwordEncoder.encode(request.password()))
                .role(request.role())
                .department(request.department())
                .userCategory(request.userCategory())
                .active(request.active() == null || request.active())
                .build());
    }

    public List<AdminUser> getUsers(UserRole role, Boolean active) {
        if (role != null && active != null) {
            return userRepository.findByRoleAndActive(role, active);
        }
        if (role != null) {
            return userRepository.findByRole(role);
        }
        return userRepository.findAll().stream()
                .filter(user -> active == null || user.isActive() == active)
                .toList();
    }

    public AdminUser updateUserStatus(String id, UpdateUserStatusRequest request) {
        AdminUser user = userRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found."));
        user.setActive(request.active());
        return userRepository.save(user);
    }

    public AdminStatsResponse getStats() {
        long capacity = shelfRepository.findAll().stream().mapToLong(Shelf::getMaxCapacity).sum();
        long activeUsers = userRepository.findAll().stream().filter(AdminUser::isActive).count();
        return new AdminStatsResponse(
                userRepository.count(),
                taskRepository.countByStatusNot(TaskStatus.COMPLETED),
                proposalRepository.countByStatus(com.biblione.admin.model.ProposalStatus.PENDING_ADMIN_REVIEW),
                capacity,
                activeUsers);
    }

    public List<Book> getPendingShelvingBooks() {
        return bookRepository.findByInventoryStatus("PENDING_SHELVING");
    }

    public StaffTask createTask(CreateTaskRequest request) {
        AdminUser staff = userRepository.findById(request.assignedStaffId())
                .filter(user -> user.isActive() && user.getRole() == UserRole.LIBRARY_STAFF)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST,
                        "The selected account is not active library staff."));

        Book book = null;
        if (request.bookId() != null && !request.bookId().isBlank()) {
            book = bookRepository.findById(request.bookId())
                    .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Book not found."));
        }
        int quantity = request.quantity() == null ? (book == null ? 1 : book.getTotalCopies()) : request.quantity();
        if (book != null) {
            if (!"PENDING_SHELVING".equals(book.getInventoryStatus())) {
                throw new ApiException(HttpStatus.CONFLICT, "Only books awaiting shelving can be assigned as inventory tasks.");
            }
            int remaining = book.getTotalCopies() - book.getAvailableCopies();
            if (quantity != remaining) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "A shelving task must cover all remaining copies in the approved lot.");
            }
            if (taskRepository.existsByBookIdAndStatusNot(book.getId(), TaskStatus.COMPLETED)) {
                throw new ApiException(HttpStatus.CONFLICT, "This book already has an open shelving task.");
            }
        }

        return taskRepository.save(StaffTask.builder()
                .assignedStaffId(staff.getId())
                .assignedStaffName(staff.getFullName())
                .bookId(book == null ? null : book.getId())
                .bookTitle(book == null ? request.bookTitle() : book.getTitle())
                .taskDescription(request.taskDescription().trim())
                .targetShelfCode(blankToNull(request.targetShelfCode()))
                .quantity(quantity)
                .status(TaskStatus.PENDING)
                .createdAt(Instant.now())
                .build());
    }

    public List<StaffTask> getStaffTasks(String staffId) {
        return taskRepository.findByAssignedStaffIdOrderByCreatedAtDesc(staffId);
    }

    public StaffTask updateTaskStatus(String id, UpdateTaskStatusRequest request) {
        StaffTask task = taskRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Staff task not found."));
        if (request.status() == TaskStatus.PENDING) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Task status can only move to IN_PROGRESS or COMPLETED.");
        }
        if (task.getStatus() == TaskStatus.COMPLETED) {
            throw new ApiException(HttpStatus.CONFLICT, "Completed tasks cannot be changed.");
        }
        if (request.targetShelfCode() != null && !request.targetShelfCode().isBlank()) {
            task.setTargetShelfCode(request.targetShelfCode().trim());
        }
        if (request.status() == TaskStatus.COMPLETED) {
            completeInventoryTask(task, request.targetShelfCode());
        }
        task.setStatus(request.status());
        return taskRepository.save(task);
    }

    private void completeInventoryTask(StaffTask task, String suppliedShelfCode) {
        if (task.getBookId() == null) {
            return;
        }
        String shelfCode = blankToNull(suppliedShelfCode);
        if (shelfCode == null) shelfCode = task.getTargetShelfCode();
        if (shelfCode == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "A shelf code is required to complete a shelving task.");
        }
        Shelf shelf = shelfRepository.findByShelfCodeIgnoreCase(shelfCode)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Shelf not found."));
        Book book = bookRepository.findById(task.getBookId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Book not found."));
        int quantity = task.getQuantity() > 0 ? task.getQuantity() : book.getTotalCopies();
        if (shelf.getCurrentBookCount() + quantity > shelf.getMaxCapacity()) {
            throw new ApiException(HttpStatus.CONFLICT, "The selected shelf does not have enough capacity.");
        }
        int available = Math.min(book.getTotalCopies(), book.getAvailableCopies() + quantity);
        book.setAvailableCopies(available);
        book.setShelfCode(shelf.getShelfCode());
        book.setShelfDetail(shelf.getLevel() + ", " + shelf.getZone());
        book.setWayfinding(shelf.getLevel() + " • " + shelf.getZone());
        book.setInventoryStatus("AVAILABLE");
        bookRepository.save(book);
        shelf.setCurrentBookCount(shelf.getCurrentBookCount() + quantity);
        shelfRepository.save(shelf);
        task.setTargetShelfCode(shelf.getShelfCode());
    }

    public Shelf createShelf(Shelf shelf) {
        shelf.setShelfCode(shelf.getShelfCode().trim().toUpperCase(Locale.ROOT));
        if (shelfRepository.findByShelfCodeIgnoreCase(shelf.getShelfCode()).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "A shelf with this code already exists.");
        }
        if (shelf.getCurrentBookCount() > shelf.getMaxCapacity()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Current book count cannot exceed shelf capacity.");
        }
        if (shelf.getCurrentBookCount() < 0) shelf.setCurrentBookCount(0);
        return shelfRepository.save(shelf);
    }

    public List<Shelf> getShelves() {
        return shelfRepository.findAll();
    }

    public Shelf updateShelf(String id, Shelf update) {
        Shelf shelf = shelfRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Shelf not found."));
        String code = update.getShelfCode().trim().toUpperCase(Locale.ROOT);
        shelfRepository.findByShelfCodeIgnoreCase(code)
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> { throw new ApiException(HttpStatus.CONFLICT, "A shelf with this code already exists."); });
        if (update.getMaxCapacity() < shelf.getCurrentBookCount()) {
            throw new ApiException(HttpStatus.CONFLICT, "Capacity cannot be lower than the current book count.");
        }
        String previousCode = shelf.getShelfCode();
        if (!previousCode.equalsIgnoreCase(code)) {
            for (Book book : bookRepository.findByShelfCode(previousCode)) {
                book.setShelfCode(code);
                book.setShelfDetail(update.getLevel() + ", " + update.getZone());
                book.setWayfinding(update.getLevel() + " • " + update.getZone());
                bookRepository.save(book);
            }
            for (StaffTask task : taskRepository.findByTargetShelfCode(previousCode)) {
                task.setTargetShelfCode(code);
                taskRepository.save(task);
            }
        }
        shelf.setShelfCode(code);
        shelf.setLevel(update.getLevel());
        shelf.setZone(update.getZone());
        shelf.setMaxCapacity(update.getMaxCapacity());
        return shelfRepository.save(shelf);
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}