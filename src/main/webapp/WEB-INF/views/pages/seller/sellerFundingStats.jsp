<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<link rel="stylesheet"
	href="${cpath}/resources/css/sellerFundingStats.css" />
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<c:set var="rate"
	value="${(funding.currentQty / funding.targetQty) * 100}" />
<div class="main-content">
<c:choose>
<c:when test="${funding.status ne '성공' && funding.status ne '실패'}">
	<div class="funding-title">
		<span class="highlight">${funding.fundingName}</span> 펀딩의 오늘 현황입니다.
	</div>
	<div class="stats-summary">
		<div class="summary-card">
			<span class="title">오늘 펀딩 금액</span>
			<span class="highlight">${todayFundingAmount}</span>
		</div>
		<div class="summary-card">
			<span class="title">오늘 기준 남은 일수</span>
			<span class="highlight">${remainingDays}일</span> <span class="date">(
				<fmt:formatDate value="${funding.endDate}" pattern="yyyy년 MM월 dd일" />
				)
			</span>
		</div>
	</div>
	</c:when>
	
	<c:when test="${funding.status eq '성공' or funding.status eq '실패'}">
	<div class="funding-title">
		<span class="highlight">${funding.fundingName}</span> 펀딩의 결과입니다.
	</div>
	<div class="stats-summary">
		<div class="summary-card">
			<span class="title">일 평균 펀딩 금액</span>
			<span class="highlight"><fmt:formatNumber value="${averageDailyFundingAmount}" pattern="#,###" />원</span>
		</div>
		<div class="summary-card">
			<span class="title">펀딩 종료 일자</span>
			<span class="highlight"><fmt:formatDate value="${funding.endDate}" pattern="yyyy년 MM월 dd일" /></span> 
		</div>
	</div>
	</c:when>
	</c:choose>
	<div class="chart-container">
		<c:choose>
        <c:when test="${funding.status eq '준비중'}">
       <div class="chart-area">
                <p style="text-align: center;  font-size: 1.2em; color: #555;">
                아직 펀딩이 시작하지 않았어요.
            </p>
            </div>
            <div class="chart-area">
                <p style="text-align: center;  font-size: 1.2em; color: #555;">
                아직 펀딩이 시작하지 않았어요.
            </p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="chart-area">
            <span style="text-align: center; font-size: 1.2em; color: #555; font-weight: bold; font-style: normal;">
            남녀 선호도
            </span>
                <canvas id="genderChart" width="400" height="300"></canvas>
            </div>
            <div class="chart-area">
             <span style="text-align: center; font-size: 1.2em; color: #555; font-weight: bold; font-style: normal;">
            연령별 선호도
            </span>
                <canvas id="ageChart" width="400" height="400"></canvas>
            </div>
        </c:otherwise>
    </c:choose>
	</div>
	<div class="stats-details">
		<div class="summary-card-down">
			<span class="title">결제 완료</span>
			<p>
				<span class="highlight">${completeOrders} 건</span>
			</p>
		</div>
		<div class="summary-card-down">
			<span class="title">환불/취소</span>
			<p>
				<span class="highlight">${refundOrders} 건</span>
			</p>
		</div>


	</div>
	<div class="total-stats">
		<div class="summary-card-down">
			<span class="title">총 펀딩 금액</span>
			<p>
				<span class="highlight"><fmt:formatNumber value="${funding.salePrice * funding.currentQty}" pattern="#,###" /> 원</span>
			</p>
		</div>

		<div class="summary-card-down-per">
			<span class="title">달성률</span>
			<div class="rate-container">
				<span class="highlight"> ${funding.currentQty} /
					${funding.targetQty} </span> <span class="highlight percent"> <fmt:formatNumber
						value="${rate}" maxFractionDigits="2" />%
				</span>
			</div>
			<div class="funding-bar">
				<div class="funding-bar-inner" style="width: ${rate}%;"></div>
			</div>
		</div>


		<div class="summary-card-down-date">
			<span class="title">펀딩 기간</span>
			<span class="highlight"> <fmt:formatDate
					value="${funding.startDate}" pattern="yyyy년 MM월 dd일" /> ~ <fmt:formatDate
					value="${funding.endDate}" pattern="yyyy년 MM월 dd일" />
			</span>


		</div>

	</div>
	<input type="hidden" id="userId" name="userId" value="${userId}">
	<div class="action-buttons">
		<button class="back-button" type="button"
			onclick="location.href='${cpath}/seller/store/list?userId=${userId}'">뒤로 가기</button>
		 <c:choose>
        <%-- 펀딩 상태가 '진행중'이거나 '종료'일 경우 --%>
        <c:when test="${funding.status eq '진행중' || funding.status eq '성공' || funding.status eq '실패'}">
            <button type="button" class="button view-button"
                onclick="location.href='${cpath}/fundings/${funding.fundingId}'">펀딩 상세 보기</button>
        </c:when>
       <%--  펀딩 진행중일 떄 수정 (삭제됨)
        <c:otherwise>
            <button type="button" class="button edit-button"
                onclick="location.href='${cpath}/seller/store/funding/edit/${funding.fundingId}'">수정하러 가기</button>
        </c:otherwise> --%>
    </c:choose>
	</div>
</div>

<script>
//성별 차트 데이터
const genderLabels = [
    <c:forEach var="g" items="${fundingGenderStats}" varStatus="loop">
        "${g.label}"<c:if test="${!loop.last}">,</c:if>
    </c:forEach>
];

const genderData = [
    <c:forEach var="g" items="${fundingGenderStats}" varStatus="loop">
        ${g.value}<c:if test="${!loop.last}">,</c:if>
    </c:forEach>
];

const genderChart = new Chart(document.getElementById('genderChart'), {
    type: 'doughnut',
    data: {
        labels: genderLabels,
        datasets: [{
            data: genderData,
            backgroundColor: ['#36a2eb', '#ff6384', '#ffcd56', '#4bc0c0'],
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                position: 'bottom'
            }
        }
    }
});

// 연령대 차트 데이터
const ageLabels = [
    <c:forEach var="a" items="${fundingAgeStats}" varStatus="loop">
        "${a.label}"<c:if test="${!loop.last}">,</c:if>
    </c:forEach>
];

const ageData = [
    <c:forEach var="a" items="${fundingAgeStats}" varStatus="loop">
        ${a.value}<c:if test="${!loop.last}">,</c:if>
    </c:forEach>
];

const ageChart = new Chart(document.getElementById('ageChart'), {
    type: 'bar',
    data: {
        labels: ageLabels,
        datasets: [{
            label: '비율 (%)',
            data: ageData,
            backgroundColor: '#42a5f5'
        }]
    },
    options: {
        scales: {
            y: {
                beginAtZero: true,
                max: 100
            }
        },
        responsive: true,
        plugins: {
            legend: {
                display: false
            }
        }
    }
});
</script>