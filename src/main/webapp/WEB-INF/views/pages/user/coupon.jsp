<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<meta charset="UTF-8">
<link rel="icon" href="data:;base64,iVBORw0KGgo=">
<link rel="stylesheet" href="${cpath}/resources/css/my_coupon_page.css" />
<link rel="stylesheet" href="${cpath}/resources/css/review-form.css" />
<link rel="stylesheet" href="${cpath}/resources/css/coupon_detail.css" />
<script>const cpath = "${pageContext.request.contextPath}";</script>

<div class="coupon-container">
	<div class="sidebar">
		<div class="menu-title active" data-tab="unused">사용 가능한 쿠폰</div>
		<div class="menu-sub" data-tab="used">사용한 쿠폰</div>
	</div>

	<div class="main-content">
		<div class="tab-search-bar">
			<div id="tabs" class="tabs"></div>
			<div class="search-wrapper">
				<%@ include file="/WEB-INF/views/common/searchBox.jsp"%>
			</div>
		</div>

		<!-- 사용 가능한 쿠폰 -->
		<div class="coupon-list unused-coupons">
			<c:forEach var="coupon" items="${coupons}">
				<c:if test="${coupon.useStatus == '미사용'}">
					<c:set var="funding" value="${fundingMap[coupon.fundingId]}" />
					<c:set var="product" value="${productMap[funding.productId]}" />
					<c:set var="store" value="${storeMap[funding.storeId]}" />
					<c:set var="price" value="${product.price}" />
					<c:set var="sale" value="${funding.salePrice}" />
					<c:set var="discountRate" value="${(price - sale) * 100 / price}" />
					<c:set var="discountRateInt"
						value="${discountRate - (discountRate % 1)}" />

					<div class="coupon-card" data-status="${coupon.useStatus}"
						data-expired-at="<fmt:formatDate value='${coupon.expiredAt}' pattern='yyyy-MM-dd'/>"
						data-reviewed="${coupon.reviewed}">
						<div class="coupon-left">
							<div class="sale">
								<fmt:formatNumber value="${discountRateInt}" type="number"
									maxFractionDigits="0" />
								%
							</div>
						</div>

						<div class="coupon-middle">
							<div class="store">${store.sido}${store.sigungu}${store.dong}</div>
							<div class="title">
								<strong class="coupon-title">${store.storeName}</strong>
							</div>
							<div class="name">
								<strong>${funding.fundingName}</strong>
							</div>
							<div class="desc">
								<c:choose>
									<c:when test="${fn:length(funding.fundingDesc) > 40}">
                    ${fn:substring(funding.fundingDesc, 0, 40)}...				
						<span class="more"
											 onclick="location.href='${cpath}/fundings/${coupon.fundingId}'"
											style="color: #FF9670; cursor: pointer;">더보기</span>	
									</c:when>
									<c:otherwise>
                    ${funding.fundingDesc}
                  </c:otherwise>
								</c:choose>
							</div>
						</div>

						<div class="coupon-right">
							<input type="hidden" name="couponId" value="${coupon.couponId}" />
							<button class="btn-show-qr" data-coupon-id="${coupon.couponId}">
								<span class="btn-word">QR 보기</span>
							</button>
							<div class="coupon-date">
								~<fmt:formatDate value="${coupon.expiredAt}" pattern="yyyy.MM.dd" />
							</div>
						</div>
					</div>
				</c:if>
			</c:forEach>
		</div>

		<!-- 사용한 쿠폰 -->
		<div class="coupon-list used-coupons" style="display: none;">
			<c:forEach var="coupon" items="${coupons}">
				<c:if test="${coupon.useStatus == '사용'}">
					<c:set var="funding" value="${fundingMap[coupon.fundingId]}" />
					<c:set var="product" value="${productMap[funding.productId]}" />
					<c:set var="store" value="${storeMap[funding.storeId]}" />
					<div class="coupon-card" data-status="${coupon.useStatus}"
						data-reviewed="${coupon.reviewed}">
						<div class="coupon-left">
							<div class="usedAt">
							<div class="use">사용완료</div>
								
								<fmt:formatDate value="${coupon.usedAt}" pattern="yyyy-MM-dd" />
								
							</div>
						</div>

						<div class="coupon-middle">
							<div class="store">${store.sido}${store.sigungu}${store.dong}</div>
							<div class="title">
								<strong class="coupon-title">${store.storeName}</strong>
							</div>
							<div class="name">
								<strong>${funding.fundingName}</strong>
							</div>
							<c:choose>
								<c:when test="${fn:length(funding.fundingDesc) > 40}">
                    ${fn:substring(funding.fundingDesc, 0, 40)}...
                   <span class="more"
											 onclick="location.href='${cpath}/fundings/${coupon.fundingId}'"
											style="color: #FF9670; cursor: pointer;">더보기</span>
						
								</c:when>
								<c:otherwise>
                    ${funding.fundingDesc}
                  </c:otherwise>
							</c:choose>
						</div>

						<div class="coupon-right">
							<c:choose>
								<c:when test="${coupon.reviewed == 1}">
									<button class="use-btn used-btn">
										<span class="btn-word">사용완료</span>
									</button>
								</c:when>
								<c:otherwise>
									<button class="use-btn used-btn">
										<span class="btn-word">사용완료</span>
									</button>
									<button type="button" class="review-btn" data-coupon-id="${coupon.couponId}"
										onclick="openReviewModal('${cpath}/review/write/${coupon.couponId}')">
										<span class="btn-word">리뷰쓰기</span>
									</button>
								</c:otherwise>
							</c:choose>
						</div>
					</div>
				</c:if>
			</c:forEach>
		</div>

		<div class="pagination"></div>
	</div>
</div>

<!-- 모달 영역 -->
<div id="modalBackdrop" class="modal-backdrop" style="display: none;"></div>
<div id="couponModal" class="modal-container" style="display: none;">
	<div id="modalContent" class="modal-content"></div>
</div>

<script>

//------------------------ [사이드바 탭 기능] ------------------------
$(document).ready(function () {
  $(".sidebar div").on("click", function () {
    $(".sidebar div").removeClass("active");
    $(this).addClass("active");

    const tab = $(this).data("tab");

    if (tab === "unused") {
      $(".unused-coupons").show();
      $(".used-coupons").hide();
    } else if (tab === "used") {
      $(".unused-coupons").hide();
      $(".used-coupons").show();
    }
  });

  $(document).on("click", ".btn-show-qr", function () {
    const couponId = $(this).data("coupon-id");

    $.ajax({
      url: `${cpath}/user/coupon/qr`,
      data: { couponId },
      type: "GET",
      success: function (html) {
        $("#modalContent").html(html);
        $("#modalBackdrop, #couponModal").fadeIn();
      },
      error: function () {
        alert("QR 쿠폰 정보를 불러오지 못했습니다.");
      }
    });
  });

  $(document).on("click", "#modalBackdrop", function () {
    $("#modalBackdrop, #couponModal").fadeOut();
  });
});

//쿠폰 설명 더보기 클릭시 펀딩 상세보기
function exitDetail() {
	  const modal = document.getElementById('couponModal');
	  const modalBack = document.getElementById('modalBackdrop');
	  modal.style.display = 'none';
	  modalBack.style.display = 'none';
	}
	
	
//------------------------ [리뷰 작성 모달 관련] ------------------------
	
function openReviewModal(url) {
    fetch(url)
        .then(res => {
            if (!res.ok) throw new Error('리뷰 폼 로드 실패');
            return res.text();
        })
        .then(html => {
            const container = document.getElementById('reviewModalContainer');
            container.innerHTML = html;
            container.style.display = 'flex';
            
            const reviewSuccessBtn = container.querySelector('#reviewSuccessBtn');
            if (reviewSuccessBtn) {
                const fundingId = reviewSuccessBtn.dataset.fundingId;
                reviewSuccessBtn.addEventListener('click', function () {
                    const fundingId = this.dataset.fundingId;
                    goToReviewPage(fundingId);
                });
            }

            document.body.classList.add('modal-open');

            initializeStarRating();
            setupReviewFormSubmission();
            
        })
        .catch(err => {
            console.error(err);
            alert("리뷰 폼 로딩 실패");
        });
}

function closeModal() {
    const container = document.getElementById('reviewModalContainer');
    container.innerHTML = '';
    container.style.display = 'none';
    document.body.classList.remove('modal-open');
}

function setupReviewFormSubmission() {
    const form = document.getElementById("reviewForm");
    const couponId = document.querySelector('#coupon-id-hidden').value;
    if (!form) return;
    form.addEventListener("submit", async (e) => {
        e.preventDefault();
        const json = {
            userId: parseInt(form.userId.value),
            productId: parseInt(form.productId.value),
            rating: parseInt(form.rating.value),
            content: form.content.value,
            imageUrls: []
        };

        for (const file of imageMap.values()) {
            const formData = new FormData();
            formData.append("file", file);
            const res = await fetch(cpath + "/image/upload", { method: "POST", body: formData });
            if (!res.ok) {
                alert("이미지 업로드 실패");
                return;
            }
            json.imageUrls.push(await res.text());
        }

        const result = await fetch(cpath + '/review/submit?couponId=' + couponId, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(json)
        });

        if (result.ok) {
            document.getElementById('successModal').style.display = 'flex';
            form.reset();
            document.getElementById('preview-container').innerHTML = '';
            imageMap.clear();
        } else {
            alert("리뷰 등록 실패");
        }
    });
}

function initializeStarRating() {
    const stars = document.querySelectorAll('#reviewModalContainer .star-rating span');
    const ratingInput = document.getElementById('rating');
    let selectedValue = 0; // 초기화마다 초기값 설정

    stars.forEach(star => {
        const value = parseInt(star.getAttribute('data-value'), 10);
        star.addEventListener('click', () => {
            selectedValue = value;
            ratingInput.value = selectedValue;
            updateStars(selectedValue);
        });
        star.addEventListener('mouseover', () => updateStars(value));
        star.addEventListener('mouseout', () => updateStars(selectedValue));
    });

    function updateStars(value) {
        stars.forEach(star => {
            const starValue = parseInt(star.getAttribute('data-value'), 10);
            star.classList.toggle('selected', starValue <= value);
        });
    }
}

//------------------------ [리뷰 작성시 이미지 업로드 & 미리보기] ------------------------
const imageLimit = 5;
const imageMap = new Map();

function handleFiles(files) {
    const previewContainer = document.getElementById('preview-container');
    if (imageMap.size + files.length > imageLimit) {
        alert("이미지는 최대 " + imageLimit + "장까지만 가능합니다.");
        return;
    }
    [...files].forEach(file => {
        if (!file.type.startsWith("image/") || file.size > 5 * 1024 * 1024) {
            alert("유효하지 않은 이미지입니다.");
            return;
        }
        const uuid = generateUUID();
        imageMap.set(uuid, file);
        const reader = new FileReader();
        reader.onload = e => {
            const img = document.createElement('img');
            img.src = e.target.result;
            const btn = document.createElement('button');
            btn.textContent = '×';
            btn.onclick = () => removeImage(uuid, btn);
            const wrapper = document.createElement('div');
            wrapper.className = 'preview-image';
            wrapper.appendChild(img);
            wrapper.appendChild(btn);
            previewContainer.appendChild(wrapper);
        };
        reader.readAsDataURL(file);
    });
    document.getElementById('images').value = '';
}

function removeImage(uuid, btn) {
    imageMap.delete(uuid);
    btn.parentElement.remove();
}

function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
        const r = Math.random() * 16 | 0;
        const v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

//------------------------ [기타 기능] ------------------------
function goToCouponDetail(url, couponId) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = url;
    form.innerHTML = `<input type="hidden" name="couponId" value="${couponId}">`;
    document.body.appendChild(form);
    form.submit();
}

function goToReviewPage(fundingId) {
    if (!fundingId) {
        alert("fundingId가 없습니다.");
        return;
    }
    window.location.href = cpath + "/review/product/" + fundingId + "/review";
    closeModal(); // 페이지 이동 후에도 모달 닫기
}

function closeSuccessModal() {
    document.getElementById('successModal').style.display = 'none';
    closeModal();
    location.reload();
}

function exitReview() {
    closeConfirmModal();
    closeModal();
}

function closeConfirmModal() {
    document.getElementById('confirmModal').style.display = 'none';
}

function openConfirmModal() {
    document.getElementById('confirmModal').style.display = 'flex';
}

//------------------------ [검색 기능] ------------------------

let currentTab = "unused"; // 초기값: 사용 가능한 쿠폰

//탭 전환 시 active tab 갱신
$(".sidebar div").on("click", function () {
$(".sidebar div").removeClass("active");
$(this).addClass("active");

currentTab = $(this).data("tab"); // unused 또는 used

if (currentTab === "unused") {
 $(".unused-coupons").show();
 $(".used-coupons").hide();
} else if (currentTab === "used") {
 $(".unused-coupons").hide();
 $(".used-coupons").show();
}

sendSearchData(); // 탭 전환 시 현재 검색어로 다시 필터링
});

function sendSearchData() {
const query = document.getElementById("searchText").value.trim().toLowerCase();
const visibleListClass = currentTab === "unused" ? ".unused-coupons" : ".used-coupons";
const listElement = document.querySelector(visibleListClass);
const cards = listElement.querySelectorAll(".coupon-card");

let matchCount = 0;

cards.forEach(card => {
 const title = card.querySelector(".coupon-title")?.textContent.toLowerCase() || "";
 const name = card.querySelector(".name")?.textContent.toLowerCase() || "";
 const desc = card.querySelector(".desc")?.textContent.toLowerCase() || "";

 const isMatch = title.includes(query) || name.includes(query) || desc.includes(query);

 if (!query) {
   card.style.display = "flex"; // 검색어 없으면 전체 보이기
   matchCount++;
 } else {
   card.style.display = isMatch ? "flex" : "none";
   if (isMatch) matchCount++;
 }
});

const pagination = document.querySelector(".pagination");
if (matchCount === 0) {
 pagination.innerHTML = `<div class="no-result-message">검색 결과가 없습니다.</div>`;
} else {
 pagination.innerHTML = ""; // 초기화
}
}

//검색 버튼 및 Enter 키 이벤트 연결
document.getElementById("searchButton").addEventListener("click", sendSearchData);
document.getElementById("searchText").addEventListener("keydown", function (e) {
if (e.key === "Enter") sendSearchData();
});

</script>
<div id="reviewModalContainer" class="modal-overlay"
	style="display: none;"></div>