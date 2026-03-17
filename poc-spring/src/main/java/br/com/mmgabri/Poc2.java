package br.com.mmgabri;

import org.springframework.stereotype.Service;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

@Service
public class Poc2 {

    public void execute(String mensagemHex) {
        //prepara para produzir mensagem
        //byte[] bytes = hexToBytes(mensagemHex);

        //forma errada
        //byte[] bytes = mensagemHex.getBytes(StandardCharsets.UTF_8);
        byte[] bytes = mensagemHex.getBytes(Charset.forName("IBM1047"));

        //consumidor da mensagem
        String text = new String(bytes, Charset.forName("IBM1047"));
        System.out.println(text);

    }

    public static byte[] hexToBytes(String hex) {
        if (hex == null) {
            throw new IllegalArgumentException("hex não pode ser null");
        }

        hex = hex.replaceAll("\\s+", "");

        if ((hex.length() % 2) != 0) {
            throw new IllegalArgumentException("hex deve ter quantidade par de caracteres");
        }

        byte[] bytes = new byte[hex.length() / 2];

        for (int i = 0; i < hex.length(); i += 2) {
            int high = Character.digit(hex.charAt(i), 16);
            int low = Character.digit(hex.charAt(i + 1), 16);

            if (high == -1 || low == -1) {
                throw new IllegalArgumentException("hex contém caractere inválido: " + hex.substring(i, i + 2));
            }

            bytes[i / 2] = (byte) ((high << 4) + low);
        }

        return bytes;
    }
}
