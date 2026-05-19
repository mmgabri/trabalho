*=================================================================
       2000-MONTA-HTML                 SECTION.
      *=================================================================
      *  MONTA O HTML EM BLOCOS USANDO WITH POINTER. CADA STRING        
      *  APENDA DIRETO EM WS-HTML-COMPLETO A PARTIR DE WS-POS.          
      *  CAMPOS COM TRAILING SPACES USAM DELIMITED BY '  ' (2 ESPACOS)  
      *  PARA EVITAR ESPACOS A DIREITA NO HTML FINAL.                   
      *=================================================================
           MOVE SPACES TO WS-HTML-COMPLETO.
           MOVE 1      TO WS-POS.

      *--- ABERTURA ---
           STRING
             '<html><body style="margin:0;padding:0;'
             'background-color:#ffffff;">'
             '<table width="100%" cellpadding="0" cellspacing="0" '
             'border="0"><tr><td align="center">'
             '<table width="560" cellpadding="0" cellspacing="0" '
             'border="0" style="background-color:#ffffff;'
             'border:1px solid #e0e0e0;"><tr><td '
             'style="padding:32px 36px;color:#222222;'
             'font-family:Arial,sans-serif;">'
                                DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- TITULO ---
           STRING
             '<div style="font-size:18px;color:'
                                DELIMITED BY SIZE
             WS-COR-TITULO      DELIMITED BY '  '
             ';font-weight:bold;">'
                                DELIMITED BY SIZE
             WS-TITULO          DELIMITED BY '  '
             '</div>'           DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA SEPARADORA ---
           STRING
             '<div style="border-top:1px solid #e0e0e0;'
             'margin:20px 0;"></div>'
                                DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- ABERTURA DA TABELA ---
           STRING
             '<table cellpadding="0" cellspacing="0" border="0" '
             'style="font-size:13px;color:#333333;">'
                                DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA MIP ---
           STRING
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'MIP</td>'
             '<td style="padding:4px 0;font-family:'
             '''Courier New'',Courier,monospace;'
             'font-weight:bold;">'
                                DELIMITED BY SIZE
             WS-MIP             DELIMITED BY '  '
             '</td></tr>'       DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA DATA/HORA ---
           STRING
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Data/Hora</td>'
             '<td style="padding:4px 0;">'
                                DELIMITED BY SIZE
             WS-DATA-HORA       DELIMITED BY '  '
             '</td></tr>'       DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA ORIGEM ---
           STRING
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Origem</td>'
             '<td style="padding:4px 0;">'
                                DELIMITED BY SIZE
             WS-ORIGEM          DELIMITED BY '  '
             '</td></tr>'       DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA SIMULACAO ---
           STRING
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Simulacao</td>'
             '<td style="'
                                DELIMITED BY SIZE
             WS-SIMU-ESTILO     DELIMITED BY '  '
             '">'               DELIMITED BY SIZE
             WS-SIMU-TXT        DELIMITED BY '  '
             '</td></tr>'       DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA PORTA 6005 CICS ---
           STRING
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Porta 6005 - CICS</td>'
             '<td style="padding:4px 0;color:'
                                DELIMITED BY SIZE
             WS-PORTA-CICS-COR  DELIMITED BY '  '
             ';">'              DELIMITED BY SIZE
             WS-PORTA-CICS-TXT  DELIMITED BY '  '
             '</td></tr>'       DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA PORTA 7005 AWS ---
           STRING
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Porta 7005 - AWS</td>'
             '<td style="padding:4px 0;color:'
                                DELIMITED BY SIZE
             WS-PORTA-AWS-COR   DELIMITED BY '  '
             ';">'              DELIMITED BY SIZE
             WS-PORTA-AWS-TXT   DELIMITED BY '  '
             '</td></tr>'       DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA ID ---
           STRING
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'ID</td>'
             '<td style="padding:4px 0;font-family:'
             '''Courier New'',Courier,monospace;">'
                                DELIMITED BY SIZE
             WS-ID-PROC         DELIMITED BY '  '
             '</td></tr></table>'
                                DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA SEPARADORA ---
           STRING
             '<div style="border-top:1px solid #e0e0e0;'
             'margin:20px 0;"></div>'
                                DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- MENSAGEM ---
           STRING
             '<div style="font-size:12px;color:#888;">Mensagem'
             '</div>'
             '<div style="font-size:13px;color:#333;'
             'padding-top:4px;line-height:1.5;">'
                                DELIMITED BY SIZE
             WS-MENSAGEM        DELIMITED BY '  '
             '</div>'           DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- LINHA SEPARADORA ---
           STRING
             '<div style="border-top:1px solid #e0e0e0;'
             'margin:20px 0;"></div>'
                                DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- RODAPE ---
           STRING
             '<div style="font-size:11px;color:#aaa;">'
             'Mensagem automatica. Nao responda este e-mail.'
             '</div>'
                                DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.

      *--- FECHAMENTO ---
           STRING
             '</td></tr></table></td></tr></table>'
             '</body></html>'
                                DELIMITED BY SIZE
             INTO WS-HTML-COMPLETO
             WITH POINTER WS-POS
           END-STRING.
