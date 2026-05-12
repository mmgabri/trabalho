      ******************************************************************
      * PROGRAMA : MONTAEML                                            *
      * FUNCAO   : MONTA HTML DE NOTIFICACAO DAS OPERACOES DO          *
      *            AUTORIZADOR DEBITO (ATIVACAO/DESATIVACAO DE         *
      *            CONTINGENCIA, SIGN-ON E SIGN-OFF DE CICS/AWS).      *
      *            HTML FICA EM AREA DE WORKING (ONLINE).              *
      *                                                                *
      * ENTRADAS : WS-TITULO, WS-RESULTADO, WS-MIP, WS-DATA-HORA,      *
      *            WS-ORIGEM, WS-SIMULACAO, WS-PORTA-CICS-ON,          *
      *            WS-PORTA-AWS-ON, WS-ID-PROC, WS-MENSAGEM            *
      *                                                                *
      * SAIDA    : WS-HTML-COMPLETO (PIC X(4000))                      *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID.    MONTAEML.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *-----------------------------------------------------------------
      * DADOS DE ENTRADA                                                
      *-----------------------------------------------------------------
       01  WS-ENTRADA.
           05  WS-TITULO          PIC X(50) VALUE
               'Contingencia ativada'.
      *        EXEMPLOS DE TITULO:                                      
      *          - Contingencia ativada                                 
      *          - Contingencia desativada                              
      *          - Sign-on CICS executado                               
      *          - Sign-on AWS executado                                
      *          - Sign-off CICS executado                              
      *          - Sign-off AWS executado                               
      *          - Falha na ativacao da contingencia                    
      *          - Falha no sign-off CICS                               
      *          - etc.                                                 

           05  WS-RESULTADO       PIC X(01) VALUE 'S'.
      *                              'S' = SUCESSO (TITULO VERDE)       
      *                              'E' = ERRO    (TITULO VERMELHO)    

           05  WS-MIP             PIC X(03) VALUE 'A07'.
           05  WS-DATA-HORA       PIC X(19) VALUE
               '12/05/2026 14:32:07'.
           05  WS-ORIGEM          PIC X(10) VALUE 'Operacao'.
      *                              'Operacao' OU 'AUTS'               

           05  WS-SIMULACAO       PIC X(01) VALUE 'N'.
      *                              'S' = SIM (LARANJA + BOLD)         
      *                              'N' = NAO (TEXTO NORMAL)           

           05  WS-PORTA-CICS-ON   PIC X(01) VALUE 'S'.
           05  WS-PORTA-AWS-ON    PIC X(01) VALUE 'N'.
      *                              'S' = ON (VERDE) / 'N' = OFF       

           05  WS-ID-PROC         PIC X(16) VALUE
               'a3f9c1e7b2d84f6c'.

           05  WS-MENSAGEM        PIC X(200) VALUE
               'Ativacao executada dentro da janela prevista.'.

      *-----------------------------------------------------------------
      * VARIAVEIS SELECIONADAS CONFORME O RESULTADO/ENTRADAS            
      *-----------------------------------------------------------------
       01  WS-VARS.
           05  WS-COR-TITULO      PIC X(07) VALUE SPACES.
           05  WS-PORTA-CICS-TXT  PIC X(03) VALUE SPACES.
           05  WS-PORTA-CICS-COR  PIC X(07) VALUE SPACES.
           05  WS-PORTA-AWS-TXT   PIC X(03) VALUE SPACES.
           05  WS-PORTA-AWS-COR   PIC X(07) VALUE SPACES.
           05  WS-SIMU-TXT        PIC X(03) VALUE SPACES.
           05  WS-SIMU-ESTILO     PIC X(50) VALUE SPACES.

      *-----------------------------------------------------------------
      * SAIDA                                                           
      *-----------------------------------------------------------------
       01  WS-HTML-COMPLETO       PIC X(4000) VALUE SPACES.
       01  WS-AUX                 PIC X(4000) VALUE SPACES.

       PROCEDURE DIVISION.
      *=================================================================
       0000-PRINCIPAL                  SECTION.
      *=================================================================
           PERFORM 1000-DEFINE-VARIAVEIS
           PERFORM 2000-MONTA-HTML
           GOBACK.

      *=================================================================
       1000-DEFINE-VARIAVEIS           SECTION.
      *=================================================================
      *  DEFINE COR DO TITULO, TEXTO/COR DE CADA PORTA E ESTILO DA      
      *  LINHA DE SIMULACAO CONFORME OS FLAGS DE ENTRADA.               
      *=================================================================

      *--- COR DO TITULO ---
           IF WS-RESULTADO = 'S'
               MOVE '#1E7E34' TO WS-COR-TITULO
           ELSE
               MOVE '#D93025' TO WS-COR-TITULO
           END-IF.

      *--- PORTA CICS ---
           IF WS-PORTA-CICS-ON = 'S'
               MOVE 'On'      TO WS-PORTA-CICS-TXT
               MOVE '#1E7E34' TO WS-PORTA-CICS-COR
           ELSE
               MOVE 'Off'     TO WS-PORTA-CICS-TXT
               MOVE '#D93025' TO WS-PORTA-CICS-COR
           END-IF.

      *--- PORTA AWS ---
           IF WS-PORTA-AWS-ON = 'S'
               MOVE 'On'      TO WS-PORTA-AWS-TXT
               MOVE '#1E7E34' TO WS-PORTA-AWS-COR
           ELSE
               MOVE 'Off'     TO WS-PORTA-AWS-TXT
               MOVE '#D93025' TO WS-PORTA-AWS-COR
           END-IF.

      *--- SIMULACAO ---
           IF WS-SIMULACAO = 'S'
               MOVE 'Sim' TO WS-SIMU-TXT
               MOVE 'padding:4px 0;color:#B25E00;font-weight:bold;'
                          TO WS-SIMU-ESTILO
           ELSE
               MOVE 'Nao' TO WS-SIMU-TXT
               MOVE 'padding:4px 0;'
                          TO WS-SIMU-ESTILO
           END-IF.

      *=================================================================
       2000-MONTA-HTML                 SECTION.
      *=================================================================
      *  MONTA O HTML EM BLOCOS. CADA STRING APENDA UM PEDACO AO        
      *  WS-HTML-COMPLETO ATRAVES DE WS-AUX.                            
      *=================================================================
           MOVE SPACES TO WS-HTML-COMPLETO.

      *--- ABERTURA (CENTRALIZADO VIA TABELA EXTERNA) ---
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
             DELIMITED BY SIZE INTO WS-HTML-COMPLETO
           END-STRING.

      *--- TITULO ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<div style="font-size:18px;color:'
             WS-COR-TITULO
             ';font-weight:bold;">'
             WS-TITULO
             '</div>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA SEPARADORA ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<div style="border-top:1px solid #e0e0e0;'
             'margin:20px 0;"></div>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- ABERTURA DA TABELA ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<table cellpadding="0" cellspacing="0" border="0" '
             'style="font-size:13px;color:#333333;">'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA MIP ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'MIP</td>'
             '<td style="padding:4px 0;font-family:'
             '''Courier New'',Courier,monospace;'
             'font-weight:bold;">'
             WS-MIP
             '</td></tr>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA DATA/HORA ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Data/Hora</td>'
             '<td style="padding:4px 0;">'
             WS-DATA-HORA
             '</td></tr>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA ORIGEM ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Origem</td>'
             '<td style="padding:4px 0;">'
             WS-ORIGEM
             '</td></tr>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA SIMULACAO ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Simulacao</td>'
             '<td style="'
             WS-SIMU-ESTILO
             '">'
             WS-SIMU-TXT
             '</td></tr>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA PORTA 6005 CICS ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Porta 6005 - CICS</td>'
             '<td style="padding:4px 0;color:'
             WS-PORTA-CICS-COR
             ';">'
             WS-PORTA-CICS-TXT
             '</td></tr>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA PORTA 7005 AWS ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'Porta 7005 - AWS</td>'
             '<td style="padding:4px 0;color:'
             WS-PORTA-AWS-COR
             ';">'
             WS-PORTA-AWS-TXT
             '</td></tr>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA ID ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<tr><td style="padding:4px 24px 4px 0;color:#888;">'
             'ID</td>'
             '<td style="padding:4px 0;font-family:'
             '''Courier New'',Courier,monospace;">'
             WS-ID-PROC
             '</td></tr></table>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA SEPARADORA ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<div style="border-top:1px solid #e0e0e0;'
             'margin:20px 0;"></div>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- MENSAGEM ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<div style="font-size:12px;color:#888;">Mensagem'
             '</div>'
             '<div style="font-size:13px;color:#333;'
             'padding-top:4px;line-height:1.5;">'
             WS-MENSAGEM
             '</div>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- LINHA SEPARADORA ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<div style="border-top:1px solid #e0e0e0;'
             'margin:20px 0;"></div>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- RODAPE ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '<div style="font-size:11px;color:#aaa;">'
             'Mensagem automatica. Nao responda este e-mail.'
             '</div>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.

      *--- FECHAMENTO (FECHA AS DUAS TABELAS DE CENTRALIZACAO) ---
           STRING
             WS-HTML-COMPLETO   DELIMITED BY '   '
             '</td></tr></table></td></tr></table>'
             '</body></html>'
             DELIMITED BY SIZE INTO WS-AUX
           END-STRING.
           MOVE WS-AUX TO WS-HTML-COMPLETO.
