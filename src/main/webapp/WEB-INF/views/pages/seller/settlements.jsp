<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<link rel="stylesheet"
	href="${cpath}/resources/css/pages/seller/settlements.css">
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<div
	style="display: flex; align-items: center; gap: 20px; margin-top: 20px; min-width: 500px;">
	<img src="${cpath}/resources/images/settlement.svg" alt="settlement" />
	<h2 style="margin: 0;">${userDTO.nickname} 사장님의 정산 현황을 확인하세요.</h2>
</div>

<div class="settlement-box" id="settlementContainer">
	<!-- 정산 내역 카드가 JS로 동적으로 삽입됩니다 -->
</div>

<script>
function formatCurrency(num) {
	return num.toLocaleString() + " 원";
}

function formatDate(dateStr) {
	if (!dateStr) return '-';
	const date = new Date(dateStr);
	return date.toLocaleDateString('ko-KR');
}

function loadSettlementPage(page) {
	$.ajax({
		url: `${cpath}/seller/settlements/list`,
		method: 'GET',
		data: { page: page },
		success: function(data) {
			const list = data.settlementlist;
			const currentPage = data.currentPage;
			const totalPages = data.totalPages;
			let html = '';

			if (!list || list.length === 0) {
				html += `
					<div class="no-settlement-message">
						정산 내역이 존재하지 않습니다.
					</div>
				`;
			}else{
			list.forEach(settlement => {
				html += `
					<div class="settlement-card">
						<div class="settlement-inner">
							<!-- 이미지 -->
							\${settlement.funding.images && settlement.funding.images.length > 0 ? `
									<div class="settlement-img">
										<img src="${cpath}\${settlement.funding.images[0].imageUrl}" alt="펀딩 이미지" />
									</div>		
									` : `<div class="settlement-img">
											<img src="${cpath}/resources/images/noimage.jpg"/>
										 </div>`}
							<!-- 정보 -->
							<div class="settlement-info-grid">
								<div><strong>펀딩 이름 :</strong></div>
								<div>\${settlement.funding.fundingName}</div>
								<div><strong>수 수 료 :</strong></div>
								<div>\${formatCurrency(settlement.fee)}</div>
								<div><strong>정산 금액 :</strong></div>
								<div>\${formatCurrency(settlement.amount)}</div>
								<div><strong>정산 상태 :</strong></div>
								<div>\${settlement.status}</div>
								<div><strong>정산 날짜 :</strong></div>
								<div>\${formatDate(settlement.settledAt)}</div>
							</div>

							<!-- 상세보기 버튼 -->
							<div class="settlement-action">
								<form action="${cpath}/seller/store/stats" method="get">
									<input type="hidden" name="fundingId" value="\${settlement.fundingId}" />
									<button type="submit">상세보기</button>
								</form>
							</div>
						</div>
					</div>
				`;
			});			

			// 페이징 처리
			html += `<div class="pagination">`;
			for (let i = 1; i <= totalPages; i++) {
				if (i === currentPage) {
					html += `<button class="page-link active" disabled>\${i}</button>`;
				} else {
					html += `<button class="page-link" data-page="\${i}">\${i}</button>`;
				}
			}
			html += `</div>`;
		}
			$("#settlementContainer").html(html);
		},
		error: function() {
			alert("정산 데이터를 불러오는 데 실패했습니다.");
		}
	});
}

$(document).ready(function() {
	loadSettlementPage(1);
});

$(document).on("click", ".page-link", function(e) {
	e.preventDefault();
	const page = $(this).data("page");
	loadSettlementPage(page);
});
</script>
