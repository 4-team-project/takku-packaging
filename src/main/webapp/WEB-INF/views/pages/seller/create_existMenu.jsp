<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/createFunding_exist_normal.css">

<input type="hidden" id="storeIdHolder" value="${storeDTO.storeId}" />

<script>
	let basePrice = null;

	function getSelectedProductIdFromURL() {
		const params = new URLSearchParams(window.location.search);
		return params.get('selectedProductId');
	}

	$(document)
			.ready(
					function() {
						const storeId = $('#storeIdHolder').val();
						const selectedId = getSelectedProductIdFromURL();

						if (!storeId) {
							alert("상점 정보를 불러올 수 없습니다.");
							return;
						}

						// 메뉴 목록 불러오기
						$
								.ajax({
									url : '${pageContext.request.contextPath}/seller/product/list',
									method : 'GET',
									data : {
										storeId : storeId
									},
									success : function(productList) {
										$('#menuSelect')
												.html(
														'<option value="" disabled selected>메뉴를 선택해주세요.</option>');
										$
												.each(
														productList,
														function(i, product) {
															const option = $(
																	'<option></option>')
																	.val(
																			product.productId)
																	.text(
																			product.productName);
															if (selectedId
																	&& product.productId == selectedId) {
																option
																		.prop(
																				'selected',
																				true);
															}
															$('#menuSelect')
																	.append(
																			option);
														});

										if (selectedId) {
											$('#menuSelect').trigger('change');
											history.replaceState({},
													document.title,
													window.location.pathname); // URL 깔끔하게
										}
									}
								});

						// 정가 불러오기
						$('#menuSelect')
								.on(
										'change',
										function() {
											const productId = $(this).val();
											$
													.ajax({
														url : '${pageContext.request.contextPath}/seller/product/info',
														method : 'GET',
														data : {
															productId : productId
														},
														dataType : 'json',
														success : function(
																product) {
															if (product
																	&& product.price != null) {
																basePrice = product.price;
																$('#menuPrice')
																		.attr(
																				'placeholder',
																				basePrice);
																$('#menuPrice')
																		.val('');
																$(
																		'#discountRate')
																		.text(
																				'할인율은 %입니다.');
																updateMinPrice();
															} else {
																basePrice = null;
																$('#menuPrice')
																		.attr(
																				'placeholder',
																				'가격 정보를 불러오지 못했습니다.');
															}
														}
													});
										});

						// 할인율 계산
						$('#menuPrice')
								.on(
										'input',
										function() {
											const sellingPrice = Number($(this)
													.val());
											if (basePrice
													&& sellingPrice > 0
													&& sellingPrice <= basePrice) {
												let discount = ((1 - (sellingPrice / basePrice)) * 100)
														.toFixed(1);
												$('#discountRate')
														.text(
																`할인율은 \${discount}%입니다.`);
											} else if (sellingPrice > basePrice) {
												$('#discountRate').text(
														'판매가는 정가보다 클 수 없습니다.');
											} else {
												$('#discountRate').text(
														'할인율은 %입니다.');
											}
											updateMinPrice();
										});

						// 최소 펀딩 금액 계산
						$('#minSales').on('input', updateMinPrice);

						function updateMinPrice() {
							const price = Number($('#menuPrice').val());
							const quantity = Number($('#minSales').val());
							const minAmount = price > 0 && quantity > 0 ? price
									* quantity : 0;
							$('#amount').text(minAmount.toLocaleString());
						}

						// 정가보다 높은 경우 차단
						$('form').on('submit', function(e) {
							const sellingPrice = Number($('#menuPrice').val());
							if (basePrice && sellingPrice > basePrice) {
								e.preventDefault();
								$('#resultModal, #modalBackdrop').fadeIn();
							}
						});

						$('#closeModalBtn').on('click', function() {
							$('#resultModal, #modalBackdrop').fadeOut();
							$('#menuPrice').focus();
						});

						// 수정 버튼 클릭 시 redirect 포함
						$('#btn-edit')
								.on(
										'click',
										function() {
											const productId = $('#menuSelect')
													.val();
											if (productId) {
												const redirectUrl = encodeURIComponent(window.location.pathname
														+ '?type=limited&selectedProductId='
														+ productId);
												const base = '${pageContext.request.contextPath}';
												window.location.href = base
														+ '/seller/product/edit/'
														+ productId
														+ '?redirect='
														+ redirectUrl;
											} else {
												alert('수정할 메뉴를 선택해주세요.');
											}
										});
					});
</script>

<!-- 단계 표시 -->
<div class="step-progress">
	<div class="step active">
		<div class="circle">1</div>
		<div class="label">상품 정보</div>
	</div>
	<div class="line"></div>
	<div class="step">
		<div class="circle">2</div>
		<div class="label">기간 및 이미지</div>
	</div>
	<div class="line"></div>
	<div class="step">
		<div class="circle">3</div>
		<div class="label">상세 내용</div>
	</div>
</div>

<h3>상품 정보를 입력해주세요.</h3>

<form
	action="${pageContext.request.contextPath}/seller/fundings/create-step3"
	method="post">
	<div class="menuName">
		<div class="menu-label">펀딩할 메뉴를 선택해주세요.</div>
		<div class="menu-select">
			<select id="menuSelect" name="productId" required>
				<option value="" disabled selected>메뉴를 선택해주세요.</option>
			</select>
			<button type="button" class="btn-edit" id="btn-edit">정보 수정</button>
			<button type="button" class="btn-add"

			onclick="location.href='${cpath}/seller/product/new?storeId=${storeDTO.storeId}&redirectUrl=${cpath}/seller/fundings/create-step2?type=limited'">
				메뉴 추가</button>

		</div>
	</div>

	<div class="menuPrice">
		<div class="menu-label">해당 메뉴를 얼마에 판매할지 판매가를 입력해주세요.</div>
		<input type="number" id="menuPrice" name="salePrice" placeholder="판매가"
			required class="form-input" /> <span class="unit-text">&nbsp원</span><br>
		<span id="discountRate">할인율은 %입니다.</span>
	</div>

	<!-- 최소 판매 개수 -->
	<div class="form-group">
		<div class="menu-label">원하시는 최소 판매 개수를 입력해주세요. (펀딩 성공 기준)</div>
		<div class="description">예: 30개를 목표로 하면, 30개가 팔려야 펀딩이 성공합니다.</div>
		<input type="number" id="minSales" name="targetQty"
			placeholder="최소 판매 개수 입력" required class="form-input" /> <span
			class="unit-text">&nbsp개</span><br> <span id="minPrice">펀딩
			성공을 위한 최소 금액은 <span id="amount"></span>원입니다.
		</span>
	</div>

	<!-- 판매 가능한 최대 개수 -->
	<div class="form-group">
		<div class="menu-label">펀딩 이벤트로 판매 가능한 최대 개수를 입력해 주세요.</div>
		<div class="description">예: 50개가 가능하면, 50개 판매시 사용자가 펀딩 참여 불가능</div>
		<input type="number" id="maxSales" name="maxQty"
			placeholder="최대 판매 개수 입력" required class="form-input" /> <span
			class="unit-text">&nbsp개</span>
	</div>

	<!-- 1인당 구매 제한 -->
	<div class="form-group">
		<div class="menu-label">한 사람이 최대 몇 개까지 살 수 있는지 정해주세요.</div>
		<div class="description">예: 1명당 2개까지 구매 가능</div>
		<input type="number" id="maxPerUser" name="perQty"
			placeholder="인당 구매 가능 개수 입력" required class="form-input" /> <span
			class="unit-text">&nbsp개</span>
	</div>

	<div class="btn-container">
		<button class="btn" type="button"
			onclick="location.href='${pageContext.request.contextPath}/seller/fundings/create-step1'">이전</button>
		<button class="btn" type="submit">다음</button>
	</div>
</form>

<!-- 모달 -->
<div id="resultModal">
	<p id="modalMsg">판매가는 정가보다 높을 수 없습니다.</p>
	<button id="closeModalBtn">확인</button>
</div>
<div id="modalBackdrop"></div>
