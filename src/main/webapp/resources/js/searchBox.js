function sendSearchData() {
  const searchText = document.getElementById("searchText").value.trim();

  if (searchText !== "") {
    const encodedSearch = encodeURIComponent(searchText);

    if (typeof loadFundings === 'function') {
      window.currentPage = 1;

      const filters = document.querySelectorAll('.funding-filter');
      filters.forEach(f => f.classList.remove('selected'));
      const defaultFilter = document.querySelector('[data-sort-id="popular"]');
      if (defaultFilter) defaultFilter.classList.add('selected');

      const sidoBtn = document.getElementById('sidoButton');
      const sigunguBtn = document.getElementById('sigunguButton');
      if (sidoBtn) {
        sidoBtn.innerText = '시/도 선택';
        sidoBtn.classList.remove('selected');
      }
      if (sigunguBtn) {
        sigunguBtn.innerText = '시/군/구 선택';
        sigunguBtn.classList.remove('selected');
      }

      document.querySelectorAll(".category-box").forEach(b => b.classList.remove("selected"));
      const totalBox = document.querySelector('.category-box[data-category-id="0"]');
      if (totalBox) totalBox.classList.add("selected");

      loadFundings({
        keyword: encodedSearch,
        sort: 'popular',
        categoryId: 0, 
        sido: '',
        sigungu: ''
      });

    } else {
      window.location.href = `${cpath}/fundings/search/json?search=${encodedSearch}`;
    }
  }
}


document.getElementById("searchText").addEventListener("keydown", function (e) {
  if (e.key === "Enter") {
    sendSearchData();
  }
});


document.getElementById('searchButton').addEventListener('click', function () {
	  const keyword = document.getElementById('searchText').value.trim(); // 수정
	  currentPage = 1;
	  isFullList = false;
	  loadFundings({ keyword: keyword });
	});

