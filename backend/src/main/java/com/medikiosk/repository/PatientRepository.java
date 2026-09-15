package com.medikiosk.repository;

import com.medikiosk.model.entity.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface PatientRepository extends JpaRepository<Patient, UUID> {
    Optional<Patient> findFirstByAbhaId(String abhaId);
    Optional<Patient> findFirstByPhone(String phone);
    java.util.List<Patient> findAllByPhone(String phone);
    Optional<Patient> findFirstByAadhaarLastFour(String aadhaarLastFour);
    boolean existsByAbhaId(String abhaId);
    java.util.List<Patient> findAllByFaceEmbeddingIsNotNull();
    Optional<Patient> findFirstByEnrolledDeviceId(String enrolledDeviceId);
    Optional<Patient> findTopByOrderByCreatedAtDesc();
}