package com.biblione.admin.repository;

import com.biblione.admin.model.StaffTask;
import com.biblione.admin.model.TaskStatus;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface StaffTaskRepository extends MongoRepository<StaffTask, String> {
    List<StaffTask> findByAssignedStaffIdOrderByCreatedAtDesc(String assignedStaffId);
    List<StaffTask> findByTargetShelfCode(String targetShelfCode);
    boolean existsByBookIdAndStatusNotIn(String bookId, List<TaskStatus> statuses);
    long countByStatusNot(TaskStatus status);
    long countByStatusNotIn(List<TaskStatus> statuses);
}
