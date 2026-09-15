package com.medikiosk.repository;

import com.medikiosk.model.entity.InterviewResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InterviewResponseRepository extends JpaRepository<InterviewResponse, UUID> {

    List<InterviewResponse> findBySessionIdOrderByAnsweredAt(UUID sessionId);

    Optional<InterviewResponse> findBySessionIdAndQuestionId(UUID sessionId, UUID questionId);

    int countBySessionId(UUID sessionId);
}