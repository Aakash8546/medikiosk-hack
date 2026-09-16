package com.medikiosk.controller;

import com.medikiosk.model.dto.request.DrugCheckRequest;
import com.medikiosk.model.dto.response.DrugInteractionResponse;
import com.medikiosk.service.DrugInteractionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/drugs")
@RequiredArgsConstructor
public class DrugInteractionController {
    private final DrugInteractionService drugInteractionService;

    @PostMapping("/check-interactions")
    public ResponseEntity<List<DrugInteractionResponse>> checkInteractions(@RequestBody DrugCheckRequest req) {
        return ResponseEntity.ok(drugInteractionService.checkInteractions(req));
    }
}