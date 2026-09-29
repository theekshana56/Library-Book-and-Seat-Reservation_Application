package com.biblione.repository;

import com.biblione.model.Book;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface BookRepository extends MongoRepository<Book, String> {

    List<Book> findByCategoryIgnoreCase(String category);

    List<Book> findByInventoryStatus(String inventoryStatus);

    List<Book> findByShelfCode(String shelfCode);
}
