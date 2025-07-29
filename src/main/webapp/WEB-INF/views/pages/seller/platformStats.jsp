<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<html>
<head>
<title>플랫폼 통계</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
body {
	font-family: 'Noto Sans KR', sans-serif;
	background-color: #f4f6f8;
	margin: 30px;
}

h1 {
	text-align: center;
	margin-bottom: 40px;
}

.grid {
	display: grid;
	grid-template-columns: repeat(2, 1fr);
	gap: 30px;
	max-width: 1000px;
	margin: 0 auto;
}

.card {
	background: white;
	padding: 20px;
	border-radius: 16px;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.08);
}

canvas {
	width: 100% !important;
	height: auto !important;
}
</style>
</head>
<body>

	<h1>📈 플랫폼 기준 통계</h1>

	<div class="grid">
		<div class="card">
			<h2>1. 연령대 분포</h2>
			<canvas id="ageChart"></canvas>
		</div>

		<div class="card">
			<h2>2. 성별 비율</h2>
			<canvas id="genderChart"></canvas>
		</div>

		<div class="card">
			<h2>3. 연령대·성별 인기 태그</h2>
			<ul>
				<c:forEach var="entry" items="${topTagsByGroup}">
					<li><strong>${entry.ageGroup} ${entry.gender}:</strong> <c:forEach
							var="tag" items="${entry.topTags}" varStatus="s">
							${tag}<c:if test="${!s.last}">, </c:if>
						</c:forEach></li>
				</c:forEach>
			</ul>
		</div>
	</div>

	<script>
	new Chart(document.getElementById('ageChart'), {
		type: 'bar',
		data: {
			labels: [<c:forEach var="item" items="${ageDistribution}">"${item.label}",</c:forEach>],
			datasets: [{
				label: '비율 (%)',
				data: [<c:forEach var="item" items="${ageDistribution}">${item.value},</c:forEach>],
				backgroundColor: 'rgba(54, 162, 235, 0.7)'
			}]
		},
		options: {
			responsive: true,
			scales: {
				y: {
					beginAtZero: true,
					max: 100
				}
			},
			plugins: {
				tooltip: {
					callbacks: {
						label: function(context) {
							return context.raw.toFixed(1) + '%';
						}
					}
				}
			}
		}
	});

	new Chart(document.getElementById('genderChart'), {
		type: 'doughnut',
		data: {
			labels: [<c:forEach var="item" items="${genderRatio}">"${item.label}",</c:forEach>],
			datasets: [{
				data: [<c:forEach var="item" items="${genderRatio}">${item.value},</c:forEach>],
				backgroundColor: ['rgba(255, 99, 132, 0.7)', 'rgba(54, 162, 235, 0.7)']
			}]
		},
		options: {
			responsive: true,
			cutout: '60%',
			plugins: {
				tooltip: {
					callbacks: {
						label: function(context) {
							return context.label + ': ' + context.raw.toFixed(1) + '%';
						}
					}
				}
			}
		}
	});
	</script>

</body>
</html>
