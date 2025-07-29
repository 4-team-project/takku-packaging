package com.takku.project.util;

import com.takku.project.errorcode.ErrorCode;

public class ErrorResponse {

	private final String errorCode;
	private final String message;
	private final String detail;

	private ErrorResponse(String errorCode, String message, String detail) {
		this.errorCode = errorCode;
		this.message = message;
		this.detail = detail;
	}

	public static ErrorResponse of(ErrorCode errorCode, String detail) {
		return new ErrorResponse(errorCode.getCode(), errorCode.getMessage(), detail);
	}

	public String getErrorCode() {
		return errorCode;
	}

	public String getMessage() {
		return message;
	}

	public String getDetail() {
		return detail;
	}
}
