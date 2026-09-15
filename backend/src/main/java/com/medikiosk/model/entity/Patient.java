package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "patients")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "abha_id", unique = true)
    private String abhaId;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    private String gender;
    private String phone;
    private String address;

    @Builder.Default
    @Column(name = "is_minor")
    private Boolean isMinor = false;

    @Column(name = "guardian_phone")
    private String guardianPhone;

    @Builder.Default
    @Column(name = "preferred_language")
    private String preferredLanguage = "en";

    @Column(name = "aadhaar_last_four")
    private String aadhaarLastFour;

    @Column(name = "face_embedding", columnDefinition = "TEXT")
    private String faceEmbedding;

    @Builder.Default
    @Column(name = "fingerprint_enrolled")
    private Boolean fingerprintEnrolled = false;

    @Column(name = "enrolled_device_id")
    private String enrolledDeviceId;

    @Column(name = "biometric_enrolled_at")
    private LocalDateTime biometricEnrolledAt;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    
    public UUID getId() { return id; }
    public String getAbhaId() { return abhaId; }
    public String getFullName() { return fullName; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public String getGender() { return gender; }
    public String getPhone() { return phone; }
    public String getAddress() { return address; }
    public Boolean getIsMinor() { return isMinor; }
    public String getGuardianPhone() { return guardianPhone; }
    public String getPreferredLanguage() { return preferredLanguage; }
    public String getAadhaarLastFour() { return aadhaarLastFour; }
    public String getFaceEmbedding() { return faceEmbedding; }
    public Boolean getFingerprintEnrolled() { return fingerprintEnrolled; }
    public String getEnrolledDeviceId() { return enrolledDeviceId; }
    public LocalDateTime getBiometricEnrolledAt() { return biometricEnrolledAt; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    public void setId(UUID id) { this.id = id; }
    public void setAbhaId(String abhaId) { this.abhaId = abhaId; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public void setGender(String gender) { this.gender = gender; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setAddress(String address) { this.address = address; }
    public void setIsMinor(Boolean isMinor) { this.isMinor = isMinor; }
    public void setGuardianPhone(String guardianPhone) { this.guardianPhone = guardianPhone; }
    public void setPreferredLanguage(String preferredLanguage) { this.preferredLanguage = preferredLanguage; }
    public void setAadhaarLastFour(String aadhaarLastFour) { this.aadhaarLastFour = aadhaarLastFour; }
    public void setFaceEmbedding(String faceEmbedding) { this.faceEmbedding = faceEmbedding; }
    public void setFingerprintEnrolled(Boolean fingerprintEnrolled) { this.fingerprintEnrolled = fingerprintEnrolled; }
    public void setEnrolledDeviceId(String enrolledDeviceId) { this.enrolledDeviceId = enrolledDeviceId; }
    public void setBiometricEnrolledAt(LocalDateTime biometricEnrolledAt) { this.biometricEnrolledAt = biometricEnrolledAt; }
}