package com.takku.project.errorcode;

public enum ErrorCode {

	INTERNAL_ERROR("COMMON-001", "서버 내부 오류", 500), INVALID_INPUT("COMMON-002", "잘못된 입력값입니다.", 400),

	USER_NOT_FOUND("USER-001", "사용자를 찾을 수 없습니다.", 404), DUPLICATE_USER("USER-002", "이미 존재하는 사용자입니다.", 409);

	private final String code;
	private final String message;
	private final int httpStatus;

	ErrorCode(String code, String message, int httpStatus) {
		this.code = code;
		this.message = message;
		this.httpStatus = httpStatus;
	}

	public String getCode() {
		return code;
	}

	public String getMessage() {
		return message;
	}

	public int getHttpStatus() {
		return httpStatus;
	}
}
