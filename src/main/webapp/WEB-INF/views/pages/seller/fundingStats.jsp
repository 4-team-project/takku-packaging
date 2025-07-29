<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<!DOCTYPE html>
<html>
<head>
    <title>펀딩 통계</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 30px;
        }

        h2, h3 {
            margin-top: 40px;
            margin-bottom: 20px;
        }

        .stats-summary {
            display: flex;
            gap: 20px;
            justify-content: space-around;
            margin-bottom: 40px;
        }

        .summary-card {
            flex: 1;
            padding: 20px;
            background-color: #f3f4f6;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        canvas {
            max-width: 100%;
            margin: 0 auto;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>펀딩 통계 (ID: ${fundingId})</h2>

    <div class="stats-summary">
        <div class="summary-card">
            <h3>오늘 펀딩 금액</h3>
            <p><strong>${todayFundingAmount}</strong> 원</p>
        </div>
        <div class="summary-card">
            <h3>결제 완료</h3>
            <p><strong>${completeOrders}</strong> 건</p>
        </div>
        <div class="summary-card">
            <h3>환불/취소</h3>
            <p><strong>${refundOrders}</strong> 건</p>
        </div>
    </div>

    <h3>참여자 성별 분포</h3>
    <canvas id="genderChart" width="400" height="300"></canvas>

    <h3>참여자 연령대 분포</h3>
    <canvas id="ageChart" width="400" height="300"></canvas>
</div>

<script>
    // 성별 차트 데이터
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

</body>
</html>
