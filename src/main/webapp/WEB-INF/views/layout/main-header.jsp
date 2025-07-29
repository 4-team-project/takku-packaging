<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet"
	href="${cpath}/resources/css/layout/main-header.css" />

<div class="box"></div>
<div class="header-box">
	<div class="logo" onclick="location.href='${cpath}/user/home'">
		<img src="${cpath}/resources/images/logo.svg" alt="logo" />
	</div>
	<div class="lower-box">
		<%@ include file="/WEB-INF/views/common/searchBox.jsp"%>
		<div class="nav-box">
			<c:choose>
				<c:when test="${not empty loginUser}">
					<c:if test="${loginUser.userType == '사용자'}">
						<div class="nav-text"
							onclick="location.href='${cpath}/user/coupon'">내 쿠폰함</div>
					</c:if>
					<c:if test="${loginUser.userType == '사용자'}">
						<div class="nav-text"
							onclick="location.href='${cpath}/user/mypage'">마이페이지</div>
					</c:if>
					<c:if test="${loginUser.userType == '소상공인'}">
						<div class="nav-text"
							onclick="location.href='${cpath}/seller/home'">소상공인 페이지</div>
					</c:if>
					<form id="logoutForm" action="${cpath}/auth/logout" method="post"
						style="display: none;"></form>
					<div class="nav-text"
						onclick="document.getElementById('logoutForm').submit();">로그아웃</div>
				</c:when>
				<c:otherwise>
					<div class="nav-text" onclick="location.href='${cpath}/auth/login'">로그인</div>
					<div class="nav-text"
						onclick="location.href='${cpath}/auth/signup'">회원가입</div>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
</div>
