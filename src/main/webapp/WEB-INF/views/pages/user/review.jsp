<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<div class="review-box">
	<div class="review-box-header">
		<h2>리뷰 작성</h2>
		<button class="review-close-btn" onclick="openConfirmModal()">✕</button>
	</div>

	<div class="info">
		<p>
			<strong>펀딩명 </strong>
			<c:out value="${fundingDTO.fundingName}" default="-" />
		</p>
		<p>
			<strong>사용 날짜 </strong>
			<c:choose>
				<c:when test="${couponDTO.usedAt == null}">미사용 쿠폰</c:when>
				<c:otherwise>
					<fmt:formatDate value="${couponDTO.usedAt}"
						pattern="yyyy.MM.dd HH:mm" />
				</c:otherwise>
			</c:choose>
		</p>
	</div>
	<form id="reviewForm" method="post" enctype="multipart/form-data"
		action="${cpath}/review">
		<input type="hidden" name="productId" value="${fundingDTO.productId}" />
		<input type="hidden" id="coupon-id-hidden" value="${couponDTO.couponId}">
		<input type="hidden" name="userId" value="${couponDTO.userId}" /> <label>별점</label>
		<div class="star-rating">
			<span data-value="1">★</span><span data-value="2">★</span><span
				data-value="3">★</span><span data-value="4">★</span><span
				data-value="5">★</span>
		</div>
		<input type="hidden" name="rating" id="rating" required /> <label
			for="content">리뷰 내용</label>
		<textarea name="content" id="content" placeholder="리뷰를 입력하세요."
			required></textarea>
		<label for="images" class="custom-file-upload">사진 선택</label> <input
			type="file" id="images" name="images" multiple accept="image/*"
			onchange="handleFiles(this.files)" />
		<div id="preview-container"
			style="margin-top: 10px; display: flex; flex-wrap: wrap; gap: 10px;"></div>
		<div class="modal-buttons">
			<button type="button" class="modal-btn Ucheck"
				onclick="openConfirmModal()">취소하기</button>
			<button type="submit" class="modal-btn Uedit">리뷰 등록</button>
		</div>
	</form>
</div>
<!-- 리뷰 작성 종료 모달 -->
<div class="modal-overlay" id="confirmModal" style="display: none;">
	<div class="modal-dialog">
		<div class="modal-header">
			<span>리뷰 작성</span>
			<button class="close-btn" onclick="closeConfirmModal()">✕</button>
		</div>
		<hr />
		<div class="modal-content">
			<p class="modal-title">리뷰 작성을 취소하시겠습니까?</p>
			<p class="modal-desc">작성된 내용은 저장되지 않습니다.</p>
		</div>
		<div class="modal-buttons">
			<button class="modal-cancel" onclick="exitReview()">닫기</button>
			<button class="modal-confirm" onclick="closeConfirmModal()">리뷰
				계속 쓰기</button>
		</div>
	</div>
</div>

<!-- 등록 성공 모달 -->
<div class="modal-overlay" id="successModal" style="display: none;">
	<div class="modal-dialog">
		<div class="modal-header">
			<span>리뷰 작성</span>
			<button class="close-btn" onclick="closeConfirmModal()">✕</button>
		</div>
		<hr />
		<div class="modal-content">
			<p class="modal-title" style="font-size: 18px; color: #ff7f50;">리뷰가
				등록되었습니다!</p>
			<p class="modal-desc" style="font-size: 14px; margin-top: 4px;">
				작성하신 리뷰를 보시려면 리뷰 보러 가기를 눌러주세요</p>
		</div>
		<div class="modal-buttons">
			<button class="modal-cancel" onclick="closeSuccessModal()">닫기</button>
			<button class="modal-confirm" id="reviewSuccessBtn"
				data-funding-id="${fundingDTO.fundingId}">리뷰 보러 가기</button>
		</div>
	</div>
</div>
