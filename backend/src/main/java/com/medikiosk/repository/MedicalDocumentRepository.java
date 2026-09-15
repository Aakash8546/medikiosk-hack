package com.medikiosk.repository;

import com.medikiosk.model.entity.MedicalDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface MedicalDocumentRepository extends JpaRepository<MedicalDocument, UUID> {

    
    @Query("SELECT d FROM MedicalDocument d WHERE d.session.id = :sessionId "
         + "ORDER BY CASE WHEN d.normalizedDate IS NULL THEN 1 ELSE 0 END, "
         + "d.normalizedDate DESC, d.createdAt DESC")
    List<MedicalDocument> findBySessionIdOrderedByDate(@Param("sessionId") UUID sessionId);

    long countBySessionId(UUID sessionId);
}