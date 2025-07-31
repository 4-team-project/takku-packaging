package com.takku.project.service;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.takku.project.domain.StoreDTO;
import com.takku.project.mapper.StoreMapper;

@Service
public class StoreService implements StoreMapper {

	@Autowired
	SqlSession sqlSession;
	String namespace = "com.takku.project.mapper.StoreMapper.";

	
	@Override
	public int insertStore(StoreDTO store) {
		int result = sqlSession.insert(namespace + "insertStore", store);
		return result;
	}

	@Override
	public StoreDTO selectStoreById(Integer storeId) {
		StoreDTO store = sqlSession.selectOne(namespace + "selectStoreById", storeId);
		return store;
	}

	@Override
	public int updateStore(StoreDTO store) {
		int result = sqlSession.update(namespace + "updateStore", store);
		return result;
	}

	@Override
	public int deleteStore(Integer storeId) {
		int result = sqlSession.delete(namespace + "deleteStore", storeId);
		return result;
	}

	@Override
	public int countByBusinessNumber(String businessNumber) {
		int result = sqlSession.selectOne(namespace + "countByBusinessNumber", businessNumber);
		return result;
	}

	@Override
	public Integer findStoreIdByUserId(int userId) {
		return sqlSession.selectOne(namespace + "selectStoreIdByUserId", userId);
	}

	// seller -> userId별 상점이름 조회
	@Override
	public StoreDTO selectStoreNameByUserId(int userId) {
		return sqlSession.selectOne(namespace + "selectStoreNameByUserId", userId);
	}

	// 사용자 상점 전체 조회
	@Override
	public List<StoreDTO> selectStoreListByUserId(int userId) {
		return sqlSession.selectList(namespace + "selectStoreListByUserId", userId);
	}
	
	@Override
	public List<Map<String, Object>> getAverageRatingByUserId(int userId) {
		return sqlSession.selectList(namespace + "getAverageRatingByUserId", userId);
	}


}
