package com.medikiosk.model.dto.request;

import lombok.Data;
import java.util.List;

@Data
public class DrugCheckRequest {
    private List<String> drugs;
}