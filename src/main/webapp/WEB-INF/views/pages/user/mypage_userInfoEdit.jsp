<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<script src="${cpath}/resources/js/userInfoEditJS.js"></script>

	<!-- 내 정보 수정 모달 -->
	<div id="user-info-modal" class="modal" style="display: none">
		<div class="modal-content">
			<span class="close-btn">&times;</span>
			<h2 class="modal-title">내 정보 수정</h2>

			<form id="user-info-form">
				<p>
				<strong for="name">이름&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong> <input type="text" id="name"
					name="name" class="input-no-border" value="${user.name}" readonly /><br>
				</p>	
				<p>
				<strong for="phone">전화번호</strong> <input type="tel" id="phone"
					name="phone" class="input-no-border" value="${user.phone}" readonly /><br>
				</p>	
				<p>	
				<strong for="birth">생년월일</strong> <input type="text" id="birth"
					name="birth" class="input-no-border" value="${user.birth}" readonly /><br>		
				</p>
				<p>
				<strong for="gender">성별&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong> <input type="text" name="gender"
					id="gender" class="input-no-border" value="${user.gender }자"
					readonly /><br> 
				</p>
				<p>
				<strong for="addr">지역&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong> <input
					type="text" class="input-no-border" id="sido"
					value="${user.sido } ${user.sigungu}"><br>
				</p>
				<hr>

				<div class="form-row">
					<strong for="nickname">닉네임&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong> 
					<input type="text" id="nickname"
						name="nickname" value="${user.nickname}" /><br>
				</div>

	
				<div class="form-row">
					<strong for="password">새 비밀번호&nbsp;&nbsp;&nbsp;&nbsp;</strong> <input type="text"
						id="password" name="password" autocomplete="off" />
				</div>

				<div class="condition" style="color:red;">
					<div>영어와 숫자 조합으로 6자 이상 입력해주세요</div>
				</div>

				<div class="form-row">
					<strong for="passwordConfirm">비밀번호 확인&nbsp;</strong> <input type="password"
						id="passwordConfirm" name="passwordConfirm" />
				</div>

			</form>

			<div class="modal-buttons">
				<button type="button" class="modal-btn Ucheck">취소</button>
				<button type="button" class="modal-btn Uedit">수정하기</button>			
			</div>
		</div>
	</div>
<!-- 모달 배경 -->
<div id="modalBackdrop"></div>	
</body>
</html>