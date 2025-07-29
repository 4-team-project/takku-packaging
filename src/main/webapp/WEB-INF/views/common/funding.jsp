<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet" href="${cpath}/resources/css/pages/user/home.css">



		<div id="initialContent">
			<c:if test="${not empty recommendList}">

				<div class="funding-list-wrapper">
					<c:forEach var="funding" items="${recommendList}" begin="0" end="3">
						<c:choose>
							<c:when test="${funding.targetQty > 0}">
								<c:set var="percent"
									value="${(funding.currentQty * 100.0) / funding.targetQty}" />
							</c:when>
							<c:otherwise>
								<c:set var="percent" value="0" />
							</c:otherwise>
						</c:choose>

						<fmt:formatNumber value="${percent}" maxFractionDigits="0"
							var="percentInt" />

						<div class="funding-box"
							onclick="location.href='${cpath}/fundings/${funding.fundingId}'">
							<c:choose>
								<c:when test="${not empty funding.images}">
									<img class="funding-recommend-image"
										src="${cpath}${funding.images[0].imageUrl}" alt="펀딩 이미지" />
								</c:when>
								<c:otherwise>
									<div class="funding-recommend-image"></div>
								</c:otherwise>
							</c:choose>

							<div class="funding-recommend-contents">
								<div class="funding-title">${funding.fundingName}</div>
								<div class="funding-progress-box">
									<div class="funding-progress-text-box">
										<div class="funding-progress-text">${percentInt}%</div>
									</div>
									<div class="funding-date-box">
										<div class="funding-date">${funding.daysLeft}일</div>
										<div class="funding-date-text">남음</div>
									</div>
								</div>
								<div class="funding-bar">
									<div class="funding-bar-inner" style="width: ${percentInt}%;"></div>
								</div>
							</div>
						</div>
					</c:forEach>
				</div>
			</c:if>

			<!-- 구분선 -->
			<div class="main-bar">
				<div class="main-bar-text">현재 진행 중인 펀딩</div>
			</div>

			<!-- 정렬 필터 -->
			<div class="funding-filter-box" id="sortButtons">
				<div class="funding-filter selected" data-sort-id="popular">
					<div class="funding-filter-text">인기순</div>
				</div>
				<div class="funding-filter" data-sort-id="latest">
					<div class="funding-filter-text">최신순</div>
				</div>
				<div class="funding-filter" data-sort-id="closing">
					<div class="funding-filter-text">마감 임박 순</div>
				</div>
			</div>

			<!-- 기본 펀딩 리스트 -->
			<div class="funding-list-wrapper">
				<c:forEach var="funding" items="${fundinglist}" begin="0" end="7">
					<c:choose>
						<c:when test="${funding.targetQty > 0}">
							<c:set var="percent"
								value="${(funding.currentQty * 100.0) / funding.targetQty}" />
						</c:when>
						<c:otherwise>
							<c:set var="percent" value="0" />
						</c:otherwise>
					</c:choose>
					<fmt:formatNumber value="${percent}" maxFractionDigits="0"
						var="percentInt" />
					<fmt:formatNumber
						value="${((funding.price - funding.salePrice) * 100.0) / funding.price}"
						maxFractionDigits="0" var="discountPercent" />

					<div class="funding-box"
						onclick="location.href='${cpath}/fundings/${funding.fundingId}'">
						<c:choose>
							<c:when test="${not empty funding.images}">
								<img class="funding-image"
									src="${cpath}${funding.images[0].imageUrl}" alt="펀딩 이미지" />
							</c:when>
							<c:otherwise>
								<div class="funding-image"></div>
							</c:otherwise>
						</c:choose>

						<div class="funding-contents">
							<div class="funding-place">${funding.storeName}</div>
							<div class="funding-title">${funding.fundingName}</div>
							<div class="rating-box">
								<img class="rating-img"
									src="${cpath}/resources/images/icons/rating.svg" alt="rating" />
								<fmt:formatNumber value="${funding.avgRating}" type="number"
									maxFractionDigits="1" var="formattedRating" />
								<div class="rating-text">${formattedRating}</div>
								<div class="review-text">(${funding.reviewCnt})</div>
							</div>
							<div class="percent-box">
								<div class="percent-text">${discountPercent}%</div>
								<div class="regular-price-text">
									<fmt:formatNumber value="${funding.price}" type="number"
										groupingUsed="true" />
								</div>
							</div>
							<div class="price-text">
								<fmt:formatNumber value="${funding.salePrice}" type="number"
									groupingUsed="true" />
								원
							</div>
							<div class="funding-progress-box">
								<div class="funding-progress-text-box">
									<div class="funding-progress-text">${percentInt}%</div>
								</div>
								<div class="funding-date-box">
									<div class="funding-date">${funding.daysLeft}일</div>
									<div class="funding-date-text">남음</div>
								</div>
							</div>
							<div class="funding-bar">
								<div class="funding-bar-inner" style="width: ${percentInt}%;"></div>
							</div>
						</div>
					</div>
				</c:forEach>
			</div>
		</div>

