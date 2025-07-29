<%@ include file="/WEB-INF/views/common/init.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet"
	href="${cpath}/resources/css/pages/seller/storeManagement.css">
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css" />
<script
	src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>

<div class="main-title-box">
	<img class="main-icon" src="${cpath}/resources/images/icons/store.svg"
		alt="store" />
	<div class="main-text">
		<c:out value="${userDTO.nickname} 사장님의" default="사장님" />
		<div class="highlight">상점 관리</div>
	</div>
</div>
<div class="store-btn-box">
	<div class="store-btn">
		<div class="store-btn-icon">
			<img src="${cpath}/resources/images/sideBar/add_active.svg" alt="add" />
		</div>
		<div class="store-btn-text" style="cursor: pointer"
			onclick="location.href='${cpath}/seller/store/new'">상점 추가하기</div>
	</div>
	<div class="store-btn">
		<div class="store-btn-icon">
			<img src="${cpath}/resources/images/icons/list.svg" alt="list" />
		</div>
		<div class="store-btn-text" style="cursor: pointer"
			onclick="location.href='${cpath}/seller/store/storeList'">상점
			목록보기</div>
	</div>
</div>

<div class="store-info-box">
	<div class="store-info-title">
		<div class="highlight">[현재 상점]</div>
		${currentStore.storeName}
	</div>
	<div class="store-info-content">
		주소:
		<c:out value="${currentStore.sido}" />
		<c:out value="${currentStore.sigungu}" />
		<c:out value="${currentStore.dong}" />
		<c:out value="${currentStore.addressDetail}" />
	</div>
	<div class="store-info-content">
		전화번호:
		<c:out value="${userDTO.phone}" />
	</div>
	<div class="store-edit-btn" style="cursor: pointer"
		onclick="location.href='${cpath}/seller/store/edit/${currentStore.storeId}'">
		<div class="edit-btn-icon">
			<img src="${cpath}/resources/images/icons/edit-black.svg" alt="edit" />
		</div>
		상점 정보 수정
	</div>
</div>

<div class="store-menu-box">
	<div class="store-menu-title">${currentStore.storeName}메뉴</div>

	<c:choose>
		<c:when test="${empty productDTO}">
			<div class="store-menu-content">아직 등록된 메뉴가 없습니다.</div>
		</c:when>

		<c:otherwise>
			<div class="store-menu-content">
				메뉴 사진을 눌러주시면
				<div class="highlight">메뉴 통계</div>
				를 보실 수 있어요.
			</div>

			<div class="store-menu-content-img-container swiper">
				<div class="swiper-wrapper">
					<c:forEach var="product" items="${productDTO}">
						<div class="swiper-slide">
							<img class="store-menu-content-img" style="cursor: pointer"
								onclick="location.href='${cpath}/seller/store/products?productId=${product.productId}'"
								src="${cpath}${product.images[0].imageUrl}"
								alt="${product.productName}" />
							<div class="store-menu-content-name">${product.productName}</div>
						</div>
					</c:forEach>
				</div>

				<div class="swiper-button-circle swiper-button-circle-prev">
					<div class="swiper-button-prev" style="cursor: pointer"></div>
				</div>
				<div class="swiper-button-circle swiper-button-circle-next">
					<div class="swiper-button-next" style="cursor: pointer"></div>
				</div>

				<div class="swiper-pagination" style="cursor: pointer"></div>
			</div>
		</c:otherwise>
	</c:choose>

	<div class="menu-btn-box">
		<div class="menu-edit-btn" style="cursor: pointer"
			onclick="location.href='${cpath}/seller/product/new?storeId=${currentStore.storeId}'">
			<div class="menu-edit-btn-icon">
				<img src="${cpath}/resources/images/sideBar/add_active.svg"
					alt="add" />
			</div>
			메뉴 추가하기
		</div>
		<div class="menu-edit-btn" style="cursor: pointer"
			onclick="location.href='${cpath}/seller/product/productList?storeId=${currentStore.storeId}'">
			<div class="menu-edit-btn-icon">
				<img src="${cpath}/resources/images/icons/list.svg" alt="list" />
			</div>
			메뉴 목록보기
		</div>
	</div>
</div>



<script>
	document
			.addEventListener(
					"DOMContentLoaded",
					function() {
						const slideCount = document
								.querySelectorAll('.store-menu-content-img-container .swiper-slide').length;
						new Swiper(".store-menu-content-img-container", {
							slidesPerView : 3,
							spaceBetween : 20,
							loop : slideCount >= 4,
							pagination : {
								el : ".swiper-pagination",
								clickable : true,
							},
							navigation : {
								nextEl : ".swiper-button-next",
								prevEl : ".swiper-button-prev",
							},
						});
						if (slideCount <= 3) {
							document
									.querySelector('.swiper-button-circle-prev').style.display = 'none';
							document
									.querySelector('.swiper-button-circle-next').style.display = 'none';
						}
					});
</script>

