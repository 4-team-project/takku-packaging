<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<link rel="stylesheet" type="text/css"
	href="${cpath}/resources/css/pages/find_password.css">

<script>
	$(function() {
		$("#cancelJoinBtn").on("click", function() {
			location.href = "${cpath}/auth/login";
		});

		// 모달 열기 함수
		function showModal(message, callback) {
			$("#modalMsg").html(message);
			$("#resultModal, #modalBackdrop").fadeIn();

			$("#closeModalBtn").off("click").on("click", function() {
				$("#resultModal, #modalBackdrop").fadeOut(function() {
					if (callback)
						callback();
				});
			});
		}

		// 인증번호 전송
		$("#sendAuthCodeBtn").on("click", function() {
			const phone = $("input[name='phone']").val();
			if (!phone) {
				showModal("휴대폰 번호를 입력하세요.", function() {
					$("input[name='phone']").focus();
				});
				return;
			}

			$.post("${cpath}/auth/send-auth-code", {
				phone : phone
			}, function(res) {
				if (res === "success") {
					$("#authCodeSection").show();
				} else {
					showModal("인증번호 전송 실패. 다시 시도해주세요.");
				}
			});
		});

		// 인증번호 확인
		$("#verifyAuthCodeBtn").on("click", function() {
			const inputCode = $("#authCodeInput").val();
			if (!inputCode) {
				showModal("인증번호를 입력하세요.", function() {
					$("#authCodeInput").focus();
				});
				return;
			}

			$.post("${cpath}/auth/verify-auth-code", {
				inputCode : inputCode
			}, function(res) {
				if (res === "success") {
					$("#authSuccessMessage").show();
					$("#authVerified").val("true");
				} else {
					showModal("인증번호가 일치하지 않습니다.", function() {
						$("#authCodeInput").focus();
					});
				}
			});
		});

		// 비밀번호 찾기 버튼 클릭 시 본인인증 확인
		$("#joinForm")
				.on(
						"submit",
						function(e) {
							const authVerified = $("#authVerified").val();
							e.preventDefault();
							if (authVerified !== "true") {
								showModal("본인인증이 완료되어야 <br> 비밀번호를 찾을 수 있습니다.",
										function() {
											$("#sendAuthCodeBtn").focus();
										});
								return;
							}

							const name = $("input[name='name']").val();
							const phone = $("input[name='phone']").val();
							const userType = $("input[name='userType']:checked")
									.val();

							$
									.post(
											"${cpath}/auth/findPassword",
											{
												name : name,
												phone : phone,
												userType : userType
											},
											function(res) {
												if (res === "not-found") {
													showModal("입력하신 정보로 등록된 계정이 없습니다.");
												} else {
													showModal(`비밀번호는 <strong style="color:#ff9670">\${res}</strong> 입니다.`);
												}
											});
						});
	});
</script>

<div class="signup-container">
	<img src="${cpath}/resources/images/logo.svg" class="logo-img" />

	<form id="joinForm">
		<!-- 회원 유형 선택 (선택 사항) -->
		<div class="modal-info">
			<p>
				<strong>회원 유형</strong> <label><input type="radio"
					name="userType" value="사용자" checked /> 사용자</label> <label
					style="margin-left: 10px;"><input type="radio"
					name="userType" value="소상공인" /> 소상공인</label>
			</p>
			<p>
				<strong>이름</strong> <input type="text" name="name" required
					class="modal-input" />
			</p>
			<div class="phone-input-row">
				<strong>휴대폰번호(ID)</strong>
				<div class="phone-auth-wrap">
					<input type="text" name="phone" required class="modal-input"
						placeholder="숫자만 입력" />
					<button type="button" class="auth-btn" id="sendAuthCodeBtn">본인인증</button>
				</div>
			</div>

			<!-- 인증번호 입력 섹션 -->
			<div id="authCodeSection" class="auth-code-section"
				style="display: none;">
				<strong>인증번호</strong>
				<div class="phone-auth-wrap">
					<input type="text" id="authCodeInput" class="modal-input"
						placeholder="인증번호 입력" />
					<button type="button" class="auth-btn" id="verifyAuthCodeBtn">확인</button>
				</div>
			</div>
			<!-- 인증 성공 메시지 -->
			<p id="authSuccessMessage"
				style="display: none; color: green; font-size: 14px; margin-left: 113px;">
				본인인증이 완료되었습니다.</p>
			<input type="hidden" name="authVerified" id="authVerified"
				value="false" />
		</div>

		<div class="modal-buttons">
			<button type="button" class="modal-btn cancel" id="cancelJoinBtn">취소</button>
			<button type="submit" class="modal-btn confirm">비밀번호 찾기</button>
		</div>
	</form>

	<!-- 모달 영역 -->
	<div id="resultModal">
		<p id="modalMsg"></p>
		<button id="closeModalBtn">확인</button>
	</div>

	<!-- 모달 배경 -->
	<div id="modalBackdrop"></div>
</div>