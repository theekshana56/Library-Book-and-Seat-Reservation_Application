package com.biblione.config;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.Shelf;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.admin.repository.ShelfRepository;
import com.biblione.model.Book;
import com.biblione.model.Loan;
import com.biblione.model.Reservation;
import com.biblione.model.SeatHold;
import com.biblione.repository.BookRepository;
import com.biblione.repository.LoanRepository;
import com.biblione.repository.ReservationRepository;
import com.biblione.repository.SeatHoldRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(name = "biblione.seed", havingValue = "true", matchIfMissing = true)
public class DatabaseSeeder implements CommandLineRunner {

    public static final String DEMO_USER_ID = "IT23773158";

    private final BookRepository bookRepository;
    private final ReservationRepository reservationRepository;
    private final LoanRepository loanRepository;
    private final SeatHoldRepository seatHoldRepository;
        private final AdminUserRepository adminUserRepository;
        private final ShelfRepository shelfRepository;
        private final PasswordEncoder passwordEncoder;

        @Value("${biblione.seed-password:Biblione-ChangeMe-2026}")
        private String seedPassword;

    @Override
    public void run(String... args) {
                seedAdminData();
        if (bookRepository.count() > 0) {
            log.info("Catalog already seeded ({} books). Skipping.", bookRepository.count());
            return;
        }

        Book ddia = bookRepository.save(Book.builder()
                .id("book-ddia")
                .title("Designing Data-Intensive Applications")
                .author("Martin Kleppmann")
                .publisher("O'Reilly")
                .edition("1st Edition")
                .year(2017)
                .category("Computer Science")
                .callNumber("QA76.9.D3")
                .format("Hardcover")
                .shelfCode("CS-204")
                .shelfDetail("L2, Stacks 8")
                .wayfinding("Level 2 • East Wing Aisle 8")
                .pickupDesk("Central Circulation Desk")
                .pickupDeskDetail("Level 1, East Atrium Entrance")
                .loanPeriodDays(14)
                .totalCopies(3)
                .availableCopies(3)
                .waitlistCount(0)
                .coverImageUrl("https://covers.openlibrary.org/b/isbn/9781449373320-L.jpg")
                .catalogNotice("Ready for express pickup today")
                .expressHoldHours(24)
                .isbn("9781449373320")
                .build());

        bookRepository.save(Book.builder()
                .id("book-clean-architecture")
                .title("Clean Architecture")
                .author("Robert C. Martin (Uncle Bob)")
                .publisher("Pearson")
                .edition("1st Edition")
                .year(2017)
                .category("Software Eng")
                .callNumber("QA76.76.D47")
                .format("Paperback")
                .shelfCode("CS-118")
                .shelfDetail("Level 1")
                .wayfinding("Level 1 • West Stacks")
                .pickupDesk("Central Circulation Desk")
                .pickupDeskDetail("Level 1, East Atrium Entrance")
                .loanPeriodDays(14)
                .totalCopies(2)
                .availableCopies(0)
                .waitlistCount(2)
                .nextReturnDate(LocalDate.of(2026, 4, 22).atStartOfDay().toInstant(ZoneOffset.UTC))
                .currentBorrower("Department of CS")
                .coverImageUrl("https://covers.openlibrary.org/b/isbn/9780134494166-L.jpg")
                .isbn("9780134494166")
                .build());

        bookRepository.save(Book.builder()
                .id("book-ai")
                .title("Artificial Intelligence: A Modern Approach")
                .author("Stuart Russell & Peter Norvig")
                .publisher("4th Edition")
                .edition("4th Edition")
                .year(2020)
                .category("Computer Science")
                .callNumber("Q335")
                .format("Hardcover")
                .shelfCode("AI-402")
                .shelfDetail("Level 4")
                .wayfinding("Level 4 • AI Collection")
                .pickupDesk("Central Circulation Desk")
                .pickupDeskDetail("Level 1, East Atrium Entrance")
                .loanPeriodDays(14)
                .totalCopies(1)
                .availableCopies(1)
                .waitlistCount(0)
                .coverImageUrl("https://covers.openlibrary.org/b/isbn/9780134610993-L.jpg")
                .catalogNotice("Can hold for 2 hours")
                .expressHoldHours(2)
                .isbn("9780134610993")
                .build());

        Book cleanCode = bookRepository.save(Book.builder()
                .id("book-clean-code")
                .title("Clean Code: Agile Software")
                .author("Robert C. Martin")
                .publisher("Prentice Hall")
                .edition("1st Edition")
                .year(2008)
                .category("Software Eng")
                .callNumber("QA76.76.T48")
                .format("Paperback")
                .shelfCode("CS-110")
                .shelfDetail("Level 1")
                .wayfinding("Level 1 • Programming Aisle")
                .pickupDesk("Central Circulation Desk")
                .pickupDeskDetail("Level 1, East Atrium Entrance")
                .loanPeriodDays(14)
                .totalCopies(2)
                .availableCopies(0)
                .waitlistCount(0)
                .coverImageUrl("https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg")
                .isbn("9780132350884")
                .build());

        Instant now = Instant.now();
        reservationRepository.save(Reservation.builder()
                .holdIdCode("BBL-9042-DDIA")
                .userId(DEMO_USER_ID)
                .borrowerLabel("RW - 20248839")
                .studentCardId("2024-9182")
                .department("CS Dept")
                .bookId(ddia.getId())
                .title(ddia.getTitle())
                .author(ddia.getAuthor())
                .coverImageUrl(ddia.getCoverImageUrl())
                .shelfCode(ddia.getShelfCode())
                .shelfDetail(ddia.getShelfDetail())
                .format("Print Copy")
                .priorityHold(true)
                .pickupDesk("Central Circulation Desk")
                .pickupDeskDetail("Level 1 • East Atrium Entrance")
                .status("READY_FOR_PICKUP")
                .createdAt(now)
                .expiresAt(now.plus(24, ChronoUnit.HOURS))
                .build());

        seatHoldRepository.save(SeatHold.builder()
                .userId(DEMO_USER_ID)
                .seatCode("A04")
                .seatName("Seat - A04")
                .zone("Silent Pod · Level 2 Quiet Zone · Window View")
                .slotLabel("Today, 10:00 - 12:00")
                .amenities(List.of("power", "wifi", "quiet"))
                .checkInBy(now.plus(12, ChronoUnit.MINUTES).plus(40, ChronoUnit.SECONDS))
                .status("CONFIRMED")
                .build());

        Instant due = LocalDate.of(2026, 10, 18).atStartOfDay().toInstant(ZoneOffset.UTC);
        loanRepository.save(Loan.builder()
                .userId(DEMO_USER_ID)
                .bookId(cleanCode.getId())
                .title("Clean Code: Agile Soft")
                .author(cleanCode.getAuthor())
                .coverImageUrl(cleanCode.getCoverImageUrl())
                .borrowedAt(due.minus(12, ChronoUnit.DAYS))
                .dueDate(due)
                .renewCount(0)
                .loanLimit(5)
                .status("ACTIVE")
                .build());

        log.info("Seeded Biblione catalog, demo reservation BBL-9042-DDIA, seat A04, and Clean Code loan.");
    }

        private void seedAdminData() {
                seedUser("seed-admin", "admin@biblione.edu", "Library Administrator", UserRole.ADMIN, "Library", "ADMIN");
                seedUser("seed-staff", "staff@biblione.edu", "Library Staff", UserRole.LIBRARY_STAFF, "Library Services", "STAFF");
                seedUser("seed-vendor", "vendor@biblione.edu", "Biblione Books Vendor", UserRole.VENDOR, "Publishing", "VENDOR");

                List<Shelf> shelves = List.of(
                                Shelf.builder().shelfCode("CS-204").level("Level 2").zone("East Wing").maxCapacity(50).currentBookCount(0).build(),
                                Shelf.builder().shelfCode("CS-301").level("Level 3").zone("Computer Science").maxCapacity(75).currentBookCount(0).build());
                for (Shelf shelf : shelves) {
                        if (shelfRepository.findByShelfCodeIgnoreCase(shelf.getShelfCode()).isEmpty()) {
                                shelfRepository.save(shelf);
                        }
                }
                log.info("Seeded initial admin, staff, vendor, and shelf records when absent.");
        }

        private void seedUser(String id, String email, String name, UserRole role, String department, String category) {
                if (adminUserRepository.existsByEmailIgnoreCase(email)) return;
                adminUserRepository.save(AdminUser.builder()
                                .id(id)
                                .fullName(name)
                                .email(email)
                                .password(passwordEncoder.encode(seedPassword))
                                .role(role)
                                .department(department)
                                .userCategory(category)
                                .active(true)
                                .build());
        }
}
