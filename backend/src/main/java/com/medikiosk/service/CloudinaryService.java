package com.medikiosk.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;


@Service
@Slf4j
public class CloudinaryService {

    private final Cloudinary cloudinary;
    private final boolean enabled;

    public CloudinaryService(
            @Value("${cloudinary.cloud-name:}") String cloudName,
            @Value("${cloudinary.api-key:}") String apiKey,
            @Value("${cloudinary.api-secret:}") String apiSecret) {

        enabled = !cloudName.isBlank() && !apiKey.isBlank() && !apiSecret.isBlank();
        if (enabled) {
            cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", cloudName,
                    "api_key",    apiKey,
                    "api_secret", apiSecret,
                    "secure",     true));
            log.info("Cloudinary image storage enabled (cloud: {})", cloudName);
        } else {
            cloudinary = null;
            log.warn("Cloudinary credentials not set — prescription images will not be stored");
        }
    }

    
    public String upload(MultipartFile file, String folder) {
        if (!enabled || cloudinary == null) return null;
        try {
            byte[] bytes = file.getBytes();
            @SuppressWarnings("unchecked")
            Map<String, Object> result = cloudinary.uploader().upload(bytes, ObjectUtils.asMap(
                    "folder",              "medikiosk/" + folder,
                    "resource_type",       "image",
                    "use_filename",        true,
                    "unique_filename",     true,
                    "overwrite",           false));
            String url = (String) result.get("secure_url");
            log.debug("Cloudinary upload OK: {}", url);
            return url;
        } catch (Exception e) {
            log.error("Cloudinary upload failed for '{}': {}", file.getOriginalFilename(), e.getMessage());
            return null;
        }
    }
}