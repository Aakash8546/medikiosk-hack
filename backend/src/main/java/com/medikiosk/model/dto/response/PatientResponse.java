package com.medikiosk.model.dto.response;

import lombok.*;
import java.util.UUID;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class PatientResponse {
    private UUID id;
    private String abhaId;
    private String fullName;
    private String dateOfBirth;
    private String gender;
    private String phone;
    private String address;
    private Boolean isMinor;
    private String preferredLanguage;
    private String createdAt;

    public UUID getId() { return id; }
    public String getAbhaId() { return abhaId; }
    public String getFullName() { return fullName; }
    public String getDateOfBirth() { return dateOfBirth; }
    public String getGender() { return gender; }
    public String getPhone() { return phone; }
    public String getAddress() { return address; }
    public Boolean getIsMinor() { return isMinor; }
    public String getPreferredLanguage() { return preferredLanguage; }
    public String getCreatedAt() { return createdAt; }

    public void setId(UUID id) { this.id = id; }
    public void setAbhaId(String abhaId) { this.abhaId = abhaId; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public void setDateOfBirth(String dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public void setGender(String gender) { this.gender = gender; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setAddress(String address) { this.address = address; }
    public void setIsMinor(Boolean isMinor) { this.isMinor = isMinor; }
    public void setPreferredLanguage(String preferredLanguage) { this.preferredLanguage = preferredLanguage; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public static PatientResponseBuilder builder() { return new PatientResponseBuilder(); }
    public static class PatientResponseBuilder {
        private UUID id; private String abhaId; private String fullName; private String dateOfBirth;
        private String gender; private String phone; private String address; private Boolean isMinor;
        private String preferredLanguage; private String createdAt;

        public PatientResponseBuilder id(UUID id) { this.id = id; return this; }
        public PatientResponseBuilder abhaId(String abhaId) { this.abhaId = abhaId; return this; }
        public PatientResponseBuilder fullName(String fullName) { this.fullName = fullName; return this; }
        public PatientResponseBuilder dateOfBirth(String dateOfBirth) { this.dateOfBirth = dateOfBirth; return this; }
        public PatientResponseBuilder gender(String gender) { this.gender = gender; return this; }
        public PatientResponseBuilder phone(String phone) { this.phone = phone; return this; }
        public PatientResponseBuilder address(String address) { this.address = address; return this; }
        public PatientResponseBuilder isMinor(Boolean isMinor) { this.isMinor = isMinor; return this; }
        public PatientResponseBuilder preferredLanguage(String preferredLanguage) { this.preferredLanguage = preferredLanguage; return this; }
        public PatientResponseBuilder createdAt(String createdAt) { this.createdAt = createdAt; return this; }

        public PatientResponse build() {
            PatientResponse r = new PatientResponse();
            r.id = this.id; r.abhaId = this.abhaId; r.fullName = this.fullName; r.dateOfBirth = this.dateOfBirth;
            r.gender = this.gender; r.phone = this.phone; r.address = this.address; r.isMinor = this.isMinor;
            r.preferredLanguage = this.preferredLanguage; r.createdAt = this.createdAt;
            return r;
        }
    }
}