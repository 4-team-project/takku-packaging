let allFundings = [];
const fundingListContainer = document.getElementById('fundingListContainer');
const fundingTabs = document.querySelector('.funding-tabs');
const fundingCountSummary = document.getElementById('fundingCountSummary');

$(document).ready(function () {
  const storeIdElement = document.getElementById('currentStoreId');
  const currentStoreId = storeIdElement ? storeIdElement.value : null;

  if (!currentStoreId || isNaN(Number(currentStoreId))) {
    alert("현재 상점 ID가 유효하지 않습니다.");
    if (fundingListContainer) fundingListContainer.innerHTML = '<p>상점 ID가 없어 펀딩을 불러올 수 없습니다.</p>';
    updateFundingCounts();
    return;
  }

  // 현재 상점 기준 초기 펀딩 로드
  loadAndDisplayFundings(currentStoreId);

  // --- 탭 필터 클릭 이벤트 ---
  $('.funding-tabs button').on('click', function () {
    $('.funding-tabs button').removeClass('active');
    $(this).addClass('active');

    const selectedStatus = $(this).data('status');
    displayFundings(selectedStatus);
  });

  // --- 펀딩 불러오기 ---
  function loadAndDisplayFundings(storeId, initialStatus = 'all') {
    $.ajax({
      url: `${cpath}/seller/store/fundings/byStore?storeId=${storeId}`,
      method: 'GET',
      dataType: 'json',
      success: function (fundings) {
        allFundings = fundings;
        updateFundingCounts();
        displayFundings(initialStatus);
        setActiveTab(initialStatus);
      },
error: function (xhr, status, error) {
  let msg = '펀딩 정보를 불러오지 못했습니다.';
  if (xhr && xhr.responseText) {
    msg = xhr.responseText;
  } else if (error) {
    msg = error;
  } else if (status) {
    msg = status;
  }

  fundingListContainer.innerHTML = `<p>${msg}</p>`;
  allFundings = [];
  updateFundingCounts();
}
    });
  }

  // --- 펀딩 카드 출력 ---
  function displayFundings(statusToFilter) {
    const filtered = (statusToFilter === 'all') ? allFundings
      : (statusToFilter === '종료') ? allFundings.filter(f => f.status === '성공' || f.status === '실패')
      : allFundings.filter(f => f.status === statusToFilter);

    fundingListContainer.innerHTML = '';
    if (filtered.length === 0) {
      fundingListContainer.innerHTML = `<p>이 상태에 해당하는 펀딩이 없습니다.</p>`;
      $('#currentFundingCount').text(0);
      $('#currentFilterStatus').text(getDisplayStatusText(statusToFilter));
      updateStatusClasses(statusToFilter);
      return;
    }

    filtered.forEach((f, i) => {
      const rate = Math.floor((Number(f.currentQty || 0) * 100) / Number(f.targetQty || 1));
      const card = document.createElement('div');
      card.className = 'funding-card';
      card.dataset.fundingId = f.fundingId;
      card.innerHTML = `
        <div class="funding-info">
          <h3 class="funding-title">${i + 1}. ${f.fundingName || '이름 없음'}</h3>
          <div class="funding-date">${formatDate(f.startDate)} ~ ${formatDate(f.endDate)}</div>
          <div class="progress-bar-wrapper">
            <div class="progress-bar-container">
              <div class="progress-bar" style="width: ${rate}%"></div>
            </div>
            <div class="progress-percentage">${rate}%</div>
          </div>
        </div>
        <span class="funding-status ${getStatusClass(f.status)}">
          ${(f.status === '성공' || f.status === '실패') ? '종료' : f.status}
        </span>
      `;
      card.addEventListener('click', () => {
        window.location.href = `${cpath}/seller/store/funding/stats?fundingId=${f.fundingId}`;
      });
      fundingListContainer.appendChild(card);
    });

    $('#currentFundingCount').text(filtered.length);
    $('#currentFilterStatus').text(getDisplayStatusText(statusToFilter));
    updateStatusClasses(statusToFilter);
  }

  // --- 헬퍼 함수들 ---
  function formatDate(dateStr) {
    return dateStr ? new Date(dateStr).toLocaleDateString('ko-KR') : '';
  }

  function getStatusClass(status) {
    if (status === '진행중') return 'status-in-progress';
    if (status === '준비중') return 'status-scheduled';
    if (status === '성공' || status === '실패') return 'status-ended';
    return 'status-ended';
  }

  function getDisplayStatusText(status) {
    if (status === 'all') return '전체';
    if (status === '진행중') return '진행 중인';
    if (status === '준비중') return '준비 중인';
    if (status === '종료') return '종료된';
    return status;
  }

  function updateStatusClasses(status) {
    const classMap = {
      'all': 'status-all',
      '진행중': 'status-in-progress',
      '준비중': 'status-scheduled',
      '종료': 'status-ended'
    };
    $('#currentFilterStatus, #currentFundingCount')
      .removeClass('status-in-progress status-scheduled status-ended status-all')
      .addClass(classMap[status] || '');
  }

  function setActiveTab(activeStatus) {
    if (!fundingTabs) return;
    fundingTabs.querySelectorAll('button').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.status === activeStatus);
    });
  }

  function updateFundingCounts() {
    const inProgress = allFundings.filter(f => f.status === '진행중').length;
    const scheduled = allFundings.filter(f => f.status === '준비중').length;
    const ended = allFundings.filter(f => f.status === '성공' || f.status === '실패').length;

    fundingCountSummary.innerHTML = `
      총 펀딩 개수: <span>${allFundings.length}</span>개 |
      진행중: <span>${inProgress}</span>개 |
      준비중: <span>${scheduled}</span>개 |
      종료: <span>${ended}</span>개
    `;
  }
});