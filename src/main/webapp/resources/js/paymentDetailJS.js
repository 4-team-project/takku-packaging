// 모달 보여주는 함수
	let currentTabStatus = 'allbuylist';
	
		// 날짜 포맷 변환 함수 (timestamp → yyyy-MM-dd HH:mm)
	  	function formatDate(timestamp) {
	    const date = new Date(parseInt(timestamp));
	    return date.toLocaleDateString('ko-KR') + ' ' + date.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
	  }
		
	 // 모달에 데이터 세팅하고 보여주는 함수
	  function showModal(data) {
		window.currentOrderId = data.orderId;
		  
	    document.getElementById('modal-fundingName').textContent = data.fundingName;
	    document.getElementById('modal-qty').textContent = data.qty;
	    document.getElementById('modal-purchasedAt').textContent = formatDate(data.purchasedAt);
	    document.getElementById('modal-paymentMethod').textContent = data.paymentMethod;
	    document.getElementById('modal-status').textContent = data.status;
	    document.getElementById('modal-success').textContent = data.success || '';

	    const cancelBtn = document.querySelector('.modal-btn.cancel');

	    // 결제취소 상태가 아니면 버튼 보이기
	    if (data.status === '환불') {
	      cancelBtn.style.display = 'none';
	    } else {
	      cancelBtn.style.display = 'inline-block';
	    }	 
	    document.getElementById('modal').style.display = 'block';
	  }

	  // 결제 상세 모달 버튼 클릭 이벤트 바인딩
	  function bindModalEvents() {
		  // 각 결제 상세 버튼에 클릭 이벤트 연결
	    document.querySelectorAll('.payment-detail-btn').forEach(btn => {
	      btn.onclick = () => {
	        const orderId = btn.getAttribute('data-orderid');
	        fetch(`${cpath}/order/detail?orderId=${orderId}`)
	          .then(response => response.json())
	          .then(data => {
	            showModal(data);
	          });
	      };
	    });
	    
	    // 모달 닫기 (X 버튼, 확인 버튼, 취소하기 버튼)
	    document.querySelectorAll('.close-btn').forEach(btn => {
	      btn.onclick = () => {
	        document.getElementById('modal').style.display = 'none';
	      };
	    });
	    
	    document.querySelectorAll('.modal-btn.confirm').forEach(btn => {
	      btn.onclick = () => {
	        document.getElementById('modal').style.display = 'none';
	      };
	    });
	    
	    document.querySelectorAll('.modal-btn.cancel').forEach(btn => {
	    	  btn.onclick = function(event) {
	    	    event.preventDefault();
	    	    event.stopPropagation();
	    	    
	    	    const orderId = window.currentOrderId;

	    	    if (!orderId) {
	    	      alert('주문 정보를 찾을 수 없습니다.');
	    	      return;
	    	    }

	    	    fetch(`${cpath}/order/cancel`, {
	    	      method: 'POST',
	    	      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	    	      body: `orderId=${orderId}`
	    	    })
	    	    
	    	    .then(response => response.text())
		    	.then(result => {
		      	if (parseInt(result) > 0) {
		        	alert("결제가 완료되었습니다. 결제취소 탭에서 확인해주세요");
		        	document.getElementById('modal').style.display = 'none';
		        	
		            // 현재 화면에서 상태만 '환불'로 업데이트
		            const statusEl = document.querySelector(`.payment-detail-btn[data-orderid="${orderId}"]`)
		                                  .closest('.payment-item')
		                                  .querySelector('.payment-status');
		            if (statusEl) {
		              statusEl.textContent = '환불';
		            }

		            // 모달 내 버튼도 숨기기
		            const cancelBtn = document.querySelector('.modal-btn.cancel');
		            if (cancelBtn) cancelBtn.style.display = 'none';
		 	    	 } else {
		       	   alert("환불되었습니다.");
		       	 location.reload(); //새로고침
		      	  }
		      })
	      };
	    }); 
	  }