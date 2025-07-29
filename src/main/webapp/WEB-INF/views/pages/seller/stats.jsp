<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/sellerMain.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
h2 {
	padding-left: 20px;
}

.full-width {
	grid-column: span 2;
}
</style>
<h1>
	<img src="${cpath}/resources/images/icons/solar_star-bold.svg"
		alt="상점 통계" class="icon" />
	<c:out value="${userDTO.nickname}" default="딱쿠" />
	사장님의 <span class="highlight"><c:out
			value="${currentStore.storeName}" default="상점" /> 상점 통계</span>
</h1>
<div class="stats-grid">
	<!-- 1개: 월별 주문 및 매출 -->
	<div class="summary-box full-width" style="box-shadow: 6px 6px 0 #FFD600;">
		<h2>월별 주문 및 매출</h2>
		<canvas id="orderChart"></canvas>
	</div>

	<!-- 2개: 인기 상품 + 태그별 주문 수 -->
	<div class="summary-box" style="background-color: #fffdfb">
		<h2>인기 상품 Top 5</h2>
		<canvas id="popularProductChart"></canvas>
	</div>

	<div class="summary-box" style="background-color: #fffdfb">
		<h2>태그별 주문 수</h2>
		<canvas id="tagStatsChart"></canvas>
	</div>

	<!-- 1개: 재구매 상품 → 전체 span 처리 -->
	<div class="summary-box full-width" style="box-shadow: 6px 6px 0 #FFD600;">
		<h2 style="padding-bottom: 0px; margin-bottom: 0px">재구매 Top 5</h2>
		<p style="font-size: 15px; color: gray; padding-left: 20px">(재구매
			횟수 기준)</p>
		<ol class="repurchase-list">
			<c:forEach var="item" items="${topRePurchased}">
				<li><span
					style="font-size: 20px; font-weight: 600; color: #333;">
						${item.productName} </span> <span
					style="color: gray; font-size: 18px; margin-left: 6px;">
						(${item.rePurchaseCount}회) </span></li>
			</c:forEach>
			<c:if test="${empty topRePurchased}">
				<li>재구매 상품 정보가 없습니다.</li>
			</c:if>
		</ol>
	</div>
</div>


<script>
    // 1. 월별 주문/매출
    new Chart(document.getElementById('orderChart'), {
        type: 'bar',
        data: {
            labels: [<c:forEach var="stat" items="${orderStats}">"${stat.month}",</c:forEach>],
            datasets: [
                {
                    label: '주문 수',
                    data: [<c:forEach var="stat" items="${orderStats}">${stat.orderCount},</c:forEach>],
                    backgroundColor: 'rgba(54, 162, 235, 0.7)',
                    yAxisID: 'y'
                },
                {
                    type: 'line',
                    label: '매출 (원)',
                    data: [<c:forEach var="stat" items="${orderStats}">${stat.revenue},</c:forEach>],
                    borderColor: '#f97c5d',
                    backgroundColor: 'rgba(249, 124, 93, 0.2)',
                    borderWidth: 2,
                    tension: 0.4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            interaction: {
                mode: 'index',
                intersect: false
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: { display: true, text: '주문 수', font: { size: 20 } },
                    ticks: { font: { size: 20 } }
                },
                y1: {
                    beginAtZero: true,
                    position: 'right',
                    grid: { drawOnChartArea: false },
                    title: { display: true, text: '매출 (원)', font: { size: 20 } },
                    ticks: { font: { size: 20 } }
                },
                x: {
                    ticks: { font: { size: 20 } }
                }
            },
            plugins: {
                tooltip: {
                	enabled: true, 
                    bodyFont: { size: 13 },
                    titleFont: { size: 13 },
                    callbacks: {
                    	label: function(context) {
                    	    const datasetLabel = context.dataset?.label || '';
                    	    const value = context.formattedValue;

                    	    if (!value) return datasetLabel;

                    	    if (datasetLabel.includes('매출')) {
                    	        return context.formattedValue+"원";
                    	    } else if (datasetLabel.includes('주문')) {
                    	        return context.formattedValue+"건";
                    	    } else {
                    	        return `${datasetLabel}: ${value}`;
                    	    }
                    	}
                    }
                },
                legend: {
                    labels: { font: { size: 20 } }
                }
            }
        }
    });

    // 2. 인기 상품 Pie
    new Chart(document.getElementById('popularProductChart'), {
        type: 'pie',
        data: {
            labels: [<c:forEach var="p" items="${popularProducts}">"${p.label}",</c:forEach>],
            datasets: [{
                data: [<c:forEach var="p" items="${popularProducts}">${p.value},</c:forEach>],
                backgroundColor: [
                    '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
                    '#FF9F40', '#C9CBCF', '#8E44AD', '#2ECC71', '#E67E22'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                tooltip: {
                    bodyFont: { size: 20 },
                    titleFont: { size: 20 }
                },
                legend: {
                    labels: { font: { size: 20 } }
                }
            }
        }
    });

    // 3. 태그별 주문 수 - Doughnut
    new Chart(document.getElementById('tagStatsChart'), {
        type: 'doughnut',
        data: {
            labels: [<c:forEach var="tag" items="${tagStats}">"${tag.label}",</c:forEach>],
            datasets: [{
                data: [<c:forEach var="tag" items="${tagStats}">${tag.value},</c:forEach>],
                backgroundColor: [
                    '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
                    '#FF9F40', '#C9CBCF', '#8E44AD', '#2ECC71', '#E67E22'
                ]
            }]
        },
        options: {
            responsive: true,
            cutout: '60%',
            plugins: {
                tooltip: {
                    bodyFont: { size: 20 },
                    titleFont: { size: 20 }
                },
                legend: {
                    labels: { font: { size: 20 } }
                }
            }
        }
    });
</script>
