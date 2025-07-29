<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet" type="text/css"
	href="${cpath}/resources/css/pages/auth_signup.css">

<script>
	$(function() {
		$("#cancelJoinBtn").on("click", function() {
			location.href = "${cpath}/auth/login";
		});
		
		// 모달 열기 함수
		function showModal(message, callback) {
			$("#modalMsg").text(message);
			$("#resultModal").fadeIn();

			$("#closeModalBtn").off("click").on("click", function() {
				$("#resultModal").fadeOut(function() {
					if (callback)
						callback();
				});
			});
		}
		
		//비밀번호 유효성 검사
		$("#password").on("input", function () {
		    const password = $(this).val();
		    const errorSpan = $("#passwordError");
		    const successSpan = $("#passwordSuccess");

		    fetch("${cpath}/api/v1/validations/password-format", {
		        method: "POST",
		        headers: {
		            "Content-Type": "application/json"
		        },
		        body: JSON.stringify({ password: password })
		    })
		    .then(response => response.json())
		    .then(data => {
		        if (data.valid) {
		            errorSpan.hide();
		            successSpan.text("사용 가능한 비밀번호입니다.").show();
		        } else {
		            successSpan.hide();
		            if (password.length < 6) {
		                errorSpan.text("비밀번호는 최소 6자 이상이어야 합니다.").show();
		            } else {
		                errorSpan.text("비밀번호는 영문자와 숫자를 포함해야 합니다.").show();
		            }
		        }
		    })
		});

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

		// 가입하기 버튼 클릭 시 본인인증 확인
		$("#joinForm").on("submit", function(e) {
			const authVerified = $("#authVerified").val();
			if (authVerified !== "true") {
				e.preventDefault();
				showModal("본인인증이 완료되어야 가입할 수 있습니다.", function() {
					$("#sendAuthCodeBtn").focus();
				});
			}
		});

		// 중복 계정 확인 함수
		function checkDuplicate() {
			const phone = $("input[name='phone']").val();
			const userType = $("input[name='userType']:checked").val();

			if (!phone || !userType) {
				$("#duplicateMsg").hide();
				return;
			}

			$.post("${cpath}/auth/check-duplicate", {
				phone : phone,
				userType : userType
			}, function(res) {
				if (res.exists) {
					$("#duplicateMsg").text("중복된 계정입니다. 다른 번호를 입력하세요.").show();
				} else {
					$("#duplicateMsg").hide();
				}
			});
		}

		$("input[name='userType']").on("change", checkDuplicate);
		$("input[name='phone']").on("blur", checkDuplicate);

		$("#joinForm").on("submit", function(e) {
			if ($("#duplicateMsg").is(":visible")) {
				e.preventDefault();
				showModal("중복된 계정이므로 가입할 수 없습니다.");
			}
		});
	});
</script>


<div class="signup-container">
	<img src="${cpath}/resources/images/logo.svg" class="logo-img" />

	<form id="joinForm" method="post" action="${cpath}/auth/signup">
		<!-- 회원 유형 선택 (선택 사항) -->
		<div class="modal-info">
			<p>
				<strong>회원 유형</strong> <label><input type="radio"
					name="userType" value="사용자" checked /> 사용자</label> <label
					style="margin-left: 10px;"><input type="radio"
					name="userType" value="소상공인" /> 소상공인</label>
			</p>
			<div class="phone-input-row">
				<strong>휴대폰번호(ID)</strong>
				<div class="phone-auth-wrap">
					<input type="text" id="phone" name="phone" required class="modal-input"
						placeholder="숫자만 입력" />
					<button type="button" class="auth-btn" id="sendAuthCodeBtn">본인인증</button>
				</div>
			</div>
			<!-- 중복된 계정 메시지 -->
			<div class="duplicate-msg-wrap">
				<p id="duplicateMsg">중복된 계정입니다. 다른 번호를 입력하세요.</p>
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

			<p>
				<strong>비밀번호</strong> 
				<input type="text" name="password" id="password" required class="modal-input" style="width: 300px;" />
			</p>  
			<span id="passwordError" style="color: red; font-size: 14px; display: none; margin-left: 112px;"></span>
  			<span id="passwordSuccess" style="color: green; font-size: 14px; display: none; margin-left: 112px;"></span>

			<p>
				<strong>이름</strong> <input type="text" name="name" required
					class="modal-input" />
			</p>
			<p>
				<strong>성별</strong> <label><input type="radio" name="gender"
					value="남" checked /> 남</label> <label style="margin-left: 10px;"><input
					type="radio" name="gender" value="여" /> 여</label>
			</p>
			<p>
				<strong>생년월일</strong> <input id="birth" type="text" name="birth" required
					class="modal-input" placeholder="yyyy-mm-dd" />
			</p>
			<p>
				<strong>닉네임</strong> <input type="text" name="nickname" required
					class="modal-input" />
			</p>

			<!-- 주소 api js 추가 -->
			<script src="${cpath}/resources/js/address.js"></script>
			<script
				src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

			<div class="address-section">
				<p class="address-row">
					<strong>주소</strong> 
					<input type="text" name="postcode" id="postcode" class="modal-input small-input" placeholder="우편번호" readonly>
					<button type="button" class="auth-btn" onclick="execDaumPostcode()">주소 검색</button>
					<button type="button" class="auth-btn" id="clearAddressBtn">지우기</button>
				</p>

				<input type="hidden" id="sido" name="sido"> 
				<input type="hidden" id="sigungu" name="sigungu">

				<p>
					<strong>&nbsp&nbsp&nbsp&nbsp&nbsp</strong> 
					<input type="text" name="roadAddress" id="roadAddress" class="modal-input" placeholder="도로명 주소" readonly>
				</p>

				<p>
					<strong>&nbsp&nbsp&nbsp&nbsp&nbsp</strong> 
					<input type="text" name="jibunAddress" id="jibunAddress" class="modal-input" placeholder="지번 주소 (선택)" readonly>
				</p>
			</div>



		</div>

		<div class="modal-buttons">
			<button type="button" class="modal-btn cancel" id="cancelJoinBtn">취소</button>
			<button type="submit" class="modal-btn confirm">가입하기</button>
		</div>
	</form>

	<!-- 모달 영역 -->
	<div id="resultModal">
		<p id="modalMsg"></p>
		<button id="closeModalBtn">확인</button>
	</div>
</div>

<%-- 메시지 출력 스크립트 --%>
<c:if test="${not empty resultMessage}">
	<script>
		$(function() {
			var isSuccess = "${isSuccess}" === "true";
			$("#modalMsg").text("${resultMessage}");
			$("#resultModal").fadeIn();

			$("#closeModalBtn").on("click", function() {
				$("#resultModal").fadeOut(function() {
					if (isSuccess) {
						location.href = "${cpath}/auth/login";
					}
				});
			});
		});
	</script>
</c:if>

<script>
document.getElementById('phone').addEventListener('input', function (e) {
  let input = e.target.value.replace(/[^0-9]/g, ''); // 숫자만
  let result = '';

  if (input.length < 4) {
    result = input;
  } else if (input.length < 8) {
    result = input.slice(0, 3) + '-' + input.slice(3);
  } else {
    result = input.slice(0, 3) + '-' + input.slice(3, 7) + '-' + input.slice(7, 11);
  }

  e.target.value = result;
});
</script>

<script>
document.getElementById('birth').addEventListener('input', function (e) {
  let input = e.target.value.replace(/[^0-9]/g, '').slice(0, 8); // 숫자만, 최대 8자리
  let formatted = '';

  if (input.length < 5) {
    formatted = input;
  } else if (input.length < 7) {
    formatted = input.slice(0, 4) + '-' + input.slice(4);
  } else {
    formatted = input.slice(0, 4) + '-' + input.slice(4, 6) + '-' + input.slice(6);
  }

  e.target.value = formatted;
});
</script>