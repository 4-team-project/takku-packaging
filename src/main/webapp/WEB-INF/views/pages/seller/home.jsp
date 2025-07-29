<%@ include file="/WEB-INF/views/common/init.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/sellerMain.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
button, button:hover, button:active, button:focus {
	cursor: url('${cpath}/resources/images/cursor.svg') 2 2, auto !important;
}
</style>
<c:choose>
	<c:when test="${empty storeDTO}">
		<h1>
			<img src="${cpath}/resources/images/icons/famicons_today-outline.svg"
				alt="오늘의 펀딩" class="icon" />
			<c:out value="${userDTO.nickname}" default="사장님" />
			사장님의 <span class="highlight">오늘의 상점</span>
		</h1>
		<div class="no-store-box">
			<p>
				<strong> " 아직 등록된 상점이 없습니다. 첫 상점을 등록해보세요! " </strong>
			</p>
			<div class="buttons">
				<button onclick="location.href='${cpath}/seller/store/new'"
					style="max-width: 200px; align-items: center; justify-content: center;">
					새 상점 만들기</button>
			</div>
		</div>

	</c:when>

	<c:otherwise>
		<h1>
			<img src="${cpath}/resources/images/icons/famicons_today-outline.svg"
				alt="오늘의 펀딩" class="icon" />
			<c:out value="${userDTO.nickname}" default="사장님" />
			사장님의 <span class="highlight">오늘의 상점</span> -
			<c:out value="${currentStore.storeName}" default="상점" />
		</h1>
		<div class="summary">
			<div class="summary-box"
				style="background-color: #FFFFFF; box-shadow: 3px 3px 0 #FF9670;">
				<p>오늘 참여</p>
				<strong><c:out value="${todayOrderCount}" />건</strong>
			</div>
			<div class="summary-box"
				style="background-color: #FFFFFF; box-shadow: 3px 3px 0 #FF9670;">
				<p>오늘 매출</p>
				<strong>₩<c:out value="${todaySales}" /></strong>
			</div>
			<div class="summary-box"
				style="background-color: #FFFFFF; box-shadow: 3px 3px 0 #FF9670;">
				<p>진행 중인 펀딩</p>
				<strong><c:out value="${ongoingFundingCount}" />개</strong>
			</div>
			<div class="summary-box"
				style="background-color: #FFFFFF; box-shadow: 3px 3px 0 #FF9670;">
				<p>진행 예정인 펀딩</p>
				<strong><c:out value="${upcomingFundingCount}" />개</strong>
			</div>
		</div>

		<div class="buttons">
			<button style="cursor: pointer"
				onclick="location.href='${cpath}/seller/fundings/create-step1'">
				<img
					src="${pageContext.request.contextPath}/resources/images/icons/fluent_add-16-regular.svg"
					alt="새 펀딩" class="icon" /> 새 펀딩 만들기
			</button>
			<button style="cursor: pointer"
				onclick="location.href='${cpath}/seller/stats?storeId=${storeDTO.storeId}'">
				<img
					src="${pageContext.request.contextPath}/resources/images/icons/bar-chart.svg"
					alt="통계" class="icon" /> 통계 보기
			</button>
			<button style="cursor: pointer"
				onclick="location.href='${cpath}/seller/settlements'">
				<img
					src="${pageContext.request.contextPath}/resources/images/icons/Group.svg"
					alt="정산" class="icon" /> 정산 현황보기
			</button>
		</div>


		<h1>
			<img
				src="${pageContext.request.contextPath}/resources/images/icons/solar_graph-up-linear.svg"
				alt="매출 통계" class="icon" /> 최근 매출 통계
		</h1>
		<div class="sales-box">
			<canvas id="orderChart"></canvas>
		</div>

		<div class="tips">
			<h2 style="padding: 0px; margin: 0px;">
				<img
					src="${pageContext.request.contextPath}/resources/images/icons/check.svg"
					alt="운영 꿀팁" class="icon" /> 운영 꿀팁
			</h2>
			<p>💡 딱쿠 플랫폼을 사용하는 고객들은?</p>

			<div class="stats-grid">
				<div class="summary-box">
					<canvas id="ageChart"></canvas>
				</div>
				<div class="summary-box">
					<canvas id="genderChart"></canvas>
				</div>
				<div class="summary-box tag-box">
					<h2 style="margin-left: 20px;">연령대 · 성별별 인기 태그</h2>
					<ul class="tag-group-list">
						<c:forEach var="entry" items="${topTagsByGroup}">
							<li class="tag-group-item"><span class="tag-label">
									${entry.ageGroup} ${entry.gender} </span> <c:forEach var="tag"
									items="${entry.topTags}">
									<span class="tag-badge">#${tag}</span>
								</c:forEach></li>
						</c:forEach>
					</ul>
				</div>
			</div>
		</div>
	</c:otherwise>
</c:choose>

<!-- 모달 영역 -->
<div id="resultModal">
	<p id="modalMsg">로그인이 필요합니다.</p>
	<button id="closeModalBtn">확인</button>
</div>

<!-- 모달 배경 -->
<div id="modalBackdrop"></div>

<c:if test="${param.msg eq 'needStore'}">
	<script>
		$(function() {
			const msg = '${param.msg}';
			if (msg === 'needLogin') {
				$("#resultModal, #modalBackdrop").fadeIn();
				$("#closeModalBtn").on("click", function() {
					$("#resultModal, #modalBackdrop").fadeOut();
				});
			}
		});
	</script>
</c:if>

<c:if test="${not empty storeDTO}">
	<script>
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
          borderColor: 'rgba(255, 99, 132, 0.9)',
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderWidth: 2,
          fill: true,
          tension: 0.4,
          yAxisID: 'y1'
        }
      ]
    },
    options: {
      responsive: true,
      interaction: { mode: 'index', intersect: false },
      scales: {
        y: {
          beginAtZero: true,
          title: { display: true, text: '주문 수' },
          ticks: { font: { size: 16 } } // ✅ Y축 폰트
        },
        y1: {
          beginAtZero: true,
          position: 'right',
          grid: { drawOnChartArea: false },
          title: { display: true, text: '매출 (원)' },
          ticks: { font: { size: 16 } } // ✅ Y1축 폰트
        }
      },
      plugins: {
        legend: {
          labels: { font: { size: 16 } } // ✅ 범례 폰트
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              const value = context.parsed.y;
              return context.dataset.label + ': ' + (context.dataset.label.includes('매출') ? value.toLocaleString() + '원' : value + '건');
            }
          }
        }
      }
    }
  });

  // 연령대 차트
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
          max: 100,
          ticks: { font: { size: 16} } // ✅ Y축 폰트
        },
        x: {
          ticks: { font: { size: 16 } } // ✅ X축 폰트
        }
      },
      plugins: {
        legend: {
          labels: { font: { size: 16 } } // ✅ 범례 폰트
        }
      }
    }
  });

  // 성별 비율 도넛 차트
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
        legend: {
          labels: { font: { size: 16 } } // ✅ 범례 폰트
        }
      }
    }
  });
</script>
</c:if>

