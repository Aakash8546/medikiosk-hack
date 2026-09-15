package com.medikiosk.model.entity;

import com.medikiosk.model.enums.SessionStatus;
import com.medikiosk.model.enums.SessionType;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "patient_sessions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PatientSession {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "session_type", nullable = false)
    private SessionType sessionType = SessionType.GENERAL;

    @Builder.Default
    @Column(nullable = false)
    private String language = "en";

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SessionStatus status = SessionStatus.STARTED;

    @Builder.Default
    @Column(name = "started_at")
    private LocalDateTime startedAt = LocalDateTime.now();

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @Column(name = "expired_at")
    private LocalDateTime expiredAt;

    @Builder.Default
    @Column(name = "last_activity")
    private LocalDateTime lastActivity = LocalDateTime.now();

    @Builder.Default
    @Column(name = "is_recovered")
    private Boolean isRecovered = false;

    public void touch() {
        this.lastActivity = LocalDateTime.now();
    }

    public boolean isExpired(int timeoutMinutes) {
        return lastActivity.plusMinutes(timeoutMinutes).isBefore(LocalDateTime.now());
    }

    
    public UUID getId() { return id; }
    public Patient getPatient() { return patient; }
    public SessionType getSessionType() { return sessionType; }
    public String getLanguage() { return language; }
    public SessionStatus getStatus() { return status; }
    public LocalDateTime getStartedAt() { return startedAt; }
    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public LocalDateTime getExpiredAt() { return expiredAt; }
    public LocalDateTime getLastActivity() { return lastActivity; }
    public Boolean getIsRecovered() { return isRecovered; }

    public void setId(UUID id) { this.id = id; }
    public void setPatient(Patient patient) { this.patient = patient; }
    public void setSessionType(SessionType sessionType) { this.sessionType = sessionType; }
    public void setLanguage(String language) { this.language = language; }
    public void setStatus(SessionStatus status) { this.status = status; }
    public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }
    public void setExpiredAt(LocalDateTime expiredAt) { this.expiredAt = expiredAt; }
    public void setLastActivity(LocalDateTime lastActivity) { this.lastActivity = lastActivity; }
    public void setIsRecovered(Boolean isRecovered) { this.isRecovered = isRecovered; }
}