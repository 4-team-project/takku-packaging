<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet" type="text/css"
	href="${cpath}/resources/css/pages/auth.css">

<c:if test="${param.msg eq 'needLogin'}">
	<script>
		$(function() {
			const msg = '${param.msg}';
			if (msg === 'needLogin') {
				$("#resultModal, #modalBackdrop").fadeIn();
				$("#closeModalBtn").on("click", function() {
					$("#resultModal, #modalBackdrop").fadeOut();
				});
			}
		});
	</script>
</c:if>

<div class="login-container">
	<img src="${cpath}/resources/images/logo.svg" class="logo-img" />

	<c:if test="${not empty resultMessage}">
		<div class="login-error-message">${resultMessage}</div>
	</c:if>

	<div class="login-box">
		<form action="${cpath}/auth/login" method="post">
			<!-- 사용자 / 소상공인 선택 -->
			<div class="user-type-select">
				<label> <input type="radio" name="userType" value="사용자"
					checked /> <span>사용자</span>
				</label> <label> <input type="radio" name="userType" value="소상공인" />
					<span>소상공인</span>
				</label>
			</div>
			
			<!-- 핸드폰 번호 입력 -->
			<div class="input-group">
				<input type="text" id="phone" name="phone" placeholder="휴대폰 번호 (숫자만 입력)"
					required class="form-input" />
			</div>

			<!-- 비밀번호 입력 -->
			<div class="input-group">
				<input type="password" name="password" placeholder="비밀번호" required class="form-input" />
			</div>

			<!-- 로그인 버튼 -->
			<button type="submit" class="login-submit">로그인</button>

			<!-- 링크들 -->
			<div class="login-links">
				<a href="${cpath}/auth/findPassword" id="joinBtn" class="btn"
					style="float: left;">비밀번호 찾기</a> <a href="${cpath}/auth/signup"
					id="joinBtn" class="btn" style="float: right;">회원가입</a>
			</div>
		</form>
	</div>
</div>

<!-- 모달 영역 -->
<div id="resultModal">
	<p id="modalMsg">로그인이 필요합니다.</p>
	<button id="closeModalBtn">확인</button>
</div>

<!-- 모달 배경 -->
<div id="modalBackdrop"></div>

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