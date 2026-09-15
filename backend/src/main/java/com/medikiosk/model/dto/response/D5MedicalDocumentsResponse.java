package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D5MedicalDocumentsResponse {
    private UUID sessionId;
    private UUID patientId;
    private int totalDocuments;
    private int ocrCompletedCount;
    private int ocrPendingCount;
    private List<DocumentItem> documentList;

    @Data @AllArgsConstructor @NoArgsConstructor
    public static class DocumentItem {
        private String documentId;
        private String title;
        private String category; 
        private String uploadDate;
        private String ocrStatus; 
        private String thumbnailUrl;
        private String fileUrl;
        private String extractedText;
    }
}