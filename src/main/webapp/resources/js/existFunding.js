document.addEventListener("DOMContentLoaded", function () {
	  const menuSelect = document.getElementById("menuSelect");

	  menuSelect.addEventListener("focus", function () {
	    const storeId = 3; // 상점ID (필요시 동적으로 변경)
	    console.log("storeid", storeId);

	    fetch(`/seller/product/list?storeId=\${storeId}`)
	      .then(response => {
	        if (!response.ok) {
	          throw new Error("네트워크 오류");
	        }
	        return response.json();
	      })
	      .then(productList => {
	        menuSelect.innerHTML = '<option value="" disabled selected>메뉴를 선택해주세요.</option>';

	        productList.forEach(product => {
	          const option = document.createElement("option");
	          option.value = product.productId;
	          option.textContent = product.productName;
	          menuSelect.appendChild(option);
	        });
	      })
	      .catch(error => {
	        alert("상품 목록을 불러오지 못했습니다.");
	        console.error(error);
	      });
	  });
	});
