function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            const road = data.roadAddress;
            const jibun = data.jibunAddress;

            document.getElementById('roadAddress').value = road; //도로명주소
            document.getElementById('jibunAddress').value = jibun; //지번주소 
            document.getElementById('postcode').value = data.zonecode; //우편번호
            const detailInput = document.getElementById('detailAddr');
            if (detailInput) {
              detailInput.focus();
            }

            const baseAddr = road || jibun;
            if (baseAddr) {
                const addrParts = baseAddr.split(' ');
                document.getElementById('sido').value = addrParts[0] || ''; //시도
                document.getElementById('sigungu').value = addrParts[1] || ''; //시군구
                document.getElementById('bname').value = addrParts[2] || ''; //동
            }        
        }
    }).open();
}

//주소 지우기
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('clearAddressBtn').addEventListener('click', function() {
        document.getElementById('postcode').value = '';
        document.getElementById('roadAddress').value = '';
        document.getElementById('jibunAddress').value = '';
        document.getElementById('detailAddr').value = '';
        document.getElementById('sido').value = '';
        document.getElementById('sigungu').value = '';
    });
});
