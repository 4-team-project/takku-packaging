var currentPage = 1;
var lastParams = {};
var isFullList = false;

const categoryMap = {
0: '전체',
1: '한식',
2: '분식',
3: '중식',
4: '일식',
5: '양식',
6: '아시안',
7: '패스트푸드',
8: '카페&디저트',
9: '도시락'
};


function hideInitialContent() {
  var initialContent = document.getElementById('initialContent');
  var moreButton = document.getElementById('moreButton');
  var filteredWrapper = document.getElementById('filteredFundingListBox');
  if (initialContent) initialContent.style.display = 'none';
  if (moreButton) moreButton.style.display = 'none';
  if (filteredWrapper) filteredWrapper.style.display = 'flex';
}

function showInitialContent() {
  var initialContent = document.getElementById('initialContent');
  var moreButton = document.getElementById('moreButton');
  var filteredWrapper = document.getElementById('filteredFundingListBox');
  if (initialContent) initialContent.style.display = 'flex';
  if (moreButton) moreButton.style.display = 'flex';
  if (filteredWrapper) filteredWrapper.style.display = 'none';
}

function renderFundingList(fundingList, append) {
	  if (typeof append === 'undefined') append = false;

	  var filteredWrapper = document.getElementById('filteredFundingListBox');
	  if (!append) filteredWrapper.innerHTML = '';

	  var currentSort = lastParams.sort || 'popular'; // 현재 선택된 정렬 기준

	  var allFundingsHTML = '';
	  if (!append) {
	    allFundingsHTML +=
	      '<div class="funding-filter-box" id="sortButtons">' +
	      '<div class="funding-filter ' + (currentSort === 'popular' ? 'selected' : '') + '" data-sort-id="popular"><div class="funding-filter-text">인기순</div></div>' +
	      '<div class="funding-filter ' + (currentSort === 'latest' ? 'selected' : '') + '" data-sort-id="latest"><div class="funding-filter-text">최신순</div></div>' +
	      '<div class="funding-filter ' + (currentSort === 'closing' ? 'selected' : '') + '" data-sort-id="closing"><div class="funding-filter-text">마감 임박 순</div></div>' +
	      '</div>' +
	      '<div class="funding-list-wrapper"><div class="filteredFundingList">';
	  }

  for (var i = 0; i < fundingList.length; i++) {
    var funding = fundingList[i];
    var avgRating = funding.avgRating ? funding.avgRating.toFixed(1) : '0.0';
    var reviewCnt = typeof funding.reviewCnt !== 'undefined' ? funding.reviewCnt : 0;
    var percent = funding.targetQty > 0 ? Math.round((funding.currentQty * 100) / funding.targetQty) : 0;
    var discount = funding.price > 0 ? Math.round(((funding.price - funding.salePrice) * 100) / funding.price) : 0;
    var imageUrl = (funding.images && funding.images.length > 0 && funding.images[0].imageUrl) ? cpath + funding.images[0].imageUrl : '';
    var imageHtml = imageUrl ? '<img class="funding-image" src="' + imageUrl + '" alt="펀딩 이미지" />' : '<div class="funding-image"></div>';
    var daysLeft = funding.daysLeft;

    allFundingsHTML +=
      '<div class="funding-box" onclick="location.href=\'' + cpath + '/fundings/' + funding.fundingId + '\'">' +
      imageHtml +
      '<div class="funding-contents">' +
      '<div class="funding-place">' + funding.storeName + '</div>' +
      '<div class="funding-title">' + funding.fundingName + '</div>' +
      '<div class="rating-box">' +
      '<img class="rating-img" src="' + cpath + '/resources/images/icons/rating.svg" alt="rating" />' +
      '<div class="rating-text">' + avgRating + '</div>' +
      '<div class="review-text">(' + reviewCnt + ')</div>' +
      '</div>' +
      '<div class="percent-box">' +
      '<div class="percent-text">' + discount + '%</div>' +
      '<div class="regular-price-text">' + funding.price.toLocaleString() + '</div>' +
      '</div>' +
      '<div class="price-text">' + funding.salePrice.toLocaleString() + '원</div>' +
      '<div class="funding-progress-box">' +
      '<div class="funding-progress-text-box"><div class="funding-progress-text">' + percent + '%</div></div>' +
      '<div class="funding-date-box">' +
      '<div class="funding-date">' + daysLeft + '일</div>' +
      '<div class="funding-date-text">남음</div>' +
      '</div>' +
      '</div>' +
      '<div class="funding-bar"><div class="funding-bar-inner" style="width: ' + percent + '%;"></div></div>' +
      '</div></div>';
  }

  allFundingsHTML += '</div></div>';
  filteredWrapper.innerHTML += allFundingsHTML;
  bindSortButtons();
  
  var moreBtn = document.getElementById('moreButton');
  if (moreBtn) {
    moreBtn.style.display = (!isFullList && fundingList.length >= 8) ? 'flex' : 'none';
  }
}

function bindSortButtons() {
  var filters = document.querySelectorAll('.funding-filter');
  for (var i = 0; i < filters.length; i++) {
    filters[i].addEventListener('click', function (event) {
      event.preventDefault();
      for (var j = 0; j < filters.length; j++) {
        filters[j].classList.remove('selected');
      }
      this.classList.add('selected');

      currentPage = 1;
      var sort = this.getAttribute('data-sort-id');
      loadFundings({ sort: sort });
    });
  }
}

function loadFundings(params) {
  if (!params) params = {};

  if (!isFullList && (params.categoryId || params.keyword || params.sido || params.sigungu)) {
	    isFullList = true;
	  }
  
  if (Object.keys(params).length > 0 || currentPage > 1) {
    hideInitialContent();
  } else {
    showInitialContent();
  }
  
  if (params.page) {
	  currentPage = params.page;
	}

  for (var key in params) {
    lastParams[key] = params[key];
  }

  if (!lastParams.sido || lastParams.sido === '시/도 선택') delete lastParams.sido;
  if (!lastParams.sigungu || lastParams.sigungu === '시/군/구 선택') delete lastParams.sigungu;

  var pageSize = isFullList ? 12 : 8;
  var query = '';
  for (var key2 in lastParams) {
    query += encodeURIComponent(key2) + '=' + encodeURIComponent(lastParams[key2]) + '&';
  }
  query += 'page=' + currentPage + '&size=' + pageSize;

  fetch(cpath + '/fundings/search/json?' + query)
  .then(function (res) { return res.json(); })
  .then(function (data) {
	    
    const sido = lastParams.sido || '';
    const sigungu = lastParams.sigungu || '';
    const keyword = lastParams.keyword ? decodeURIComponent(lastParams.keyword) : '';
    updateRecommendTitle(sido, sigungu, keyword);

    renderFundingList(data.fundinglist, false);
    renderPagination(data.totalPages, currentPage);
  })
  .catch(function (err) {
    console.error('펀딩 로딩 실패:', err);
  });

}

document.addEventListener('DOMContentLoaded', function () {
  bindSortButtons();

  var findBtn = document.getElementById('findBtn');
  if (findBtn) {
	  findBtn.addEventListener('click', function () {
	    if (findBtn.classList.contains('disabled')) return;  

	    const sido = document.getElementById('sidoButton').textContent.trim();
	    const sigungu = document.getElementById('sigunguButton').textContent.trim();
	    currentPage = 1;
	    isFullList = true;
	    updateRecommendTitle(sido, sigungu);
	    loadFundings({ sido: sido, sigungu: sigungu });
	  });
	}

  var moreBtn = document.getElementById('moreButton');
  if (moreBtn) {

    moreBtn.addEventListener('click', function () {
      isFullList = true;
      moreBtn.style.display = 'none';
      var selectedSortEl = document.querySelector('.funding-filter.selected');
      var selectedSort = selectedSortEl ? selectedSortEl.getAttribute('data-sort-id') : 'popular';
      loadFundings({ sort: selectedSort });
    });
  }

});

//페이지네이션 처리 함수
function renderPagination(totalPages, currentPage) {
	  const paginationEl = document.querySelector('.pagination');
	  if (!paginationEl) return;

	  if (!isFullList || totalPages <= 1) {
	    paginationEl.innerHTML = '';
	    return;
	  }

	  let html = ''; 

	  for (let i = 1; i <= totalPages; i++) {
	    if (i === currentPage) {
	      html += `<button class="page-link active" disabled>${i}</button>`;
	    } else {
	      html += `<button class="page-link" data-page="${i}">${i}</button>`;
	    }
	  }

	  paginationEl.innerHTML = html;

	  paginationEl.querySelectorAll('.page-link[data-page]').forEach(btn => {
	    btn.addEventListener('click', function () {
	      currentPage = parseInt(this.dataset.page);
	      loadFundings({ page: currentPage });
	    });
	  });
	}



function updateRecommendTitle(sido, sigungu, keyword) {
	  const nickname = '${sessionScope.loginUser.nickname}'; 
	  const titleEl = document.getElementById('recommendTitle');
	  if (!titleEl) return;

	  let regionText = '';
	  if (sido === '전체' && sigungu === '전체') {
	    regionText = '전체';
	  } else if (sido && sigungu && sigungu !== '시/군/구 선택') {
	    regionText = `${sido} ${sigungu}`;
	  } else if (sido && sido !== '시/도 선택') {
	    regionText = sido;
	  }

	  const categoryId = lastParams.categoryId != null ? Number(lastParams.categoryId) : 0;
	  const categoryName = categoryMap[categoryId] || '';

	  if (keyword && keyword.trim() !== '') {
	    if (regionText) {
	      if (categoryId && categoryId !== 0)
	        titleEl.innerHTML = `<span>${regionText}</span> 에서 현재 진행 중인 <span>'${keyword}'</span> <span>${categoryName}</span> 펀딩`;
	      else
	        titleEl.innerHTML = `<span>${regionText}</span> 에서 현재 진행 중인 <span>'${keyword}'</span> 전체 펀딩`;
	    } else {
	      if (categoryId && categoryId !== 0)
	        titleEl.innerHTML = `<span>'${keyword}'</span> 에 대한 현재 진행 중인 <span>${categoryName}</span> 펀딩`;
	      else
	        titleEl.innerHTML = `<span>'${keyword}'</span> 에 대한 현재 진행 중인 <span>전체</span> 펀딩`;
	    }
	  }

	  else {
	    if (regionText) {
	      if (categoryId && categoryId !== 0)
	        titleEl.innerHTML = `<span>${regionText}</span> 에서 현재 진행 중인 <span>${categoryName}</span> 펀딩`;
	      else
	        titleEl.innerHTML = `<span>${regionText}</span> 에서 현재 진행 중인 <span>전체</span> 펀딩`;
	    } else {
	      if (categoryId && categoryId !== 0)
	        titleEl.innerHTML = `<span>딱쿠</span>에서 현재 진행 중인 <span>${categoryName}</span> 펀딩`;
	      else
	        titleEl.innerHTML = `<span>딱쿠</span>에서 현재 진행 중인 <span>전체</span> 펀딩`;
	    }
	  }
	}


window.loadFundings = loadFundings;
window.currentPage = currentPage;
