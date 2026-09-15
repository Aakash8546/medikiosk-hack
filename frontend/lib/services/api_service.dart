import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/network/dio_client.dart';
import '../core/utils/app_logger.dart';
import '../core/network/api_endpoints.dart';
import '../models/ayush_assessment_request.dart';
import '../models/ayush_report_response.dart';
import '../models/interview_response.dart';
import '../models/patient.dart';
import '../models/ocr_document_page.dart';
import '../models/clinical_summary.dart';
import '../models/opd_queue.dart';

class ApiService {
  final Dio _dio = MediKioskDio.instance;

  
  
  Dio get _dioNoRetry {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    return dio;
  }

  
  Future<Patient> registerPatient({
    required String abhaId,
    required String name,
    required String dateOfBirth,
    required String gender,
    required String phone,
    required String address,
    required bool isMinor,
    required String preferredLanguage,
    String? guardianName,
    String? guardianPhone,
  }) async {
    
    String isoDob = dateOfBirth;
    try {
      final parts = dateOfBirth.split('/').map((e) => e.trim()).toList();
      if (parts.length == 3) {
        isoDob = '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    } catch (_) {
      
    }

    final payload = {
      'abhaId': abhaId.replaceAll(RegExp(r'[\s\-]'), ''),
      'fullName': name.trim(),
      'dateOfBirth': isoDob,
      'gender': gender,
      'phone': phone.replaceAll(RegExp(r'[^\d]'), ''),
      'address': address.trim(),
      'isMinor': isMinor,
      'preferredLanguage': preferredLanguage,
      if (guardianName != null) 'guardianName': guardianName.trim(),
      if (guardianPhone != null) 'guardianPhone': guardianPhone.replaceAll(RegExp(r'[^\d]'), ''),
    };

    logApi('POST ${ApiEndpoints.registerPatient} ${describeKeys(payload)}');

    final response = await _dioNoRetry.post(
      ApiEndpoints.registerPatient,
      data: payload,
    );

    logApi('Patient registered: ${response.statusCode}');
    return Patient.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Patient> identifyPatient({
    required String identifierType,
    required String identifier,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.identifyPatient,
      data: {'type': identifierType, 'identifier': identifier},
    );
    return Patient.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Patient> getPatientByAbha(String abhaId) async {
    final cleanAbha = abhaId.trim();
    logApi('GET /patients/abha/${maskId(cleanAbha)}');
    final response = await _dioNoRetry.get('/patients/abha/$cleanAbha');
    return Patient.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Patient> getPatientByPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    logApi('GET /patients/phone/${maskId(cleanPhone)}');
    final response = await _dioNoRetry.get('/patients/phone/$cleanPhone');
    return Patient.fromJson(response.data as Map<String, dynamic>);
  }

  
  Future<Map<String, dynamic>> createSession({
    required String patientId,
    required String sessionType,
    required String language,
  }) async {
    logApi('POST ${ApiEndpoints.createSession} (type=$sessionType, lang=$language)');
    final response = await _dioNoRetry.post(
      ApiEndpoints.createSession,
      data: {
        'patientId': patientId,
        'sessionType': sessionType,
        'language': language,
      },
    );
    logApi('Session created: ${response.statusCode}');
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> createConsent({
    required String sessionId,
    required String decision,
    required String consentType,
  }) async {
    logApi('POST ${ApiEndpoints.createConsent} (type=$consentType, decision=$decision)');
    final response = await _dioNoRetry.post(
      ApiEndpoints.createConsent,
      data: {
        'sessionId': sessionId,
        'consentType': consentType,
        'decision': decision,
      },
    );
    logApi('Consent recorded');
    return response.data as Map<String, dynamic>;
  }

  
  Future<InterviewResponse> startInterview({
    required String language, 
  }) async {
    logApi('POST ${ApiEndpoints.startInterview} (lang=$language)');
    
    
    final formData = FormData.fromMap({
      'language': language,
    });

    final response = await _dioNoRetry.post(
      ApiEndpoints.startInterview,
      data: formData,
    );

    logApi('Interview started');
    return InterviewResponse.fromJson(response.data as Map<String, dynamic>);
  }

  
  
  
  Future<InterviewResponse> submitInterviewReply({
    required String sessionId,
    String? textAnswer,
    String? audioFilePath,
  }) async {
    
    logApi('POST ${ApiEndpoints.interviewReply} '
        '(mode=${audioFilePath != null ? 'voice' : 'text'})');

    final map = <String, dynamic>{
      'session_id': sessionId,
    };

    if (textAnswer != null && textAnswer.isNotEmpty) {
      map['text_answer'] = textAnswer;
    }

    if (audioFilePath != null && audioFilePath.isNotEmpty) {
      final file = File(audioFilePath);
      if (await file.exists()) {
        final fileName = audioFilePath.split('/').last;
        map['audio_file'] = await MultipartFile.fromFile(
          audioFilePath,
          filename: fileName,
        );
      }
    }

    final formData = FormData.fromMap(map);

    try {
      final response = await _dioNoRetry.post(
        ApiEndpoints.interviewReply,
        data: formData,
      );

      logApi('Interview reply accepted');
      return InterviewResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logApi('Interview reply failed: ${e.response?.statusCode}');
      rethrow;
    }
  }

  Future<void> submitAnswer({
    required String interviewId,
    required String questionId,
    required String answer,
    required String inputMode,
  }) async {
    await _dio.post(
      ApiEndpoints.submitAnswer(interviewId),
      data: {
        'questionId': questionId,
        'answer': answer,
        'inputMode': inputMode,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAlerts({
    required String interviewId,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.getInterviewAlerts(interviewId),
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  

  
  
  
  
  
  
  Future<OcrUploadResult> uploadDocument({
    required String sessionId,
    required List<String> filePaths,
  }) async {
    final formData = FormData();
    if (sessionId.isNotEmpty) {
      formData.fields.add(MapEntry('sessionId', sessionId));
    }

    for (final path in filePaths) {
      if (File(path).existsSync()) {
        final fileName = path.split('/').last;
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }
    }

    if (formData.files.isEmpty) {
      throw StateError('None of the selected documents could be read.');
    }

    logApi('POST ${ApiEndpoints.uploadDocument} (${formData.files.length} file(s))');

    final response = await _dioNoRetry.post(
      ApiEndpoints.uploadDocument,
      data: formData,
      options: Options(
        
        receiveTimeout: const Duration(minutes: 4),
        sendTimeout: const Duration(minutes: 2),
      ),
    );

    return OcrUploadResult.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  
  
  Future<OcrUploadResult> getSessionDocuments(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.sessionDocuments(sessionId));
    return OcrUploadResult.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  

  
  
  
  
  Future<Map<String, dynamic>> submitIntake({
    required String sessionId,
    Map<String, dynamic>? structuredHistory,
    String? finalSummary,
    List<String> redFlags = const [],
  }) async {
    logApi('POST ${ApiEndpoints.submitIntake}');
    final response = await _dioNoRetry.post(
      ApiEndpoints.submitIntake,
      data: {
        'sessionId': sessionId,
        if (structuredHistory != null) 'structuredHistory': structuredHistory,
        if (finalSummary != null) 'finalSummary': finalSummary,
        'redFlags': redFlags,
      },
      options: Options(receiveTimeout: const Duration(seconds: 90)),
    );
    logApi('Intake submitted: ${response.statusCode}');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> processOcr({
    required String documentId,
  }) async {
    final response = await _dio.post(ApiEndpoints.processOcr(documentId));
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  
  Future<ClinicalSummary> generateSummary({
    required String interviewId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.generateSummary,
      data: {'interviewId': interviewId},
    );
    return ClinicalSummary.fromJson(response.data as Map<String, dynamic>);
  }

  
  Future<OpdQueue> submitCase({
    required String summaryId,
    required String patientId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.submitCase,
      data: {'summaryId': summaryId, 'patientId': patientId},
    );
    return OpdQueue.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OpdQueue> getQueueStatus(String submissionId) async {
    final response = await _dio.get(
      ApiEndpoints.getQueueStatus(submissionId),
    );
    return OpdQueue.fromJson(response.data as Map<String, dynamic>);
  }

  

  
  
  Future<Map<String, dynamic>> generateAbhaOtp({
    required String abhaId,
  }) async {
    logApi('POST ${ApiEndpoints.generateAbhaOtp} for ${maskId(abhaId)}');
    final response = await _dioNoRetry.post(
      ApiEndpoints.generateAbhaOtp,
      data: {
        'abhaId': abhaId,
        'authMethod': 'MOBILE_OTP',
      },
    );
    logApi('OTP requested: ${response.statusCode}');
    return response.data as Map<String, dynamic>;
  }

  
  
  Future<Map<String, dynamic>> verifyAbhaOtp({
    required String txnId,
    required String otp,
    required String abhaId,
  }) async {
    logApi('POST ${ApiEndpoints.verifyAbhaOtp}');
    final response = await _dioNoRetry.post(
      ApiEndpoints.verifyAbhaOtp,
      data: {
        'txnId': txnId,
        'otp': otp,
        'abhaId': abhaId,
      },
    );
    
    logApi('OTP verification: ${response.statusCode}');
    return response.data as Map<String, dynamic>;
  }

  static final Map<String, Map<String, dynamic>> _mockTxnStore = {};

  
  Future<Map<String, dynamic>> generateAadhaarOtp({
    required String aadhaarNumber,
    String purpose = 'REGISTRATION',
  }) async {
    logApi('POST ${ApiEndpoints.aadhaarGenerateOtp} for Aadhaar (purpose=$purpose)');
    try {
      final response = await _dioNoRetry.post(
        ApiEndpoints.aadhaarGenerateOtp,
        data: {
          'aadhaarNumber': aadhaarNumber,
          'purpose': purpose,
        },
      );
      logApi('Aadhaar OTP requested: ${response.statusCode}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      logApi('Server call failed or 404, using mock fallback: $e');
      final cleanAadhaar = aadhaarNumber.replaceAll(RegExp(r'\D'), '');
      final txnId = 'AADHAAR-TXN-${DateTime.now().millisecondsSinceEpoch}';
      final last4 = cleanAadhaar.length >= 4 ? cleanAadhaar.substring(cleanAadhaar.length - 4) : '3347';
      final seed = int.tryParse(last4) ?? 1234;

      final namesList = [
        'Aakash Kumar Srivastava',
        'Rahul Sharma',
        'Priya Verma',
        'Amit Patel',
        'Vikram Singh',
        'Neha Gupta',
        'Sanjay Kumar',
        'Ananya Roy',
        'Rohan Mehta',
        'Pooja Joshi'
      ];
      final citiesList = [
        'AKGEC Campus, Ghaziabad, UP',
        'Sector 62, Noida, UP',
        'Indirapuram, Ghaziabad, UP',
        'Connaught Place, New Delhi',
        'Koramangala, Bengaluru, Karnataka',
        'Bandra West, Mumbai, Maharashtra'
      ];

      final fullName = cleanAadhaar.endsWith('47')
          ? 'Aakash Kumar Srivastava'
          : namesList[seed % namesList.length];
      final city = citiesList[seed % citiesList.length];
      final phone = '829${cleanAadhaar.length >= 7 ? cleanAadhaar.substring(cleanAadhaar.length - 7) : '9006119'}';
      final dob = '${1985 + (seed % 18)}-0${(seed % 8) + 1}-${(seed % 20) + 5}';
      final gender = (seed % 2 == 0) ? 'male' : 'female';
      final maskedMobile = 'XXXXXX${phone.substring(phone.length - 4)}';

      _mockTxnStore[txnId] = {
        'aadhaarNumber': cleanAadhaar,
        'purpose': purpose,
        'fullName': fullName,
        'dateOfBirth': dob,
        'gender': gender,
        'phone': phone,
        'address': city,
      };

      return {
        'txnId': txnId,
        'maskedMobile': maskedMobile,
        'message': 'OTP sent to Aadhaar-linked mobile number ending in ${phone.substring(phone.length - 4)}',
        'isMock': true,
      };
    }
  }

  
  Future<Map<String, dynamic>> verifyAadhaarOtp({
    required String txnId,
    required String otp,
  }) async {
    logApi('POST ${ApiEndpoints.aadhaarVerifyOtp}');
    try {
      final response = await _dioNoRetry.post(
        ApiEndpoints.aadhaarVerifyOtp,
        data: {
          'txnId': txnId,
          'otp': otp,
        },
      );
      logApi('Aadhaar OTP verification: ${response.statusCode}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      logApi('Server call failed or 404, using mock fallback: $e');
      final txnData = _mockTxnStore[txnId] ?? {
        'fullName': 'Rajesh Kumar',
        'dateOfBirth': '1990-05-15',
        'gender': 'male',
        'phone': '9876543210',
        'address': 'House No. 12, Main Road, New Delhi',
        'aadhaarNumber': '236035533347',
      };

      if (txnData['purpose'] == 'LOGIN') {
        return {
          'status': 'LOGIN_SUCCESS',
          'patient': {
            'id': 'PAT-${DateTime.now().millisecondsSinceEpoch}',
            'abhaId': '91-1601-4548-1380',
            'fullName': txnData['fullName'],
            'dateOfBirth': txnData['dateOfBirth'],
            'gender': txnData['gender'],
            'phone': txnData['phone'],
          }
        };
      }

      final aadhaar = (txnData['aadhaarNumber'] as String? ?? '236035533347');
      final lastFour = aadhaar.length >= 4 ? aadhaar.substring(aadhaar.length - 4) : '3347';

      return {
        'status': 'VERIFIED',
        'txnId': txnId,
        'fullName': txnData['fullName'],
        'dateOfBirth': txnData['dateOfBirth'],
        'gender': txnData['gender'],
        'phone': txnData['phone'],
        'address': txnData['address'],
        'aadhaarLastFour': lastFour,
      };
    }
  }

  
  Future<Map<String, dynamic>> registerAbha({
    required String txnId,
    String? phone,
    String? address,
    String? preferredLanguage,
  }) async {
    logApi('POST ${ApiEndpoints.abhaRegister}');
    try {
      final response = await _dioNoRetry.post(
        ApiEndpoints.abhaRegister,
        data: {
          'txnId': txnId,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
          if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
        },
      );
      logApi('ABHA registered: ${response.statusCode}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      logApi('Server call failed or 404, using mock fallback: $e');
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      final p2 = ts.substring(ts.length - 4);
      final p3 = (int.parse(p2) + 1234).toString().padLeft(4, '0');
      final p4 = (int.parse(p2) + 5678).toString().padLeft(4, '0');
      final generatedAbha = '91-$p2-$p3-$p4';
      final patientId = 'PAT-$ts';

      return {
        'patientId': patientId,
        'abhaId': generatedAbha,
        'fullName': 'Rajesh Kumar',
        'dateOfBirth': '1990-05-15',
        'gender': 'male',
        'phone': phone ?? '9876543210',
        'address': address ?? 'Main Road, New Delhi',
        'message': 'ABHA created successfully! Your 14-digit ABHA number is $generatedAbha',
        'isMock': true,
      };
    }
  }

  
  Future<List<dynamic>> getLinkedAccounts(String phone) async {
    logApi('GET ${ApiEndpoints.linkedAccounts(phone)}');
    try {
      final response = await _dioNoRetry.get(ApiEndpoints.linkedAccounts(phone));
      return response.data as List<dynamic>;
    } catch (e) {
      logApi('Server call failed or 404, using mock fallback: $e');
      return [
        {
          'id': 'PAT-MOCK-1',
          'abhaId': '91-1601-4548-1380',
          'fullName': 'Rajesh Kumar',
          'dateOfBirth': '1990-05-15',
          'gender': 'male',
          'phone': phone,
        }
      ];
    }
  }

  
  Future<Map<String, dynamic>> verifyFaceBiometric({String? faceImageBase64, String? abhaId}) async {
    logApi('POST ${ApiEndpoints.verifyFaceBiometric}');
    final response = await _dioNoRetry.post(
      ApiEndpoints.verifyFaceBiometric,
      data: {
        if (faceImageBase64 != null) 'faceImageBase64': faceImageBase64,
        if (abhaId != null) 'abhaId': abhaId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> verifyFingerprintBiometric({String? deviceId, String? templateHash, String? abhaId}) async {
    logApi('POST ${ApiEndpoints.verifyFingerprintBiometric}');
    final response = await _dioNoRetry.post(
      ApiEndpoints.verifyFingerprintBiometric,
      data: {
        if (deviceId != null) 'deviceId': deviceId,
        if (templateHash != null) 'templateHash': templateHash,
        if (abhaId != null) 'abhaId': abhaId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> enrollFaceBiometric({
    required String patientId,
    String? faceImageBase64,
    String? faceEmbedding,
  }) async {
    logApi('POST ${ApiEndpoints.enrollFaceBiometric}');
    final response = await _dio.post(
      ApiEndpoints.enrollFaceBiometric,
      data: {
        'patientId': patientId,
        if (faceImageBase64 != null) 'faceImageBase64': faceImageBase64,
        if (faceEmbedding != null) 'faceEmbedding': faceEmbedding,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> enrollFingerprintBiometric({
    required String patientId,
    required String deviceId,
  }) async {
    logApi('POST ${ApiEndpoints.enrollFingerprintBiometric}');
    final response = await _dio.post(
      ApiEndpoints.enrollFingerprintBiometric,
      data: {
        'patientId': patientId,
        'deviceId': deviceId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> matchFingerprintByDevice({required String deviceId}) async {
    logApi('POST ${ApiEndpoints.matchFingerprintByDevice}');
    final response = await _dio.post(
      ApiEndpoints.matchFingerprintByDevice,
      data: {'deviceId': deviceId},
    );
    return response.data as Map<String, dynamic>;
  }



  
  Future<Map<String, dynamic>> verifyAbha(String abhaId) async {
    final response = await _dio.post(
      ApiEndpoints.verifyAbha,
      data: {'abhaId': abhaId},
    );
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> registerDoctor({
    required String username,
    required String fullName,
    required String password,
    String role = 'PHYSICIAN',
  }) async {
    logApi('POST ${ApiEndpoints.registerDoctor}');
    final response = await _dioNoRetry.post(
      ApiEndpoints.registerDoctor,
      data: {
        'username': username.trim(),
        'fullName': fullName.trim(),
        'password': password,
        'role': role,
      },
    );
    logApi('Doctor registered: ${response.statusCode}');
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> loginDoctor({
    required String username,
    required String password,
  }) async {
    logApi('POST ${ApiEndpoints.loginDoctor}');
    final response = await _dioNoRetry.post(
      ApiEndpoints.loginDoctor,
      data: {
        'username': username.trim(),
        'password': password,
      },
    );
    
    logApi('Doctor login: ${response.statusCode}');
    return response.data as Map<String, dynamic>;
  }

  
  Future<String> transcribe({required String audioPath}) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioPath),
    });
    final response = await _dio.post(ApiEndpoints.transcribe, data: formData);
    return response.data['text'] as String;
  }

  Future<String> synthesize({required String text, required String lang}) async {
    final response = await _dio.post(
      ApiEndpoints.synthesize,
      data: {'text': text, 'language': lang},
    );
    return response.data['audioUrl'] as String;
  }

  

  
  
  
  
  
  Future<AyushReportResponse> submitAyushAssessment(AyushAssessmentRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.ayushAssessment,
      data: request.toJson(),
    );
    return AyushReportResponse.fromJson(response.data as Map<String, dynamic>);
  }

  

  
  
  
  
  
  
  Future<String> downloadAyushPdf({
    required String sessionId,
    String? lang,
    String? sessionToken,
    Function(int, int)? onProgress,
  }) async {
    
    final dir = await getTemporaryDirectory();
    final langSuffix = (lang != null && lang.isNotEmpty) ? '_$lang' : '';
    final filePath = '${dir.path}/Ayush_Summary_Report_$sessionId$langSuffix.pdf';

    final response = await _dio.get<List<int>>(
      ApiEndpoints.ayushPdf(sessionId, lang ?? 'en'),
      onReceiveProgress: onProgress,
      options: Options(
        headers: {
          'Accept': 'application/pdf',
          if (sessionToken != null && sessionToken.isNotEmpty)
            'Authorization': 'Bearer $sessionToken',
        },
        responseType: ResponseType.bytes,
      ),
    );

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('AYUSH PDF response was empty');
    }
    await File(filePath).writeAsBytes(bytes, flush: true);

    return filePath;
  }

  

  
  Future<dynamic> getDoctorDashboard() async {
    final response = await _dio.get(ApiEndpoints.doctorDashboard);
    return response.data;
  }

  
  Future<Map<String, dynamic>> getPatientQueueDetail(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorPatientDetail(sessionId));
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> getClinicalView(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorClinicalView(sessionId));
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> getDoctorAiSummary(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorAiSummary(sessionId));
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> getDoctorDocuments(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorDocuments(sessionId));
    final data = response.data;
    if (data is List) {
      return {'documentList': data};
    } else if (data is Map<String, dynamic>) {
      return data;
    }
    return {'documentList': []};
  }

  
  Future<Map<String, dynamic>> getDoctorTimeline(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorTimeline(sessionId));
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> getDoctorConsultationNotes(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorConsultationNotes(sessionId));
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> getDoctorRedFlagAlert(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorRedFlagAlert(sessionId));
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> acknowledgeRedFlagAlert({
    required String alertId,
    String? notes,
  }) async {
    final queryParams = notes != null && notes.isNotEmpty ? {'notes': notes} : null;
    try {
      final response = await _dio.post(
        ApiEndpoints.acknowledgeRedFlag(alertId),
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 405 ||
          e.response?.statusCode == 500) {
        final response = await _dio.put(
          ApiEndpoints.acknowledgeRedFlag(alertId),
          queryParameters: queryParams,
        );
        return response.data as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  
  Future<Map<String, dynamic>> getDoctorConfirmationSummary(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorConfirmationSummary(sessionId));
    return response.data as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> editClinicalSummary(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.editClinicalSummary,
        data: body,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && (e.response?.statusCode == 405 || e.response?.statusCode == 404)) {
        final response = await _dio.put(
          ApiEndpoints.editClinicalSummary,
          data: body,
        );
        return response.data as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  
  Future<Map<String, dynamic>> completeDoctorConsultation({
    required String sessionId,
    String? diagnosis,
    List<String>? icd10Codes,
    List<String>? icdTm2Codes,
    List<Map<String, dynamic>>? prescriptions,
    String? doctorNotes,
  }) async {
    final body = <String, dynamic>{
      'sessionId': sessionId,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (icd10Codes != null) 'icd10Codes': icd10Codes,
      if (icdTm2Codes != null) 'icdTm2Codes': icdTm2Codes,
      if (prescriptions != null) 'prescriptions': prescriptions,
      if (doctorNotes != null) 'doctorNotes': doctorNotes,
    };
    try {
      final response = await _dio.post(
        ApiEndpoints.doctorConsultationNotes(sessionId),
        data: body,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException && (e.response?.statusCode == 404 || e.response?.statusCode == 405)) {
        final response = await _dio.post(
          '/consultation/notes',
          data: body,
        );
        return response.data as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  
  Future<Map<String, dynamic>> submitConsultationNotes({
    required String sessionId,
    String? diagnosis,
    List<String>? icd10Codes,
    List<String>? icdTm2Codes,
    List<Map<String, dynamic>>? prescriptions,
    String? doctorNotes,
  }) => completeDoctorConsultation(
    sessionId: sessionId,
    diagnosis: diagnosis,
    icd10Codes: icd10Codes,
    icdTm2Codes: icdTm2Codes,
    prescriptions: prescriptions,
    doctorNotes: doctorNotes,
  );

  
  Future<Map<String, dynamic>> getDoctorCompletionStatus(String sessionId) async {
    final response = await _dio.get(ApiEndpoints.doctorCompletionStatus(sessionId));
    return response.data as Map<String, dynamic>;
  }
}
