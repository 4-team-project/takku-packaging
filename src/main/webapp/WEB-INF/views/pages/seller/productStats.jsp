<%@ include file="/WEB-INF/views/common/init.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/sellerMain.css">

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/productDetail.css">
<title>상품 통계</title>
<style>
button, button:hover, button:active, button:focus {
	cursor: url('${cpath}/resources/images/cursor.svg') 2 2, auto !important;
	width: 200px;
	height: 70px;
	font-size: 20px;
}

.summary-box {
	margin: 10px 0;
}

.menu-container {
	display: flex;
	flex-direction: row;
	gap: 20px;
}

.menu-box {
	display: flex;
	flex-direction: column;
	gap: 20px;
	border: 1px solid #f1c5b3;
	border-radius: 10px;
	background-color: #fff4ee;
	padding: 20px;
	margin: 20px 0;
	position: relative;
	width: 100%;
	box-sizing: border-box;
	gap: 20px;
}

/* ✅ 이미지: 1열 */
.image-slider {
	grid-column: 1;
	grid-row: 1/span 2;
	aspect-ratio: 4/3;
	background-color: #ddd;
	display: flex;
	align-items: center;
	justify-content: center;
	position: relative;
	border-radius: 8px;
}

.image-slider img {
	width: 316px;
	height: 236px;
	object-fit: cover;
}

.prev-btn, .next-btn {
	all: unset; /* 버튼 스타일 초기화*/
	position: absolute;
	background-color: #FF9670;
	border: none;
	color: white;
	font-size: 20px;
	width: 40px !important;
	height: 40px;
	text-align: center;
	border-radius: 50%;
	line-height: 40px;
}

.prev-btn:hover, .next-btn:hover {
	background-color: #ff774a;
	box-shadow: 0 0 6px rgba(0, 0, 0, 0.2);
	transform: scale(1.05);
	transition: all 0.2s ease;
}

.prev-btn {
	left: 5px;
}

.next-btn {
	right: 5px;
}

/* 메뉴 정보: 1행 2열 */
.menu-info {
	grid-column: 2;
	grid-row: 1;
	text-align: left;
	display: flex;
	flex-direction: column;
	justify-content: center;
	gap: 12px;
}
/* 수정 버튼: 2행 2열 */
.edit-btn-wrap {
	display: flex;
	justify-content: flex-end;
}

.product-name {
	font-size: 32px;
	font-weight: bold;
	margin: 2;
	color: #333;
	width: 320px;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.rating-price {
	display: flex;
	justify-content:space-between;
	gap: 20px;
	font-size: 18px;
	color: #555;
}

.rating {
	background-color: #ffe8a1;
	padding: 6px 10px;
	border-radius: 6px;
	font-size: 22px;
	font-weight: bold;
	display: inline-block;
	gap: 4px;
}

.price {
	font-weight: bold;
	color: #e74a3b;
	font-size: 20px;
}

.description {
	font-size: 20px;
	line-height: 1.6;
	color: #444;
	display: -webkit-box;
	-webkit-line-clamp: 2; /* 최대 2줄까지 */
	-webkit-box-orient: vertical;
	overflow: hidden;
	text-overflow: ellipsis;
}

.review-summary {
	display: flex;
	flex-direction: row;
	gap: 20px;
	margin-top: 10px;
	flex-wrap: wrap;
}

.review-card {
	flex: 1 1 45%;
	background-color: #ffffff;
	border-radius: 12px;
	padding: 16px 20px;
	box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
	min-height: 150px;
}

.review-card.positive {
	border-left: 8px solid #4CAF50;
}

.review-card.negative {
	border-left: 8px solid #F44336;
}

.review-card h3 {
	margin-top: 0;
	margin-bottom: 12px;
	font-size: 20px;
	color: #333;
}

.review-lines {
	font-size: 18px; /* 글자 크기 */
	line-height: 1.8; /* 줄 간격 */
	margin-top: 10px; /* 위쪽 여백 */
	margin-bottom: 10px; /* 아래쪽 여백 */
	color: #333; /* 글자 색 */
}

.summary-box h2 {
	margin-top: 0;
	margin-bottom: 0;
	padding-left: 8px;
	padding-right: 8px;
}
</style>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<div class="main-content"
	style="cursor: url('${cpath}/resources/images/cursor.svg') 2 2, auto;">
	<div class="main-title-box">
		<%@ include file="/WEB-INF/views/common/sellerButton.jsp"%>
		<div class="main-title">${productDTO.productName}통계</div>
	</div>
	<div class="menu-box">
		<div class="menu-container">
			<div class="image-slider">
				<div class="prev-btn" onclick="prevImage()">&lt;</div>
				<img id="menu-image" src="" alt="메뉴 이미지">
				<div class="next-btn" onclick="nextImage()">&gt;</div>
			</div>

			<div class="menu-info">
				<h2 class="product-name">${productDTO.productName}</h2>
				<div class="rating-price">
					<c:choose>
						<c:when
							test="${not empty productDTO.averageRating and productDTO.averageRating > 0}">
							<div class="rating">⭐ ${productDTO.averageRating}</div>
						</c:when>
						<c:otherwise>
							<span class="rating-empty">리뷰가 없습니다</span>
						</c:otherwise>
					</c:choose>
					<br> <span class="price"> <fmt:formatNumber
							value="${productDTO.price}" type="currency" />
					</span>
				</div>
				<p class="description">${productDTO.description}</p>
			</div>

		</div>
		<div class="edit-btn-wrap">
			<button
				onclick="location.href='${cpath}/seller/product/edit/${productDTO.productId}'">
				메뉴 정보 수정</button>
		</div>
	</div>

	<div class="summary-box">
		<h2>리뷰 요약</h2>

		<c:choose>
			<c:when
				test="${not empty positiveSummary or not empty negativeSummary}">
				<!-- ✅ 설명 문구: 리뷰 요약이 있을 때만 보여줌 -->
				<p style="font-size: 17px; color: #666; margin-top: 4px;">최근
					100개의 리뷰를 분석하여 핵심 내용을 자동으로 추출한 것입니다.</p>

				<div class="review-summary">
					<c:if test="${not empty positiveSummary}">
						<div class="review-card positive">
							<h3>👍 긍정 리뷰</h3>
							<ul class="review-lines">
								<c:forEach var="line" items="${positiveSummary}">
                            💬 ${line}<br>
								</c:forEach>
							</ul>
						</div>
					</c:if>

					<c:if test="${not empty negativeSummary}">
						<div class="review-card negative">
							<h3>👎 부정 리뷰</h3>
							<ul class="review-lines">
								<c:forEach var="line" items="${negativeSummary}">
                            💬 ${line}<br>
								</c:forEach>
							</ul>
						</div>
					</c:if>
				</div>
			</c:when>

			<c:otherwise>
				<p style="font-size: 20px; color: #999; padding: 10px;">😢 리뷰
					요약이 없습니다.</p>
			</c:otherwise>
		</c:choose>
	</div>

	<div class="summary">
		<div class="summary-box">
			<h2>연령대 비율</h2>
			<c:choose>
				<c:when test="${not empty productAgeStats}">
					<canvas id="ageChart"></canvas>
				</c:when>
				<c:otherwise>
					<p style="padding: 10px; font-size: 16px; color: #777;">📉 아직
						판매 기록이 없습니다</p>
				</c:otherwise>
			</c:choose>
		</div>

		<div class="summary-box">
			<h2>성별 비율</h2>
			<c:choose>
				<c:when test="${not empty productGenderStats}">
					<canvas id="genderChart"></canvas>
				</c:when>
				<c:otherwise>
					<p style="padding: 10px; font-size: 16px; color: #777;">📉 아직
						판매 기록이 없습니다</p>
				</c:otherwise>
			</c:choose>
		</div>
	</div>
</div>

<script>

console.log("${productDTO}")

const images = [
	<c:forEach var="img" items="${productDTO.images}" varStatus="status">
		"${cpath}${img.imageUrl}"<c:if test="${!status.last}">,</c:if>
	</c:forEach>
];

let currentIndex = 0;
const imgElement = document.getElementById("menu-image");

// ✅ 첫 이미지 표시
if (images.length > 0) {
	imgElement.src = images[0];
}

function showImage(index) {
	if (!images || images.length === 0) return;
	currentIndex = (index + images.length) % images.length;
	imgElement.src = images[currentIndex];
}

function prevImage() {
	showImage(currentIndex - 1);
}

function nextImage() {
	showImage(currentIndex + 1);
}

// ✅ 연령대 차트
new Chart(document.getElementById('ageChart'), {
	type: 'pie',
	data: {
		labels: [<c:forEach var="item" items="${productAgeStats}">"${item.label}",</c:forEach>],
		datasets: [{
			backgroundColor: ['#36b9cc', '#1cc88a', '#f6c23e', '#e74a3b', '#858796'],
			data: [<c:forEach var="item" items="${productAgeStats}">${item.value},</c:forEach>]
		}]
	}
});

// ✅ 성별 차트
new Chart(document.getElementById('genderChart'), {
	type: 'doughnut',
	data: {
		labels: [<c:forEach var="item" items="${productGenderStats}">"${item.label}",</c:forEach>],
		datasets: [{
			backgroundColor: ['#4e73df', '#e74a3b'],
			data: [<c:forEach var="item" items="${productGenderStats}">${item.value},</c:forEach>]
		}]
	}
});
</script>