<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<script
	src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
<script src="https://kit.fontawesome.com/5db5b8890b.js"
	crossorigin="anonymous"></script>
<c:set var="qrBaseUrl"
	value="https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=http%3A%2F%2F192.168.0.22%3A9999%2Fcoupon%2FsellerCheck%3FcouponCode%3D" />
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/seller_check.css" />
<c:set var="qrUrl" value="${qrBaseUrl}${coupon.couponCode}" />
<c:choose>
	<c:when test="${not empty coupon}">
		<div class="coupon-card" id="couponCard"
			data-funding-name="${fn:escapeXml(funding.fundingName)}">
			<div class="coupon-card-store">
				<i class="fas fa-store"></i>&nbsp;${store.storeName}
			</div>

			<div class="coupon-card-funding">&nbsp;${funding.fundingName}</div>

			<div class="coupon-card-product">&nbsp;${product.productName}</div>

			<div class="productImages">
				<c:choose>
					<c:when test="${not empty image}">
						<img src="${cpath}${image[0].imageUrl}" alt="상품 이미지" />
					</c:when>
					<c:otherwise>
						<img src="${cpath}/resources/images/noimage.jpg" alt="이미지 없음" />
					</c:otherwise>
				</c:choose>
			</div>

			<h2>${coupon.useStatus}</h2>

			<div class="coupon-date">
				<strong>사용기한 :</strong>
				<fmt:formatDate value="${coupon.createdAt}" pattern="yyyy-MM-dd" />
				~
				<fmt:formatDate value="${coupon.expiredAt}" pattern="yyyy-MM-dd" />
			</div>

			<br>

			<c:if test="${coupon.useStatus eq '미사용'}">
				<form action="${cpath}/coupon/use" method="get">
					<input type="hidden" name="couponCode" value="${coupon.couponCode}" />
					<button type="submit">쿠폰 사용 처리</button>
				</form>
			</c:if>

			<c:if test="${coupon.useStatus eq '사용'}">
				<p style="color: red;">이미 사용된 쿠폰입니다.</p>
			</c:if>
		</div>
	</c:when>
	<c:when test="${empty coupon}">
		<div class="empty-coupon">
			<strong>잘못된 접근 혹은 쿠폰 정보를 불러오지 못했습니다.</strong> <br> <strong>다시
				확인해주세요.</strong>
		</div>
	</c:when>
</c:choose>