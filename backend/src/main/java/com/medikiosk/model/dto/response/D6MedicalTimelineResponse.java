package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D6MedicalTimelineResponse {
    private UUID sessionId;
    private UUID patientId;
    private String patientName;
    private String ageGenderAbha;
    private String priorityBadge;
    private List<String> categoriesFilter;
    private List<TimelineEvent> timelineEvents;
    private String disclaimer;

    @Data @AllArgsConstructor @NoArgsConstructor @Builder
    public static class TimelineEvent {
        private String eventId;
        private String date;
        private String time;
        private String category;
        private String iconType;
        private String title;
        private String resultText;
        private String highlightTag;
        private String highlightValue;
        private String imageUrl;
        private String badgeColor;
    }
}