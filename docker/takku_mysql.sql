-- 1. 계정 및 DB 생성 (root 계정에서 실행해야 함)
CREATE USER IF NOT EXISTS 'takku'@'localhost' IDENTIFIED BY 'takku1234';
CREATE DATABASE IF NOT EXISTS takku_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON takku_db.* TO 'takku'@'localhost';
FLUSH PRIVILEGES;

-- 2. 사용할 DB 선택
USE takku_db;

-- 3. 테이블 생성 (기존 테이블이 있으면 삭제)
DROP TABLE IF EXISTS user;

CREATE TABLE user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- 4. 더미 데이터 삽입
INSERT INTO user (name) VALUES 
('John Smith'),
('Emily Johnson'),
('Michael Brown'),
('Sophia Davis'),
('Liam Wilson'),
('Emma Garcia'),
('Olivia Martinez'),
('Noah Lee'),
('Ava Kim'),
('James Chen');

-- 사용자 테이블
CREATE TABLE takku_user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_type ENUM('소상공인', '사용자') NOT NULL,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    gender ENUM('남', '여') NOT NULL,
    birth DATE NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    sido VARCHAR(20),
    sigungu VARCHAR(30),
    is_partner ENUM('Y', 'N') NOT NULL,
    point INT DEFAULT 0 NOT NULL,
    created_at DATETIME NOT NULL
);

-- 포인트 내역 테이블
CREATE TABLE takku_point (
    point_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    point_change INT NOT NULL,
    reason ENUM('적립', '사용') NOT NULL,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES takku_user(user_id)
);

-- 상점 카테고리 테이블
CREATE TABLE takku_store_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL
);

-- 상점 테이블
CREATE TABLE takku_store (
    store_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    business_number VARCHAR(20) UNIQUE NOT NULL,
    bank_account VARCHAR(50),
    store_name VARCHAR(100) NOT NULL,
    sido VARCHAR(20) NOT NULL,
    sigungu VARCHAR(30) NOT NULL,
    dong VARCHAR(30),
    address_detail VARCHAR(255),
    category_id INT NOT NULL,
    description TEXT,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES takku_user(user_id),
    FOREIGN KEY (category_id) REFERENCES takku_store_category(category_id)
);

-- 상품 테이블
CREATE TABLE takku_product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    store_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price INT NOT NULL,
    description TEXT,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (store_id) REFERENCES takku_store(store_id)
);

-- 펀딩 테이블
CREATE TABLE takku_funding (
    funding_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    store_id INT NOT NULL,
    funding_type ENUM('한정', '일반') NOT NULL,
    funding_name VARCHAR(100) NOT NULL,
    funding_desc TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    sale_price INT NOT NULL,
    target_qty INT NOT NULL,
    max_qty INT NOT NULL,
    current_qty INT NOT NULL,
    per_qty INT,
    status ENUM('준비중','진행중','성공','실패') NOT NULL,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (product_id) REFERENCES takku_product(product_id),
    FOREIGN KEY (store_id) REFERENCES takku_store(store_id)
);

-- 태그 및 매핑
CREATE TABLE takku_tag (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE takku_funding_tag (
    funding_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (funding_id, tag_id),
    FOREIGN KEY (funding_id) REFERENCES takku_funding(funding_id),
    FOREIGN KEY (tag_id) REFERENCES takku_tag(tag_id)
);

-- 주문 테이블
CREATE TABLE takku_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    funding_id INT NOT NULL,
    qty INT NOT NULL,
    amount INT NOT NULL,
    use_point INT,
    discount_amount INT,
    status ENUM('결제완료','환불') NOT NULL,
    funding_status ENUM('펀딩 진행중','펀딩실패','쿠폰발급완료') NOT NULL,
    payment_method ENUM('카드','계좌이체','포인트','기타') NOT NULL,
    purchased_at DATETIME NOT NULL,
    refund_at DATETIME,
    imp_uid VARCHAR(30),
    merchant_uid VARCHAR(30),
    FOREIGN KEY (user_id) REFERENCES takku_user(user_id),
    FOREIGN KEY (funding_id) REFERENCES takku_funding(funding_id)
);

-- 쿠폰 테이블
CREATE TABLE takku_coupon (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    funding_id INT NOT NULL,
    user_id INT NOT NULL,
    store_id INT NOT NULL,
    coupon_code VARCHAR(50) UNIQUE NOT NULL,
    use_status ENUM('미사용','사용','선물됨') NOT NULL,
    used_at DATETIME,
    reviewed TINYINT(1) DEFAULT 0,
    created_at DATETIME NOT NULL,
    expired_at DATETIME NOT NULL,
    FOREIGN KEY (funding_id) REFERENCES takku_funding(funding_id),
    FOREIGN KEY (user_id) REFERENCES takku_user(user_id),
    FOREIGN KEY (store_id) REFERENCES takku_store(store_id)
);

-- 정산 테이블
CREATE TABLE takku_settlement (
    settlement_id INT AUTO_INCREMENT PRIMARY KEY,
    funding_id INT,
    store_id INT,
    fee INT NOT NULL,
    amount INT NOT NULL,
    status ENUM('대기','완료') NOT NULL,
    settled_at DATETIME,
    FOREIGN KEY (funding_id) REFERENCES takku_funding(funding_id),
    FOREIGN KEY (store_id) REFERENCES takku_store(store_id)
);

-- 리뷰 테이블
CREATE TABLE takku_review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    content TEXT,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES takku_user(user_id),
    FOREIGN KEY (product_id) REFERENCES takku_product(product_id)
);

-- 이미지 테이블
CREATE TABLE takku_image (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    funding_id INT,
    review_id INT,
    image_url VARCHAR(255) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES takku_product(product_id),
    FOREIGN KEY (funding_id) REFERENCES takku_funding(funding_id),
    FOREIGN KEY (review_id) REFERENCES takku_review(review_id)
);

-- 1. takku_store_category (상점 카테고리)
INSERT INTO takku_store_category (category_name) VALUES 
('한식'),
('분식'),
('중식'),
('일식'),
('양식'),
('아시안'),
('패스트푸드'),
('카페/디저트'),
('도시락');

-- 2. takku_user (사용자)
-- 소상공인
INSERT INTO takku_user (user_type, password, name, gender, birth, nickname, phone, sido, sigungu, is_partner, created_at) VALUES
('소상공인', 'Pass123!', '김한식', '남', STR_TO_DATE('1980-01-01','%Y-%m-%d'), '한식달인', '010-1000-1000', '서울', '종로구', 'Y', NOW()),
('소상공인', 'Food456$', '이중식', '남', STR_TO_DATE('1985-02-02','%Y-%m-%d'), '중식장인', '010-2000-2000', '서울', '강남구', 'Y', NOW()),
('소상공인', 'Sushi789#', '박일식', '남', STR_TO_DATE('1990-03-03','%Y-%m-%d'), '일식명인', '010-3000-3000', '부산', '해운대구', 'Y', NOW()),
('소상공인', 'Cafe321#', '홍디저트', '여', STR_TO_DATE('1992-04-04','%Y-%m-%d'), '달달홍', '010-7000-7000', '서울', '마포구', 'Y', NOW());

-- 일반 사용자
INSERT INTO takku_user (user_type, password, name, gender, birth, nickname, phone, sido, sigungu, is_partner, created_at) VALUES
('사용자', 'User123!', '정소비자', '여', STR_TO_DATE('1995-05-05','%Y-%m-%d'), '소비짱', '010-4000-4000', '서울', '서초구', 'N', NOW()),
('사용자', 'User234@', '김슬기', '여', STR_TO_DATE('1992-07-10','%Y-%m-%d'), '슬기짱', '010-5000-5000', '부산', '수영구', 'N', NOW()),
('사용자', 'User345#', '최강식', '남', STR_TO_DATE('1978-12-20','%Y-%m-%d'), '강먹보', '010-6000-6000', '서울', '영등포구', 'N', NOW()),
('사용자', 'User456$', '박디저', '여', STR_TO_DATE('1996-03-15','%Y-%m-%d'), '디저여왕', '010-8000-8000', '서울', '은평구', 'N', NOW());

-- 3. takku_store (상점)
INSERT INTO takku_store (user_id, business_number, bank_account, store_name, sido, sigungu, dong, address_detail, category_id, description, created_at) VALUES
(1, '123-45-67890', '111-222-3333', '김한식 맛집', '서울', '종로구', '청운동', '12번지', 1, '정통 한식 전문점입니다.', NOW()),
(2, '223-55-77890', '222-333-4444', '이중식 차이나', '서울', '강남구', '삼성동', '34번지', 3, '정통 중식 전문점입니다.', NOW()),
(3, '323-65-88890', '333-444-5555', '박일식 스시', '부산', '해운대구', '좌동', '56번지', 4, '정통 일식 스시 전문점입니다.', NOW()),
(4, '423-75-99890', '444-555-6666', '홍디저트 카페', '서울', '마포구', '서교동', '101-1', 8, '디저트와 커피를 즐길 수 있는 카페입니다.', NOW()),
(1, '555-66-77777', '555-666-7777', '분식달인', '서울', '강북구', '수유동', '101', 2, '분식 전문점입니다.', NOW()),
(2, '666-77-88888', '666-777-8888', '양식마스터', '경기', '성남시', '분당구', '202', 5, '양식 전문점입니다.', NOW());











commit;


