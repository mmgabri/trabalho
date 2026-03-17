package br.com.mmgabri;

import org.springframework.stereotype.Service;

import java.nio.charset.Charset;
import java.util.Arrays;

@Service
public class ConvertHexToText {

    public void execute(String input) {
        //String hex = "f1f2f3";
        byte[] bytes = hexToBytes(input);

        String texto = new String(bytes, Charset.forName("Cp1047")); // ou Cp037
        System.out.println(texto); // 123

        textToArrayBytesIbm1047(texto);

    }

    public void textToArrayBytesIbm1047(String text) {
        byte[] bytes = text.getBytes(Charset.forName("IBM1047"));
        System.out.println(Arrays.toString(bytes));
        bytesToEbcdicString(bytes);
    }

    public void bytesToEbcdicString(byte[] bytes) {
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
