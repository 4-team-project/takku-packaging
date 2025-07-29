package com.takku.project.service;

import java.util.Random;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import net.nurigo.sdk.NurigoApp;
import net.nurigo.sdk.message.model.Message;
import net.nurigo.sdk.message.request.SingleMessageSendingRequest;
import net.nurigo.sdk.message.response.SingleMessageSentResponse;
import net.nurigo.sdk.message.service.DefaultMessageService;

@Service
public class SmsService {

    private final DefaultMessageService messageService;

    @Value("${solapi.sender}")
    private String sender;

    public SmsService(@Value("${solapi.api.key}") String apiKey,
                      @Value("${solapi.api.secret}") String apiSecret) {
        this.messageService = NurigoApp.INSTANCE.initialize(apiKey, apiSecret, "https://api.solapi.com");
    }

    public String generateCode() {
        Random random = new Random();
        return String.valueOf(100000 + random.nextInt(900000));  // 6자리 인증번호
    }

    public void sendSms(String to, String code) {
        Message message = new Message();
        message.setFrom(sender);
        message.setTo(to);
        message.setText("[Takku] 인증번호 [" + code + "] 를 입력해주세요.");

        SingleMessageSentResponse response = messageService.sendOne(new SingleMessageSendingRequest(message));
        System.out.println("문자 전송 결과: " + response);
    }
}