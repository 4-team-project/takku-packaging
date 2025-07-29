package com.takku.project.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.takku.project.domain.OrderDTO;

public interface OrderMapper {

	// 주문 구매자 ID로 조회
	List<OrderDTO> selectByUserId(Integer userId);

	// 주문 생성
	int insertOrder(OrderDTO order);

	// 주문 펀딩 상태 수정
	int updateOrderFundingStatus(int orderId);

	// 주문 결제 상태 및 환불일 수정
	int updateOrderRefundAtStatus(OrderDTO order);

	// 메뉴이름 가져올거야
	String getProductNameByOrderId(int orderId);

	// orderId받기
	OrderDTO selectOrderByOrderId(int orderId);

	// 펀딩 이름 가져올거야
	String getFundingNameByOrderId(int orderId);

	// userid랑 status 가져올거야
	List<OrderDTO> getOrdersByUserAndStatus(@Param("userId") int userId, @Param("status") String status);


	List<OrderDTO> searchOrders(int userId, String keyword);

	List<OrderDTO> selectCompletedOrdersByFundingId(@Param("fundingId") int fundingId);

}
