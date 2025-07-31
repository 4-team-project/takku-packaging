package com.takku.project.service;

import java.security.cert.X509Certificate;
import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.takku.project.domain.AIResponse;
import com.takku.project.domain.FundingDTO;
import com.takku.project.domain.FundingPromotionRequestDto;
import com.takku.project.domain.ProductDTO;
import com.takku.project.domain.StoreDTO;
import com.takku.project.domain.stats.SummaryResponse;

import lombok.RequiredArgsConstructor;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Protocol;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

@Service
@RequiredArgsConstructor
public class AIService implements DisposableBean {

	@Value("${groq.api.url}")
	private String apiUrl;

	@Value("${groq.api.key}")
	private String apiKey;

	@Value("${groq.api.model}")
	private String model;

	@Value("${external.ai.api.url}")
	private String aiApiBaseUrl;

	@Value("${external.ai.api.timeout:30000}")
	private int apiTimeout;

	@Value("${external.ai.api.retry.max:3}")
	private int maxRetries;

	@Value("${external.ai.api.use-https:true}")
	private boolean useHttps;

	private final ProductService productService;
	private final StoreService storeService;

	private final ObjectMapper mapper = new ObjectMapper();

	private final OkHttpClient client = createDefaultClient();
	private final OkHttpClient clientWithVerifier = createClientForRailway();

	private OkHttpClient createDefaultClient() {
		return new OkHttpClient.Builder().protocols(List.of(Protocol.HTTP_1_1)).connectTimeout(30, TimeUnit.SECONDS)
				.readTimeout(120, TimeUnit.SECONDS).writeTimeout(30, TimeUnit.SECONDS).build();
	}

	private OkHttpClient createClientForRailway() {
		try {
			OkHttpClient.Builder builder = new OkHttpClient.Builder().protocols(List.of(Protocol.HTTP_1_1))
					.connectTimeout(apiTimeout / 1000, TimeUnit.SECONDS).readTimeout(120, TimeUnit.SECONDS)
					.writeTimeout(30, TimeUnit.SECONDS).retryOnConnectionFailure(true);

			// Railway 도메인 패턴 허용
			builder.hostnameVerifier((hostname, session) -> {
				return hostname.endsWith(".railway.app") || hostname.endsWith(".up.railway.app")
						|| hostname.equals("takku-ai-api-production.up.railway.app") || hostname.equals("localhost"); // 개발용
			});

			// SSL 설정 - Railway 환경에 최적화
			if (useHttps) {
				// Trust all certificates for Railway
				TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
					@Override
					public void checkClientTrusted(X509Certificate[] chain, String authType) {
					}

					@Override
					public void checkServerTrusted(X509Certificate[] chain, String authType) {
					}

					@Override
					public X509Certificate[] getAcceptedIssuers() {
						return new X509Certificate[] {};
					}
				} };

				SSLContext sslContext = SSLContext.getInstance("TLS");
				sslContext.init(null, trustAllCerts, new java.security.SecureRandom());

				builder.sslSocketFactory(sslContext.getSocketFactory(), (X509TrustManager) trustAllCerts[0]);
			}

			return builder.build();
		} catch (Exception e) {
			System.err.println("⚠️ Railway SSL 설정 실패, 기본 설정 사용: " + e.getMessage());
			return createDefaultClient();
		}
	}

	@Override
	public void destroy() {
		System.out.println("🫹 AIService 종료 중 - OkHttp 정리");
		client.connectionPool().evictAll();
		client.dispatcher().executorService().shutdown();
		clientWithVerifier.connectionPool().evictAll();
		clientWithVerifier.dispatcher().executorService().shutdown();
	}

	/**
	 * Railway API 헬스 체크
	 */
	public boolean isRailwayApiHealthy() {
		try {
			String healthUrl = getApiUrl() + "/health";
			Request request = new Request.Builder().url(healthUrl).addHeader("User-Agent", "TakkuApp/1.0").get()
					.build();

			try (Response response = clientWithVerifier.newCall(request).execute()) {
				return response.isSuccessful();
			}
		} catch (Exception e) {
			System.err.println("🔍 Railway 헬스 체크 실패: " + e.getMessage());
			return false;
		}
	}

	/**
	 * API URL 생성 (HTTP/HTTPS 설정 고려)
	 */
	private String getApiUrl() {
		String baseUrl = aiApiBaseUrl;
		if (!useHttps && baseUrl.startsWith("https://")) {
			baseUrl = baseUrl.replace("https://", "http://");
		}
		return baseUrl;
	}

	public SummaryResponse getReviewSummary(int productId) {
		String url = getApiUrl() + "/summary/" + productId;

		for (int attempt = 1; attempt <= maxRetries; attempt++) {
			try {
				Request request = new Request.Builder().url(url).addHeader("User-Agent", "TakkuApp/1.0").get().build();

				try (Response response = clientWithVerifier.newCall(request).execute()) {
					if (!response.isSuccessful()) {
						if (isRetryableError(response.code()) && attempt < maxRetries) {
							System.err.println("⚠️ 요약 API 재시도 중... (" + attempt + "/" + maxRetries + ") - HTTP "
									+ response.code());
							Thread.sleep(getBackoffDelay(attempt));
							continue;
						}
						throw new RuntimeException("요약 FastAPI 호출 실패: HTTP " + response.code());
					}

					String responseBody = response.body().string();
					JsonNode root = mapper.readTree(responseBody);

					JsonNode summaryNode = root.path("summary");
					if (summaryNode.isMissingNode() || !summaryNode.has("positive") || !summaryNode.has("negative")) {
						throw new RuntimeException("요약 결과 형식이 올바르지 않습니다.");
					}

					List<String> positive = mapper.convertValue(summaryNode.get("positive"), new TypeReference<>() {
					});
					List<String> negative = mapper.convertValue(summaryNode.get("negative"), new TypeReference<>() {
					});

					return new SummaryResponse(productId, positive, negative);
				}

			} catch (Exception e) {
				if (attempt == maxRetries) {
					throw new RuntimeException(
							"요약 API 처리 실패 - productId: " + productId + ", message: " + e.getMessage(), e);
				}

				System.err
						.println("⚠️ 요약 API 호출 실패, 재시도 중... (" + attempt + "/" + maxRetries + ") - " + e.getMessage());
				try {
					Thread.sleep(getBackoffDelay(attempt));
				} catch (InterruptedException ie) {
					Thread.currentThread().interrupt();
					throw new RuntimeException("재시도 중 인터럽트 발생", ie);
				}
			}
		}

		throw new IllegalStateException("요약 API 호출 실패: 모든 재시도 실패");
	}

	public List<FundingDTO> getRecommendations(int userId) {
		String json = getRecommendationsAsString(userId);
		return parseRecommendationList(json);
	}

	public String getRecommendationsAsString(int userId) {
		// 헬스 체크 (첫 번째 시도에만)
		if (!isRailwayApiHealthy()) {
			System.err.println("⚠️ Railway API 서버가 응답하지 않습니다.");
		}

		String fullUrl = getApiUrl() + "/recommend/" + userId;

		for (int attempt = 1; attempt <= maxRetries; attempt++) {
			try {
				Request request = new Request.Builder().url(fullUrl).addHeader("User-Agent", "TakkuApp/1.0")
						.addHeader("Accept", "application/json").get().build();

				try (Response response = clientWithVerifier.newCall(request).execute()) {
					if (!response.isSuccessful()) {
						if (isRetryableError(response.code()) && attempt < maxRetries) {
							System.err.println("⚠️ 추천 API 재시도 중... (" + attempt + "/" + maxRetries + ") - HTTP "
									+ response.code());
							Thread.sleep(getBackoffDelay(attempt));
							continue;
						}
						throw new RuntimeException(
								"추천 FastAPI API 호출 실패: HTTP " + response.code() + " - userId: " + userId);
					}

					String responseBody = response.body().string();
					if (responseBody == null || responseBody.trim().isEmpty()) {
						throw new RuntimeException("추천 API 응답이 비어있습니다.");
					}

					return responseBody;
				}

			} catch (Exception e) {
				if (attempt == maxRetries) {
					throw new RuntimeException(
							"추천 FastAPI API 호출 실패 - userId: " + userId + ", message: " + e.getMessage(), e);
				}

				System.err
						.println("⚠️ 추천 API 호출 실패, 재시도 중... (" + attempt + "/" + maxRetries + ") - " + e.getMessage());
				try {
					Thread.sleep(getBackoffDelay(attempt));
				} catch (InterruptedException ie) {
					Thread.currentThread().interrupt();
					throw new RuntimeException("재시도 중 인터럽트 발생", ie);
				}
			}
		}

		throw new IllegalStateException("추천 API 호출 실패: 모든 재시도 실패");
	}

	/**
	 * 재시도 가능한 에러 코드 판별
	 */
	private boolean isRetryableError(int code) {
		return code == 500 || code == 502 || code == 503 || code == 504 || code == 429;
	}

	/**
	 * 백오프 지연 시간 계산
	 */
	private long getBackoffDelay(int attempt) {
		return Math.min(1000 * (long) Math.pow(2, attempt - 1), 5000); // 최대 5초
	}

	public AIResponse generateFundingContent(FundingPromotionRequestDto req) {
		ProductDTO product = productService.selectByProductId(req.getProductId());
		if (product == null)
			throw new IllegalArgumentException("존재하지 않는 상품입니다. productId=" + req.getProductId());

		StoreDTO store = storeService.selectStoreById(product.getStoreId());
		if (store == null)
			throw new IllegalArgumentException("상품에 연결된 상점이 존재하지 않습니다. storeId=" + product.getStoreId());

		String prompt = buildPrompt(req, product, store);
		int maxGroqRetries = 10;

		for (int attempts = 1; attempts <= maxGroqRetries; attempts++) {
			try {
				String requestBody = buildGroqRequestBody(prompt);
				Request request = new Request.Builder().url(apiUrl).addHeader("Authorization", "Bearer " + apiKey)
						.addHeader("User-Agent", "TakkuApp/1.0")
						.post(RequestBody.create(requestBody, MediaType.parse("application/json"))).build();

				try (Response response = client.newCall(request).execute()) {
					if (!response.isSuccessful()) {
						if (response.code() == 429 && attempts < maxGroqRetries) {
							System.err
									.println("⚠️ Groq API 레이트 리밋, 재시도 중... (" + attempts + "/" + maxGroqRetries + ")");
							Thread.sleep(getBackoffDelay(attempts));
							continue;
						}
						throw new RuntimeException("Groq API 호출 실패: HTTP " + response.code());
					}
					String responseBody = response.body().string();
					return parseGroqResponse(responseBody);
				}

			} catch (Exception e) {
				if (attempts == maxGroqRetries) {
					throw new RuntimeException("AI 홍보글 생성 실패 - 재시도 실패 (" + attempts + "회): " + e.getMessage(), e);
				}
				System.err.println("⚠️ Groq 응답 파싱 실패, 재시도 중... (" + attempts + "회)");
				try {
					Thread.sleep(getBackoffDelay(attempts));
				} catch (InterruptedException ie) {
					Thread.currentThread().interrupt();
					throw new RuntimeException("재시도 중 인터럽트 발생", ie);
				}
			}
		}

		throw new IllegalStateException("AI 홍보글 생성 실패: 알 수 없는 오류");
	}

	private String buildPrompt(FundingPromotionRequestDto req, ProductDTO product, StoreDTO store) {
		return String.join("\n", "다음 조건에 따라 홍보글을 작성하세요.", "", "[출력 조건]", "1. 출력은 반드시 JSON 형식입니다.",
				"2. JSON 구조는 다음과 같아야 합니다:", "{\"title\":\"...\", \"content\":\"...\", \"hashtags\":\"...\"}",
				"3. content는 400자 이상이며 HTML 형식이어야 합니다.",
				"4. content에는 이모지를 포함하고, <div>, <ul>, <li>, <h3>, <hr>, <span> 태그 등을 사용할 수 있습니다.",
				"5. content에는 해시태그를 넣지 마세요.", "6. HTML 속성값의 따옴표(\")는 반드시 \\\"로 escape 처리하세요.",
				"7. 전체 JSON 문자열 내 모든 따옴표(\")도 \\\"로 escape 처리하세요.", "", "[제공된 정보]", "상품명: " + product.getProductName(),
				"상품설명: " + product.getDescription(), "원가: " + product.getPrice() + "원",
				"판매가: " + req.getSalePrice() + "원", "상점명: " + store.getStoreName(), "상점 설명: " + store.getDescription(),
				"카테고리: " + store.getCategoryName(), "지역: " + store.getSido() + " " + store.getSigungu(),
				"키워드: " + req.getKeyword(), "타겟층: " + req.getTarget());
	}

	private String buildGroqRequestBody(String prompt) throws Exception {
		ObjectNode jsonNode = mapper.createObjectNode();
		jsonNode.put("model", model);

		ArrayNode messages = mapper.createArrayNode();

		ObjectNode systemMsg = mapper.createObjectNode();
		systemMsg.put("role", "system");
		systemMsg.put("content", "반드시 JSON 형식으로만 응답해.");
		messages.add(systemMsg);

		ObjectNode userMsg = mapper.createObjectNode();
		userMsg.put("role", "user");
		userMsg.put("content", prompt);
		messages.add(userMsg);

		jsonNode.set("messages", messages);
		jsonNode.put("temperature", 0.7);
		jsonNode.put("max_tokens", 2048);
		jsonNode.put("stream", false);

		return mapper.writeValueAsString(jsonNode);
	}

	private AIResponse parseGroqResponse(String responseBody) throws Exception {
		JsonNode rootNode = mapper.readTree(responseBody);
		if (rootNode.has("error")) {
			throw new RuntimeException("Groq API 에러: " + rootNode.get("error").get("message").asText());
		}

		JsonNode choicesNode = rootNode.path("choices");
		if (!choicesNode.isArray() || choicesNode.size() == 0) {
			throw new RuntimeException("Groq API 응답에 choices가 없음");
		}

		String content = choicesNode.get(0).path("message").path("content").asText(null);
		if (content == null)
			throw new RuntimeException("Groq API 응답에서 content가 없음");

		String cleanedJson = content.replaceAll("(?s)<think>.*?</think>", "").replaceAll("(?i)```json\\s*", "")
				.replaceAll("```", "").replaceAll("[\\n\\r]", "").trim();

		JsonNode jsonResult = mapper.readTree(cleanedJson);

		String title = jsonResult.path("title").asText(null);
		String htmlContent = jsonResult.path("content").asText(null);
		String hashtagsRaw = jsonResult.path("hashtags").asText(null);

		if (title == null || title.trim().isEmpty())
			throw new IllegalArgumentException("AI 응답 title이 누락되었거나 비어있음: " + cleanedJson);
		if (htmlContent == null || htmlContent.trim().length() < 400)
			throw new IllegalArgumentException("AI 응답 content가 너무 짧거나 없음: " + cleanedJson);
		if (hashtagsRaw == null || hashtagsRaw.trim().isEmpty())
			throw new IllegalArgumentException("AI 응답 hashtags가 없음: " + cleanedJson);

		AIResponse aiResponse = new AIResponse();
		aiResponse.setTitle(title);
		aiResponse.setContent(htmlContent);
		aiResponse.setHashtags(hashtagsRaw);

		boolean allValid = aiResponse.getHashtags().stream().allMatch(tag -> tag.startsWith("#"));
		if (!allValid)
			throw new IllegalArgumentException("해시태그 형식 오류: " + aiResponse.getHashtags());

		return aiResponse;
	}

	private List<FundingDTO> parseRecommendationList(String json) {
		try {
			return mapper.readValue(json, new TypeReference<>() {
			});
		} catch (Exception e) {
			throw new RuntimeException("추천 FastAPI API 결과 파싱 실패 - message: " + e.getMessage(), e);
		}
	}
}