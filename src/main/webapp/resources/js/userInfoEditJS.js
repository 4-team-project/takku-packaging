//내 정보 수정하기
document.addEventListener('DOMContentLoaded', () => {
	
	// 내 정보 수정하기 버튼 클릭 시 모달 열기
	  	document.querySelector('.editMypage').addEventListener('click', e => {
	    e.preventDefault();
	    document.getElementById('user-info-modal').style.display = 'block';
	    document.getElementById('modalBackdrop').style.display = 'block';
	    
	    //수정저장하고 다시 모달창 들어가면 비밀번호 칸 빈칸으로
	    const passwordInput = document.getElementById('password');
	    const passwordConfirmInput = document.getElementById('passwordConfirm');
	    const conditionDiv = document.querySelector('.condition div');

	    // 조건 문구 초기화
	    passwordInput.value = '';
	    passwordConfirmInput.value = '';
	    
	    conditionDiv.textContent = "영어와 숫자조합으로 6자 이상 입력해주세요.";
	    conditionDiv.style.color = "black";
	  	});
	  	
		
	  // 비밀번호 유효성 검사 이벤트 추가
	  const passwordInput = document.getElementById('password');
	  const conditionDiv = document.querySelector('.condition div');
	
	  passwordInput.addEventListener('input', () => {
	    const pwd = passwordInput.value;

	    fetch(`${cpath}/api/v1/validations/password-format`, {
	      method: 'POST',
	      headers: { 'Content-Type': 'application/json' },
	      body: JSON.stringify({ password: pwd })
	    })
	    .then(res => res.json())
	    .then(data => {
	      if (data.valid) {
	        conditionDiv.textContent = "사용 가능한 비밀번호 형식입니다.";
	        conditionDiv.style.color = "green";
	      } else {
	        conditionDiv.textContent = "영어와 숫자 조합으로 6자 이상이어야 합니다.";
	        conditionDiv.style.color = "red";
	      }
	    })
	  });
		

  	// "수정하기" 버튼 클릭 시 → POST로 서버에 전송
 	document.querySelector('.modal-btn.Uedit').addEventListener('click', () => {
    const form = document.getElementById('user-info-form');

    const nickname = form.nickname.value;
    const password = form.password.value;
    const passwordConfirm = form.passwordConfirm.value;

    if (password && password !== passwordConfirm) {
      alert("비밀번호가 일치하지 않습니다.");
      return;
    }

    fetch(`${cpath}/user/update`, {
      method: 'POST',
      headers: {
    	  'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
    	  nickname,
    	    password,
    	    passwordConfirm
      })
    })
    .then(res => res.text())
   .then(result => {
	    if (parseInt(result) > 0) {
	      alert("수정이 완료되었습니다.");
	      location.reload(); //새로고침
	      document.getElementById('user-info-modal').style.display = 'none';
	      document.getElementById('modalBackdrop').style.display = 'none';
	    } else if (result === '-1') {
	      alert("비밀번호가 일치하지 않습니다.");
	    } else {
	      alert("수정에 실패했습니다.");
	    }
	  })
  });

  // X 버튼 클릭 시 모달 닫기
  document.querySelector('#user-info-modal .close-btn').addEventListener('click', () => {
    document.getElementById('user-info-modal').style.display = 'none';
    document.getElementById('modalBackdrop').style.display = 'none';
  });
	//"확인" 버튼
  document.querySelector('.modal-btn.Ucheck').addEventListener('click', () => {
    document.getElementById('user-info-modal').style.display = 'none';
    document.getElementById('modalBackdrop').style.display = 'none';
  });
});
	