class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data) => ApiResponse(
        success: true,
        data: data,
      );

  factory ApiResponse.error(String error, [int? statusCode]) => ApiResponse(
        success: false,
        error: error,
        statusCode: statusCode,
      );
}