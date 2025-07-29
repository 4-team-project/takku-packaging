package com.takku.project.mapper;

import java.util.List;

import com.takku.project.domain.ProductDTO;

public interface ProductMapper {

	void insertProduct(ProductDTO product);

	List<ProductDTO> selectProductByStoreId(int storeId);

	ProductDTO selectByProductId(int productId);

	void updateProduct(ProductDTO product);

	void deleteProduct(int productId);
}
