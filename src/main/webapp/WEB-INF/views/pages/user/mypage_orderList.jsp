<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<div id="resultContainer"></div>
<div class="order-list">

	<c:forEach var="order" items="${orderList}">
		<div class="payment-item order-card">

			<!-- 구매일, 이미지 -->
			<div class="payment-left">
				<div class="payment-date">
					<span class="payment-label">구매일:</span> ${order.purchasedAt}
				</div>
				<div class="payment-image">
					<img src="${cpath}${order.images[0].imageUrl}" alt="메뉴 이미지" />
				</div>
			</div>

			<!-- 오른쪽 내용 -->
			<div class="payment-right">
				<div class="top-row">
					<div class="menu-name">${order.productName}</div>
					<div class="payment-amount">${order.amount}</div>
					<div class="payment-status">${order.status}</div>
					<div class="payment-detail-btn" data-orderid="${order.orderId}">
						<span>결제상세</span>
					</div>

				</div>
				<div class="payment-qty">수량 : ${order.qty}</div>
			</div>

		</div>
	</c:forEach>
</div>