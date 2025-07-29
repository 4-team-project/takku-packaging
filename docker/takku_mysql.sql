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
('홍길동'),
('김철수'),
('이영희'),
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
