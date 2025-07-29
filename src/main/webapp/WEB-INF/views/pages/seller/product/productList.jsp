<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<link rel="stylesheet"
	href="${cpath}/resources/css/pages/seller/productDetail.css">
<link rel="stylesheet"
	href="${cpath}/resources/css/pages/seller/settlements.css">
<link rel="stylesheet"
	href="${cpath}/resources/css/pages/seller/storeList.css">
<%@ include file="/WEB-INF/views/common/sellerModal.jsp"%>

<div class="main-title-box">
	<%@ include file="/WEB-INF/views/common/sellerButton.jsp"%>
	<div style="margin-left: 20px;" class="main-title" id="typingText">
		${currentStore.storeName}의 상품 목록입니다</div>
</div>

<div class="store-list" id="product-list"></div>

<script>
function loadProductListPage(page) {
  $("#product-list").empty();
  $.ajax({
    url: `${cpath}/seller/product/list/byStoreId`,
    method: 'GET',
    data: { page: page, storeId: ${storeDTO.storeId} },
    success: function(data) {
      const list = data.productList;
      const currentPage = data.currentPage;
      const totalPages = data.totalPages;
      let html = '';

      list.forEach(product => {
    	  const imageUrl = product.thumbnailImageUrl 
    	                   ? `\${cpath}\${product.thumbnailImageUrl}` 
    	                   : `\${cpath}/resources/images/category/default.svg`;

    	  html += `
    	    <div class="store-card">
    	      <div class="store-info-left">
    	        <div class="store-title" style="display:flex; align-items:center;">
    	          \${product.productName}
    	        </div>
    	        <div class="store-info-middle">
    	          <div class="store-info-middle-text">
    	            <div class="store-detail">가격: \${product.price.toLocaleString()}원</div>
    	            <div class="store-detail">설명: \${product.description || '설명 없음'}</div>
    	          </div>
    	          <button class="btn" onclick="location.href='${cpath}/seller/product/edit/\${product.productId}'">수정하기</button>
    	        </div>
    	      </div>
    	      <div class="store-buttons">
    	        <button class="btn-delete" data-product-id="\${product.productId}">삭제하기</button>
    	      </div>
    	    </div>
    	  `;
    	});


      html += `<div class="pagination">`;
      for (let i = 1; i <= totalPages; i++) {
        if (i === currentPage) {
          html += `<button class="page-link active" disabled>\${i}</button>`;
        } else {
          html += `<button class="page-link" data-page="\${i}">\${i}</button>`;
        }
      }
      html += `</div>`;

      $("#product-list").html(html);
    },
    error: function() {
      alert("상품 목록을 불러오는 데 실패했습니다.");
    }
  });
}

// 최초 로딩 시 상품 리스트 1페이지 불러오기
$(document).ready(function() {
  loadProductListPage(1);
});

// 페이지네이션 클릭 시
$(document).on("click", ".page-link", function(e) {
  e.preventDefault();
  const page = $(this).data("page");
  loadProductListPage(page);
});

// 상품 삭제 버튼 클릭 시
$(document).on("click", ".btn-delete", function () {
  const productId = $(this).data("product-id");
  const productName = $(this).closest(".store-card").find(".store-title").text().trim();

  openModal({
    title: "상품 삭제 확인",
    body: `<div class="modal-info">
             <strong>\${productName} 상품을 삭제하시겠습니까?</strong>
             <p class="cancel-guide">삭제하시면 되돌릴 수 없습니다.<br />괜찮으시면 아래 ‘삭제’ 버튼을 눌러주세요.</p>
           </div>`,
    cancelText: "취소",
    confirmText: "삭제",
    onConfirm: function () {
      deleteProduct(productId);
      closeModal(); 
    }
  });
});

// 상품 삭제 함수
function deleteProduct(productId) {
  if (!productId) {
    alert("삭제할 상품 ID가 없습니다.");
    return;
  }
  fetch(`${cpath}/seller/product/delete/\${productId}`, {
    method: "POST"
  })
  .then(res => res.text())
  .then(msg => {
    alert("삭제 결과: " + msg);
    location.reload(); 
  })
  .catch(err => alert("오류 발생: " + err));
}
</script>
