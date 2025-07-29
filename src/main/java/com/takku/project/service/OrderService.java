package com.takku.project.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.takku.project.domain.ImageDTO;
import com.takku.project.domain.OrderDTO;
import com.takku.project.mapper.OrderMapper;

@Service
public class OrderService implements OrderMapper {

	@Autowired
	SqlSession sqlSession;
	String namespace = "com.takku.project.mapper.OrderMapper.";

	private final String imageNamespace = "com.takku.project.mapper.ImageMapper.";

	@Override
	public List<OrderDTO> selectByUserId(Integer userId) {
		List<OrderDTO> orderList = sqlSession.selectList(namespace + "selectByUserId", userId);

		for (OrderDTO order : orderList) {
			List<ImageDTO> images = sqlSession.selectList(imageNamespace + "selectImagesByFundingId",
					order.getFundingId());
			order.setImages(images);
		}
		return orderList;
	}

	@Override
	public int insertOrder(OrderDTO order) {
		int result = sqlSession.insert(namespace + "insertOrder", order);
		return result;
	}

	@Override
	public int updateOrderFundingStatus(int orderId) {
		int result = sqlSession.update(namespace + "updateOrderFundingStatus", orderId);
		return result;
	}

	@Override
	public int updateOrderRefundAtStatus(OrderDTO order) {
		int result = sqlSession.update(namespace + "updateOrderRefundAtStatus", order);
		return result;
	}

	@Override
	public String getProductNameByOrderId(int orderId) {
		String result = sqlSession.selectOne(namespace + "getProductNameByOrderId", orderId);
		return result;
	}

	@Override
	public OrderDTO selectOrderByOrderId(int orderId) {
		return sqlSession.selectOne(namespace + "selectOrderByOrderId", orderId);
	}

	@Override
	public String getFundingNameByOrderId(int orderId) {
		String result = sqlSession.selectOne(namespace + "getFundingNameByOrderId", orderId);
		return result;
	}

	@Override
	public List<OrderDTO> getOrdersByUserAndStatus(int userId, String status) {
		Map<String, Object> param = new HashMap<>();
		param.put("userId", userId);
		param.put("status", status);

		List<OrderDTO> orderList = sqlSession.selectList(namespace + "getOrdersByUserAndStatus", param);

		for (OrderDTO order : orderList) {
			List<ImageDTO> images = sqlSession.selectList(imageNamespace + "selectImagesByFundingId",
					order.getFundingId());
			order.setImages(images);
		}
		return orderList;
	}

	  @Override
	    public List<OrderDTO> searchOrders(int userId, String keyword) {
		  Map<String, Object> param = new HashMap<>();
		  param.put("userId", userId);
		  param.put("keyword", keyword);

		  return sqlSession.selectList(namespace + "searchOrders", param);
	    }


	public void refundOrdersForFailedFunding(int fundingId) {
		List<OrderDTO> orders = sqlSession.selectList(namespace + "selectCompletedOrdersByFundingId", fundingId);

		for (OrderDTO order : orders) {
			// 주문 상태를 환불로 변경하고 환불일 설정
			order.setStatus("환불");
			order.setRefundAt(new java.sql.Date(System.currentTimeMillis()));
			sqlSession.update(namespace + "updateOrderRefundAtStatus", order);
		}
	}

	@Override
	public List<OrderDTO> selectCompletedOrdersByFundingId(int fundingId) {
		return sqlSession.selectList(namespace + "selectCompletedOrdersByFundingId", fundingId);
	}

}
