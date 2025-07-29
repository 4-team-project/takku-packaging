<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<link rel="stylesheet"
	href="${cpath}/resources/css/seller_funding_list.css" />
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%-- userId 값을 숨겨진 필드에 저장 --%>
<input type="hidden" id="currentUserId"
	value="${store != null ? store.userId : ''}">
<input type="hidden" id="currentStoreId" value="${currentStore.storeId}" />
<div class="seller-funding-content">
	<div class="header-section">

		<h2 class="page-title">
			<img alt="svg" class="image"
				src="${cpath}/resources/images/icons/calendar.svg">${user.nickname}
			사장님의 펀딩 현황
		</h2>
		<span class="page-description">보고 싶은 펀딩을 눌러보세요. 자세한 내용을 확인할 수
			있습니다.</span><br> <span class="funding-status-summary">${store.storeName} 가게의 
			<strong id="currentFilterStatus">전체</strong> 펀딩은 <strong
			id="currentFundingCount">${fn:length(fundingList)}</strong>개입니다.
		</span>
	</div>
	<!-- 다른 지점 store 리스트 -->
	<div id="storeListContainer" style="display: none;"></div>

	<div id="fundingCountSummary"></div>

	<div class="funding-summary-section">
		<div class="funding-tabs">
			<button id="tabAll" class="active" data-status="all">전체</button>
			<button id="tabInProgress" data-status="진행중">진행중</button>
			<button id="tabScheduled" data-status="준비중">준비중</button>
			<button id="tabEnded" data-status="종료">종료</button>
		</div>
	</div>



	<!-- 펀딩 리스트 출력 영역 -->
	<div id="fundingListContainer">
		<c:forEach var="funding" items="${funding}" varStatus="status">
			<c:set var="current"
				value="${funding.currentQty != null ? funding.currentQty : 0}" />
			<c:set var="target"
				value="${funding.targetQty != null && funding.targetQty != 0 ? funding.targetQty : 1}" />
			<c:set var="rate" value="${(current * 100) / target}" />

			<div class="funding-card"
				onclick="location.href='\${cpath}' + '/seller/store/funding/stats?fundingId=${funding.fundingId}'">
				<div class="funding-info">
					<h3 class="funding-title">${status.index + 1}.
						${funding.fundingName}</h3>
					<div class="funding-date">
						<fmt:formatDate value="${funding.startDate}" pattern="yyyy년 M월 d일" />
						~
						<fmt:formatDate value="${funding.endDate}" pattern="yyyy년 M월 d일" />
					</div>
					<div class="progress-bar-wrapper">
						<div class="progress-bar-container">
							<div class="progress-bar" style="width: ${rate}%"></div>
						</div>
						<div class="progress-percentage">${rate}%</div>
					</div>
				</div>

				<!-- 상태 뱃지 -->
				<c:choose>
					<c:when test="${funding.status == '진행중'}">
						<span class="funding-status status-in-progress">진행중</span>
					</c:when>
					<c:when test="${funding.status == '준비중'}">
						<span class="funding-status status-scheduled">준비중</span>
					</c:when>
					<c:otherwise>
						<span class="funding-status status-ended">종료</span>
					</c:otherwise>
				</c:choose>
			</div>
		</c:forEach>
	</div>
</div>
<script src="${cpath}/resources/js/seller_funding_list.js">
	const initialFundings = JSON
			.parse('${fn:escapeXml(objectMapper.writeValueAsString(funding))}');
	const storeList = JSON
			.parse('${fn:escapeXml(objectMapper.writeValueAsString(userStores))}');
	const currentStore = JSON
			.parse('${fn:escapeXml(objectMapper.writeValueAsString(store))}');
	const cpath = '${cpath}';
</script>

