package com.medikiosk.repository;

import com.medikiosk.model.entity.InterviewQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InterviewQuestionRepository extends JpaRepository<InterviewQuestion, UUID> {

    List<InterviewQuestion> findByIsActiveTrueAndAppliesToInOrderBySequenceOrder(
        List<String> appliesToValues);

    Optional<InterviewQuestion> findByQuestionKey(String questionKey);

    List<InterviewQuestion> findByParentQuestionKeyAndTriggerValue(
        String parentKey, String triggerValue);
}