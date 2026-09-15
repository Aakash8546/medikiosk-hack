package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DoctorDashboardStatsResponse {
    private String doctorName;
    private String specialty;
    private long totalPatientsToday;
    private long activeNow;
    private long opdCountToday;
    private long completedCountToday;
    private List<OpdQueueItemResponse> patientQueue;
}