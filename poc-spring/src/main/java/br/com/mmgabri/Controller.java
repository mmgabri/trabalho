package br.com.mmgabri;


import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.CompletionStage;

@RestController
@RequiredArgsConstructor
public class Controller {
    private static final Logger logger = LoggerFactory.getLogger(Controller.class);
    private final ConvertHexToText poc1;
    private final Poc2 poc2;

    @PostMapping
    public CompletionStage<ResponseEntity<String>> formatador(@RequestBody String request) {
        logger.info("Starting authorization processing");
        poc2.execute(request);
        return null;
    }
}