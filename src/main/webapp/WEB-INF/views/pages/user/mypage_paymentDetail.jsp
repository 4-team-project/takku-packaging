<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<script>
		const cpath = '${cpath}';
	</script>
	<script src="${cpath}/resources/js/paymentDetailJS.js"></script>

	<div id="modal" class="modal" style="display: none;">
		<div class="modal-content">
			<span class="close-btn">&times;</span>
			<h2>결제 상세 정보</h2>
			<hr>
			<div class="modal-info">
				<p>
					<strong>펀딩명:</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span id="modal-fundingName"></span>
				</p>
				<p>
					<strong>수량:</strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span id="modal-qty"></span>
				</p>
				<p>
					<strong>결제날짜:</strong> <span id="modal-purchasedAt"></span>
				</p>
				<p>
					<strong>결제수단:</strong> <span id="modal-paymentMethod"></span>
				</p>
				<p>
					<strong>결제상태:</strong> <span id="modal-status"></span>
				</p>
				<p>
					<span id="modal-success"></span>
				</p>
			</div>

			<div class="modal-buttons">
				<button type="button" class="modal-btn cancel">환불하기</button>
				<button class="modal-btn confirm">확인</button>
			</div>
		</div>
	</div>
</body>
</html>