package com.medikiosk.model.dto.response;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.UUID;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AyushRecommendationsResponse {
    private UUID sessionId;
    private String prakritiResult;
    private String vikritiSummary;
    private List<String> dietRecommendations;
    private List<String> lifestyleRecommendations;
    private List<String> recommendedYoga;

    public static AyushRecommendationsResponseBuilder builder() {
        return new AyushRecommendationsResponseBuilder();
    }

    public static class AyushRecommendationsResponseBuilder {
        private UUID sessionId;
        private String prakritiResult;
        private String vikritiSummary;
        private List<String> dietRecommendations;
        private List<String> lifestyleRecommendations;
        private List<String> recommendedYoga;

        public AyushRecommendationsResponseBuilder sessionId(UUID sessionId) { this.sessionId = sessionId; return this; }
        public AyushRecommendationsResponseBuilder prakritiResult(String prakritiResult) { this.prakritiResult = prakritiResult; return this; }
        public AyushRecommendationsResponseBuilder vikritiSummary(String vikritiSummary) { this.vikritiSummary = vikritiSummary; return this; }
        public AyushRecommendationsResponseBuilder dietRecommendations(List<String> dietRecommendations) { this.dietRecommendations = dietRecommendations; return this; }
        public AyushRecommendationsResponseBuilder lifestyleRecommendations(List<String> lifestyleRecommendations) { this.lifestyleRecommendations = lifestyleRecommendations; return this; }
        public AyushRecommendationsResponseBuilder recommendedYoga(List<String> recommendedYoga) { this.recommendedYoga = recommendedYoga; return this; }

        public AyushRecommendationsResponse build() {
            AyushRecommendationsResponse r = new AyushRecommendationsResponse();
            r.sessionId = this.sessionId;
            r.prakritiResult = this.prakritiResult;
            r.vikritiSummary = this.vikritiSummary;
            r.dietRecommendations = this.dietRecommendations;
            r.lifestyleRecommendations = this.lifestyleRecommendations;
            r.recommendedYoga = this.recommendedYoga;
            return r;
        }
    }
}