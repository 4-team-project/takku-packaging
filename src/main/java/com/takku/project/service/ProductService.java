package com.takku.project.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.takku.project.domain.ProductDTO;

@Service
public class ProductService {

	@Autowired
	private SqlSession sqlSession;

	private final String namespace = "com.takku.project.mapper.ProductMapper.";

	public int insertProduct(ProductDTO productVO) {
		return sqlSession.insert(namespace + "insertProduct", productVO);
	}

	public List<ProductDTO> selectProductByStoreId(Integer storeId) {
		return sqlSession.selectList(namespace + "selectProductByStoreId", storeId);
	}

	public int updateProduct(ProductDTO productVO) {
		return sqlSession.update(namespace + "updateProduct", productVO);
	}

	public int deleteProduct(Integer productId) {
		return sqlSession.delete(namespace + "deleteProduct", productId);
	}

	public ProductDTO selectByProductId(Integer productId) {
		return sqlSession.selectOne(namespace + "selectByProductId", productId);
	}
	
	//상점ID로 상품 가져오기
	public List<ProductDTO> selectProductByStoreId(int storeId) {
	    return sqlSession.selectList(namespace  + "selectProductByStoreId", storeId);
	}
}
