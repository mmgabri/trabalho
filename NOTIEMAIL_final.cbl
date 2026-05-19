      *=============================================================*           
       IDENTIFICATION DIVISION.                                                 
      *=============================================================*           
       PROGRAM-ID. NOTIEMAIL.                                                   
       AUTHOR.     AUTORIZADOR-DEBITO.                                          
      *=============================================================*           
      * NOTIFICACAO POR EMAIL DE EVENTOS OPERACIONAIS DO            *           
      * AUTORIZADOR DEBITO.                                         *           
      *                                                             *           
      * PROGRAMA UNICO QUE EXECUTA:                                 *           
      *  1) CARGA DE TITULO, MENSAGEM E STATUS DAS PORTAS POR       *           
      *     TRANSACAO (CTA..CTG)                                    *           
      *  2) MONTAGEM DO HTML DARK-MODE-SAFE PARA OUTLOOK            *           
      *                                                             *           
      * REGRAS DE EXIBICAO NO HTML:                                 *           
      *  - LINHAS DE PORTAS 6005/7005 SO APARECEM PARA CTA E CTB    *           
      *  - TITULO EM VERDE QUANDO WS-SUCCESS = 'SIM'                *           
      *  - TITULO EM VERMELHO QUANDO WS-SUCCESS = 'NAO'             *           
      *  - BARRA LATERAL DO HEADER ACOMPANHA A COR DO TITULO        *           
      *=============================================================*           
                                                                                
       ENVIRONMENT DIVISION.                                                    
       DATA DIVISION.                                                           
       WORKING-STORAGE SECTION.                                                 
                                                                                
      *-------------------------------------------------------------*           
      * CAMPOS DE ENTRADA (PREMISSA: VEM DE COPYBOOK/LINKAGE)       *           
      *-------------------------------------------------------------*           
       01  LTRANS-COD               PIC X(03).                                  
       01  WCTN-MIP                 PIC X(02).                                  
       01  WCTN-INTERACAO           PIC 9(02).                                  
       01  WCTN-CODRET-CICS         PIC X(02).                                  
       01  WCTN-CODRET-AWS          PIC X(02).                                  
       01  WCTN-SIMULACAO           PIC X(03).                                  
           88  EH-SIMULACAO         VALUE 'SIM'.                                
                                                                                
      *-------------------------------------------------------------*           
      * CAMPOS DE SAIDA DA CARGA                                    *           
      *-------------------------------------------------------------*           
       01  WS-SUCCESS               PIC X(03)  VALUE 'NAO'.                     
           88  SUCESSO              VALUE 'SIM'.                                
           88  FALHA                VALUE 'NAO'.                                
                                                                                
       01  WS-TITULO                PIC X(80)  VALUE SPACES.                    
       01  WS-MENSAGEM              PIC X(200) VALUE SPACES.                    
       01  WS-PORTA-CICS            PIC X(10)  VALUE SPACES.                    
       01  WS-PORTA-AWS             PIC X(10)  VALUE SPACES.                    
       01  WS-EYEBROW               PIC X(80)  VALUE SPACES.                    
                                                                                
      *-------------------------------------------------------------*           
      * CAMPOS DE COR / FLAG DERIVADOS PARA O HTML                  *           
      *-------------------------------------------------------------*           
       01  WS-TITULO-COR            PIC X(07)  VALUE '#15803d'.                 
       01  WS-CICS-COR              PIC X(07)  VALUE '#15803d'.                 
       01  WS-AWS-COR               PIC X(07)  VALUE '#15803d'.                 
       01  WS-EXIBE-PORTAS          PIC X(03)  VALUE 'NAO'.                     
           88  EXIBE-PORTAS         VALUE 'SIM'.                                
       01  WS-EXIBE-MENSAGEM        PIC X(03)  VALUE 'SIM'.                     
           88  EXIBE-MENSAGEM       VALUE 'SIM'.                                
       01  WS-SIMULACAO-TXT         PIC X(03)  VALUE 'Nao'.                     
                                                                                
      *-------------------------------------------------------------*           
      * BUFFER DE SAIDA DO HTML                                     *           
      *-------------------------------------------------------------*           
       01  WS-HTML-COMPLETO         PIC X(9000) VALUE SPACES.                   
       01  WS-POS                   PIC 9(05) COMP VALUE 1.                     
                                                                                
      *-------------------------------------------------------------*           
      * VALORES DEFAULT DO EMAIL                                    *           
      *-------------------------------------------------------------*           
       01  WS-DATA-HORA             PIC X(25) VALUE                             
           '18/05/2026  14:32:07'.                                              
       01  WS-ORIGEM                PIC X(30) VALUE                             
           'AUTDB-PROD-CICS01'.                                                 
       01  WS-ID-PROC               PIC X(30) VALUE                             
           'CTG20260518143207001'.                                              
                                                                                
      *=============================================================*           
       PROCEDURE DIVISION.                                                      
      *=============================================================*           
                                                                                
      *-------------------------------------------------------------*           
      * Rotina principal: orquestra carga, estilos e montagem HTML  *           
      *-------------------------------------------------------------*           
       RTEMAIL-PRINCIPAL               SECTION.                                 
                                                                                
           PERFORM RTEMAIL-CARGA-CAMPOS.                                        
           PERFORM RTEMAIL-DEFINE-ESTILOS.                                      
           PERFORM RTEMAIL-MONTA-HTML.                                          
           DISPLAY WS-HTML-COMPLETO.                                            
           STOP RUN.                                                            
                                                                                
       RTEMAIL-PRINCIPALX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * Dispatcher de carga por LTRANS-COD                          *           
      *-------------------------------------------------------------*           
       RTEMAIL-CARGA-CAMPOS            SECTION.                                 
                                                                                
           MOVE 'NAO'  TO WS-SUCCESS.                                           
           MOVE SPACES TO WS-TITULO                                             
                          WS-MENSAGEM                                           
                          WS-PORTA-CICS                                         
                          WS-PORTA-AWS                                          
                          WS-EYEBROW.                                           
                                                                                
           EVALUATE LTRANS-COD                                                  
              WHEN 'CTA'   PERFORM RTEMAIL-CARGA-CTA                            
              WHEN 'CTB'   PERFORM RTEMAIL-CARGA-CTB                            
              WHEN 'CTC'   PERFORM RTEMAIL-CARGA-CTC                            
              WHEN 'CTD'   PERFORM RTEMAIL-CARGA-CTD                            
              WHEN 'CTE'   PERFORM RTEMAIL-CARGA-CTE                            
              WHEN 'CTF'   PERFORM RTEMAIL-CARGA-CTF                            
              WHEN 'CTG'   PERFORM RTEMAIL-CARGA-CTG                            
              WHEN OTHER                                                        
                 DISPLAY 'NOTIEMAIL: LTRANS-COD INVALIDO = '                    
                         LTRANS-COD                                             
           END-EVALUATE.                                                        
                                                                                
       RTEMAIL-CARGA-CAMPOSX.                                                   
                                                                                
      *-------------------------------------------------------------*           
      * CTA - Ativacao de contingencia                              *           
      *-------------------------------------------------------------*           
       RTEMAIL-CARGA-CTA               SECTION.                                 
                                                                                
           MOVE 'AUTORIZADOR DEBITO  |  ATIVACAO DE CONTINGENCIA'               
             TO WS-EYEBROW.                                                     
                                                                                
           IF WCTN-MIP = 'J2'                                                   
              PERFORM RTEMAIL-CTA-J2                                            
           ELSE                                                                 
              PERFORM RTEMAIL-CTA-NAO-J2                                        
           END-IF.                                                              
                                                                                
       RTEMAIL-CARGA-CTAX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTA / MIP J2 - fluxo de 8 interacoes                        *           
      *-------------------------------------------------------------*           
       RTEMAIL-CTA-J2                  SECTION.                                 
                                                                                
           IF WCTN-INTERACAO   = 08                                             
              AND WCTN-CODRET-CICS = '00'                                       
              AND WCTN-CODRET-AWS  = '00'                                       
              MOVE 'SIM' TO WS-SUCCESS                                          
              MOVE 'Contingencia ativada com sucesso !'                         
                TO WS-TITULO                                                    
              MOVE 'Ativa'   TO WS-PORTA-CICS                                   
              MOVE 'Inativa' TO WS-PORTA-AWS                                    
           ELSE                                                                 
              MOVE 'Contingencia nao ativada - Falha na execucao !'             
                TO WS-TITULO                                                    
              PERFORM RTEMAIL-CTA-J2-ERROS                                      
           END-IF.                                                              
                                                                                
       RTEMAIL-CTA-J2X.                                                         
                                                                                
      *-------------------------------------------------------------*           
      * CTA / J2 - dispatch de erros por interacao                  *           
      *-------------------------------------------------------------*           
       RTEMAIL-CTA-J2-ERROS            SECTION.                                 
                                                                                
           EVALUATE WCTN-INTERACAO                                              
              WHEN 1                                                            
                 MOVE 'CTA-1 - Falha ao enviar Sign-on para o CICS ou TI        
      -    'MEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.           
                 MOVE 'Inativa' TO WS-PORTA-CICS                                
                 MOVE 'Ativa'   TO WS-PORTA-AWS                                 
              WHEN 2                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTA-2 - Sign-on retornado do CICS com '                 
                       'erro - DE39 = '                                         
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                 ELSE                                                           
                    MOVE 'CTA-2 - Nao foi possivel enviar a Ativacao de         
      -    'sessao para a CICS. Consulte o log para mais detalhe                
      -    's' TO WS-MENSAGEM.                                                  
                 END-IF                                                         
                 MOVE 'Inativa' TO WS-PORTA-CICS                                
                 MOVE 'Ativa'   TO WS-PORTA-AWS                                 
              WHEN 3                                                            
                 MOVE 'CTA-3 - Falha ao enviar a Ativacao de sessao para        
      -    ' o CICS ou TIMEOUT. Consulte o log para mais detalhe                
      -    's' TO WS-MENSAGEM.                                                  
                 MOVE 'Inativa' TO WS-PORTA-CICS                                
                 MOVE 'Ativa'   TO WS-PORTA-AWS                                 
              WHEN 4                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTA-4 - Ativacao de sessao retornada do '               
                       'CICS com erro. DE39 = '                                 
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                    MOVE 'Inativa' TO WS-PORTA-CICS                             
                    MOVE 'Ativa'   TO WS-PORTA-AWS                              
                 ELSE                                                           
                    MOVE 'CTA-4 - Nao foi possivel enviar a Solicitacao         
      -    'de troca de chaves para a CICS. Consulte o log para mais det        
      -    'alhes' TO WS-MENSAGEM.                                              
                    MOVE 'Ativa' TO WS-PORTA-CICS                               
                    MOVE 'Ativa' TO WS-PORTA-AWS                                
                 END-IF                                                         
              WHEN 5                                                            
                 MOVE 'CTA-5 - Falha ao enviar a Solicitacao de troca de        
      -    ' chaves para o CICS ou TIMEOUT. Consulte o log para mais det        
      -    'alhes' TO WS-MENSAGEM.                                              
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
              WHEN 6                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTA-6 - Solicitacao de troca de chaves '                
                       'retornada do CICS com erro. DE39 = '                    
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                 ELSE                                                           
                    MOVE 'CTA-6 - Nao foi possivel enviar Sign-off para         
      -    'a AWS. Consulte o log para mais detalhes' TO WS-MENSAGEM.           
                 END-IF                                                         
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
              WHEN 7                                                            
                 MOVE 'CTA-7 - Falha ao enviar Sign-off para a AWS ou TI        
      -    'MEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.           
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
              WHEN 8                                                            
                 STRING                                                         
                    'CTA-8 - Solicitacao de Sign-off retornada '                
                    'da AWS com erro. DE39 = '                                  
                    WCTN-CODRET-AWS                                             
                                       DELIMITED BY SIZE                        
                    INTO WS-MENSAGEM                                            
                 END-STRING                                                     
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
           END-EVALUATE.                                                        
                                                                                
       RTEMAIL-CTA-J2-ERROSX.                                                   
                                                                                
      *-------------------------------------------------------------*           
      * CTA / MIP <> J2 - fluxo de 6 interacoes                     *           
      *-------------------------------------------------------------*           
       RTEMAIL-CTA-NAO-J2              SECTION.                                 
                                                                                
           IF WCTN-INTERACAO   = 06                                             
              AND WCTN-CODRET-CICS = '00'                                       
              AND WCTN-CODRET-AWS  = '00'                                       
              MOVE 'SIM' TO WS-SUCCESS                                          
              MOVE 'Contingencia ativada com sucesso !'                         
                TO WS-TITULO                                                    
              MOVE 'Ativa'   TO WS-PORTA-CICS                                   
              MOVE 'Inativa' TO WS-PORTA-AWS                                    
           ELSE                                                                 
              MOVE 'Contingencia nao ativada - Falha na execucao !'             
                TO WS-TITULO                                                    
              PERFORM RTEMAIL-CTA-NAO-J2-ERROS                                  
           END-IF.                                                              
                                                                                
       RTEMAIL-CTA-NAO-J2X.                                                     
                                                                                
      *-------------------------------------------------------------*           
      * CTA / NAO-J2 - dispatch de erros por interacao              *           
      *-------------------------------------------------------------*           
       RTEMAIL-CTA-NAO-J2-ERROS        SECTION.                                 
                                                                                
           EVALUATE WCTN-INTERACAO                                              
              WHEN 1                                                            
                 MOVE 'CTA-1 - Falha ao enviar Sign-on para o CICS ou TI        
      -    'MEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.           
                 MOVE 'Inativa' TO WS-PORTA-CICS                                
                 MOVE 'Ativa'   TO WS-PORTA-AWS                                 
              WHEN 2                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTA-2 - Sign-on retornado do CICS com '                 
                       'erro - DE39 = '                                         
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                 ELSE                                                           
                    MOVE 'CTA-2 - Nao foi possivel enviar Ativacao de se        
      -    'ssao para a CICS. Consulte o log para mais detalhe                  
      -    's' TO WS-MENSAGEM.                                                  
                 END-IF                                                         
                 MOVE 'Inativa' TO WS-PORTA-CICS                                
                 MOVE 'Ativa'   TO WS-PORTA-AWS                                 
              WHEN 3                                                            
                 MOVE 'CTA-3 - Falha ao enviar Ativacao de sessao para o        
      -    ' CICS ou TIMEOUT. Consulte o log para mais detalhe                  
      -    's' TO WS-MENSAGEM.                                                  
                 MOVE 'Inativa' TO WS-PORTA-CICS                                
                 MOVE 'Ativa'   TO WS-PORTA-AWS                                 
              WHEN 4                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTA-4 - Ativacao de sessao retornada do '               
                       'CICS com erro. DE39 = '                                 
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                    MOVE 'Inativa' TO WS-PORTA-CICS                             
                    MOVE 'Ativa'   TO WS-PORTA-AWS                              
                 ELSE                                                           
                    MOVE 'CTA-4 - Nao foi possivel enviar Sign-off para         
      -    'a AWS. Consulte o log para mais detalhes' TO WS-MENSAGEM.           
                    MOVE 'Ativa' TO WS-PORTA-CICS                               
                    MOVE 'Ativa' TO WS-PORTA-AWS                                
                 END-IF                                                         
              WHEN 5                                                            
                 MOVE 'CTA-5 - Falha ao enviar o Sign-off para a AWS, ou        
      -    ' TIMEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.        
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
              WHEN 6                                                            
                 STRING                                                         
                    'CTA-8 - Solicitacao de Sign-off retornada '                
                    'da AWS com erro. DE39 = '                                  
                    WCTN-CODRET-AWS                                             
                                       DELIMITED BY SIZE                        
                    INTO WS-MENSAGEM                                            
                 END-STRING                                                     
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
           END-EVALUATE.                                                        
                                                                                
       RTEMAIL-CTA-NAO-J2-ERROSX.                                               
                                                                                
      *-------------------------------------------------------------*           
      * CTB - Desativacao de contingencia                           *           
      *-------------------------------------------------------------*           
       RTEMAIL-CARGA-CTB               SECTION.                                 
                                                                                
           MOVE 'AUTORIZADOR DEBITO  |  DESATIVACAO DE CONTINGENCI              
      -    'A' TO WS-EYEBROW.                                                   
                                                                                
           IF WCTN-INTERACAO   = 06                                             
              AND WCTN-CODRET-CICS = '00'                                       
              AND WCTN-CODRET-AWS  = '00'                                       
              MOVE 'SIM' TO WS-SUCCESS                                          
              MOVE 'Contingencia desativada com sucesso !'                      
                TO WS-TITULO                                                    
              MOVE 'Inativa' TO WS-PORTA-CICS                                   
              MOVE 'Ativa'   TO WS-PORTA-AWS                                    
           ELSE                                                                 
              MOVE 'Contingencia nao desativada - Falha na execucao             
      -    '!' TO WS-TITULO.                                                    
              PERFORM RTEMAIL-CTB-ERROS                                         
           END-IF.                                                              
                                                                                
       RTEMAIL-CARGA-CTBX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTB - dispatch de erros por interacao                       *           
      *-------------------------------------------------------------*           
       RTEMAIL-CTB-ERROS               SECTION.                                 
                                                                                
           EVALUATE WCTN-INTERACAO                                              
              WHEN 1                                                            
                 MOVE 'CTB-1 - Falha ao enviar Sign-on para a AWS ou TIM        
      -    'EOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.            
                 MOVE 'Ativa'   TO WS-PORTA-CICS                                
                 MOVE 'Inativa' TO WS-PORTA-AWS                                 
              WHEN 2                                                            
                 IF WCTN-CODRET-AWS NOT = '00'                                  
                    AND WCTN-CODRET-AWS NOT = '  '                              
                    STRING                                                      
                       'CTB-2 - Sign-on retornado da AWS com '                  
                       'erro. DE39 = '                                          
                       WCTN-CODRET-AWS                                          
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                 ELSE                                                           
                    MOVE 'CTB-2 - Nao foi possivel enviar o Sign-off par        
      -    'a o CICS. Consulte o log para mais detalhes' TO WS-MENSAGEM.        
                 END-IF                                                         
                 MOVE 'Ativa'   TO WS-PORTA-CICS                                
                 MOVE 'Inativa' TO WS-PORTA-AWS                                 
              WHEN 3                                                            
                 MOVE 'CTB-3 - Falha ao enviar o Sign-Off para o CICS ou        
      -    ' TIMEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.        
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
              WHEN 4                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTB-4 - Sign-Off retornado do CICS com '                
                       'erro. DE39 = '                                          
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                 ELSE                                                           
                    MOVE 'CTB-4 - Nao foi possivel enviar a Desativacao         
      -    'de sessao para o CICS. Consulte o log para mais detalhe             
      -    's' TO WS-MENSAGEM.                                                  
                 END-IF                                                         
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
              WHEN 5                                                            
                 MOVE 'CTB-5 - Falha ao enviar a Desativacao de Sessao p        
      -    'ara o CICS, ou TIMEOUT. Consulte o log para mais detalhe            
      -    's' TO WS-MENSAGEM.                                                  
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
              WHEN 6                                                            
                 STRING                                                         
                    'CTB-6 - Desativacao de sessao retornada do '               
                    'CICS com erro. DE39 = '                                    
                    WCTN-CODRET-CICS                                            
                                       DELIMITED BY SIZE                        
                    INTO WS-MENSAGEM                                            
                 END-STRING                                                     
                 MOVE 'Ativa' TO WS-PORTA-CICS                                  
                 MOVE 'Ativa' TO WS-PORTA-AWS                                   
           END-EVALUATE.                                                        
                                                                                
       RTEMAIL-CTB-ERROSX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTC - Sign-On na AWS                                        *           
      *-------------------------------------------------------------*           
       RTEMAIL-CARGA-CTC               SECTION.                                 
                                                                                
           MOVE 'AUTORIZADOR DEBITO  |  SIGN-ON AWS'                            
             TO WS-EYEBROW.                                                     
                                                                                
           IF WCTN-INTERACAO  = 02                                              
              AND WCTN-CODRET-AWS = '00'                                        
              MOVE 'SIM' TO WS-SUCCESS                                          
              MOVE 'Sign-On na AWS processado com sucesso !'                    
                TO WS-TITULO                                                    
           ELSE                                                                 
              MOVE 'Falha no processamento do Sign-On na AWS !'                 
                TO WS-TITULO                                                    
              EVALUATE WCTN-INTERACAO                                           
                 WHEN 1                                                         
                    MOVE 'CTC-1 - Falha ao enviar Sign-on para a AWS ou         
      -    'TIMEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.         
                 WHEN 2                                                         
                    STRING                                                      
                       'CTC-2 - Sign-on retornado da AWS com '                  
                       'erro. DE39 = '                                          
                       WCTN-CODRET-AWS                                          
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
              END-EVALUATE                                                      
           END-IF.                                                              
                                                                                
       RTEMAIL-CARGA-CTCX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTD - Sign-Off na AWS                                       *           
      *-------------------------------------------------------------*           
       RTEMAIL-CARGA-CTD               SECTION.                                 
                                                                                
           MOVE 'AUTORIZADOR DEBITO  |  SIGN-OFF AWS'                           
             TO WS-EYEBROW.                                                     
                                                                                
           IF WCTN-INTERACAO  = 02                                              
              AND WCTN-CODRET-AWS = '00'                                        
              MOVE 'SIM' TO WS-SUCCESS                                          
              MOVE 'Sign-Off na AWS processado com sucesso !'                   
                TO WS-TITULO                                                    
           ELSE                                                                 
              MOVE 'Falha no processamento do Sign-Off na AWS !'                
                TO WS-TITULO                                                    
              EVALUATE WCTN-INTERACAO                                           
                 WHEN 1                                                         
                    MOVE 'CTD-1 - Falha ao enviar Sign-Off para a AWS ou        
      -    ' TIMEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.        
                 WHEN 2                                                         
                    STRING                                                      
                       'CTD-2 - Sign-Off retornado da AWS com '                 
                       'erro. DE39 = '                                          
                       WCTN-CODRET-AWS                                          
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
              END-EVALUATE                                                      
           END-IF.                                                              
                                                                                
       RTEMAIL-CARGA-CTDX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTE - Sign-On no CICS                                       *           
      *-------------------------------------------------------------*           
       RTEMAIL-CARGA-CTE               SECTION.                                 
                                                                                
           MOVE 'AUTORIZADOR DEBITO  |  SIGN-ON CICS'                           
             TO WS-EYEBROW.                                                     
                                                                                
           IF WCTN-INTERACAO   = 06                                             
              AND WCTN-CODRET-CICS = '00'                                       
              MOVE 'SIM' TO WS-SUCCESS                                          
              MOVE 'Sign-On no CICS processado com sucesso !'                   
                TO WS-TITULO                                                    
           ELSE                                                                 
              MOVE 'Falha no processamento do Sign-On no CICS !'                
                TO WS-TITULO                                                    
              PERFORM RTEMAIL-CTE-ERROS                                         
           END-IF.                                                              
                                                                                
       RTEMAIL-CARGA-CTEX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTE - dispatch de erros por interacao                       *           
      *-------------------------------------------------------------*           
       RTEMAIL-CTE-ERROS               SECTION.                                 
                                                                                
           EVALUATE WCTN-INTERACAO                                              
              WHEN 1                                                            
                 MOVE 'CTE-1 - Falha ao enviar Sign-on para o CICS ou TI        
      -    'MEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.           
              WHEN 2                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTE-2 - Sign-on retornado do CICS com '                 
                       'erro - DE39 = '                                         
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                 ELSE                                                           
                    MOVE 'CTE-2 - Nao foi possivel enviar a Ativacao de         
      -    'sessao para a CICS. Consulte o log para mais detalhe                
      -    's' TO WS-MENSAGEM.                                                  
                 END-IF                                                         
              WHEN 3                                                            
                 MOVE 'CTE-3 - Falha ao enviar a Ativacao de sessao para        
      -    ' o CICS ou TIMEOUT. Consulte o log para mais detalhe                
      -    's' TO WS-MENSAGEM.                                                  
              WHEN 4                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTE-4 - Ativacao de sessao retornada do '               
                       'CICS com erro. DE39 = '                                 
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                 ELSE                                                           
                    MOVE 'CTE-4 - Nao foi possivel enviar a Solicitacao         
      -    'de troca de chaves para a CICS. Consulte o log para mais det        
      -    'alhes' TO WS-MENSAGEM.                                              
                 END-IF                                                         
              WHEN 5                                                            
                 MOVE 'CTE-5 - Falha ao enviar a Solicitacao de troca de        
      -    ' chaves para o CICS ou TIMEOUT. Consulte o log para mais det        
      -    'alhes' TO WS-MENSAGEM.                                              
              WHEN 6                                                            
                 STRING                                                         
                    'CTE-6 - Solicitacao de troca de chaves '                   
                    'retornada do CICS com erro. DE39 = '                       
                    WCTN-CODRET-CICS                                            
                                       DELIMITED BY SIZE                        
                    INTO WS-MENSAGEM                                            
                 END-STRING                                                     
           END-EVALUATE.                                                        
                                                                                
       RTEMAIL-CTE-ERROSX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTF - Sign-Off no CICS                                      *           
      *-------------------------------------------------------------*           
       RTEMAIL-CARGA-CTF               SECTION.                                 
                                                                                
           MOVE 'AUTORIZADOR DEBITO  |  SIGN-OFF CICS'                          
             TO WS-EYEBROW.                                                     
                                                                                
           IF WCTN-INTERACAO   = 04                                             
              AND WCTN-CODRET-CICS = '00'                                       
              MOVE 'SIM' TO WS-SUCCESS                                          
              MOVE 'Sign-Off no CICS processado com sucesso !'                  
                TO WS-TITULO                                                    
           ELSE                                                                 
              MOVE 'Falha no processamento do Sign-Off no CICS !'               
                TO WS-TITULO                                                    
              PERFORM RTEMAIL-CTF-ERROS                                         
           END-IF.                                                              
                                                                                
       RTEMAIL-CARGA-CTFX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTF - dispatch de erros por interacao                       *           
      *-------------------------------------------------------------*           
       RTEMAIL-CTF-ERROS               SECTION.                                 
                                                                                
           EVALUATE WCTN-INTERACAO                                              
              WHEN 1                                                            
                 MOVE 'CTF-1 - Falha ao enviar Sign-off para o CICS ou T        
      -    'IMEOUT. Consulte o log para mais detalhes' TO WS-MENSAGEM.          
              WHEN 2                                                            
                 IF WCTN-CODRET-CICS NOT = '00'                                 
                    AND WCTN-CODRET-CICS NOT = '  '                             
                    STRING                                                      
                       'CTF-2 - Sign-off retornado do CICS com '                
                       'erro - DE39 = '                                         
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
                 ELSE                                                           
                    MOVE 'CTF-2 - Nao foi possivel enviar a Desativacao         
      -    'de sessao para a CICS. Consulte o log para mais detalhe             
      -    's' TO WS-MENSAGEM.                                                  
                 END-IF                                                         
              WHEN 3                                                            
                 MOVE 'CTF-3 - Falha ao enviar a Desativacao de sessao p        
      -    'ara o CICS ou TIMEOUT. Consulte o log para mais detalhe             
      -    's' TO WS-MENSAGEM.                                                  
              WHEN 4                                                            
                 STRING                                                         
                    'CTF-4 - Desativacao de sessao retornada do '               
                    'CICS com erro. DE39 = '                                    
                    WCTN-CODRET-CICS                                            
                                       DELIMITED BY SIZE                        
                    INTO WS-MENSAGEM                                            
                 END-STRING                                                     
           END-EVALUATE.                                                        
                                                                                
       RTEMAIL-CTF-ERROSX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * CTG - Solicitacao de Troca de chaves no CICS                *           
      *-------------------------------------------------------------*           
       RTEMAIL-CARGA-CTG               SECTION.                                 
                                                                                
           MOVE 'AUTORIZADOR DEBITO  |  TROCA DE CHAVES CICS'                   
             TO WS-EYEBROW.                                                     
                                                                                
           IF WCTN-INTERACAO   = 02                                             
              AND WCTN-CODRET-CICS = '00'                                       
              MOVE 'SIM' TO WS-SUCCESS                                          
              MOVE 'Solicitacao de Troca de chaves no CICS processado co        
      -    'm sucesso !' TO WS-TITULO.                                          
           ELSE                                                                 
              MOVE 'Falha no processamento da Solicitacao de troca de ch        
      -    'aves no CICS !' TO WS-TITULO.                                       
              EVALUATE WCTN-INTERACAO                                           
                 WHEN 1                                                         
                    MOVE 'CTG-1 - Falha ao enviar Solicitacao de troca d        
      -    'e chaves no CICS ou TIMEOUT. Consulte o log para mais detalh        
      -    'es' TO WS-MENSAGEM.                                                 
                 WHEN 2                                                         
                    STRING                                                      
                       'CTG-2 - Solicitacao de troca de chaves '                
                       'retornada do CICS com erro. DE39 = '                    
                       WCTN-CODRET-CICS                                         
                                       DELIMITED BY SIZE                        
                       INTO WS-MENSAGEM                                         
                    END-STRING                                                  
              END-EVALUATE                                                      
           END-IF.                                                              
                                                                                
       RTEMAIL-CARGA-CTGX.                                                      
                                                                                
      *-------------------------------------------------------------*           
      * Define cores e flag de exibicao de portas                   *           
      *-------------------------------------------------------------*           
       RTEMAIL-DEFINE-ESTILOS          SECTION.                                 
                                                                                
           IF WS-SUCCESS = 'SIM'                                                
              MOVE '#15803d' TO WS-TITULO-COR                                   
           ELSE                                                                 
              MOVE '#b91c1c' TO WS-TITULO-COR                                   
           END-IF.                                                              
                                                                                
           IF WS-PORTA-CICS = 'Ativa'                                           
              MOVE '#15803d' TO WS-CICS-COR                                     
           ELSE                                                                 
              MOVE '#b91c1c' TO WS-CICS-COR                                     
           END-IF.                                                              
                                                                                
           IF WS-PORTA-AWS = 'Ativa'                                            
              MOVE '#15803d' TO WS-AWS-COR                                      
           ELSE                                                                 
              MOVE '#b91c1c' TO WS-AWS-COR                                      
           END-IF.                                                              
                                                                                
           IF LTRANS-COD = 'CTA' OR 'CTB'                                       
              MOVE 'SIM' TO WS-EXIBE-PORTAS                                     
           ELSE                                                                 
              MOVE 'NAO' TO WS-EXIBE-PORTAS                                     
           END-IF.                                                              
                                                                                
           IF WCTN-SIMULACAO = 'SIM'                                            
              MOVE 'Sim' TO WS-SIMULACAO-TXT                                    
           ELSE                                                                 
              MOVE 'Nao' TO WS-SIMULACAO-TXT                                    
           END-IF.                                                              
                                                                                
      *--- Card de mensagem nao aparece no caminho feliz das                    
      *    transacoes que nao tem WS-MENSAGEM definida (CTC..CTG)               
           IF WS-SUCCESS = 'SIM'                                                
              AND LTRANS-COD NOT = 'CTA'                                        
              AND LTRANS-COD NOT = 'CTB'                                        
              MOVE 'NAO' TO WS-EXIBE-MENSAGEM                                   
           ELSE                                                                 
              MOVE 'SIM' TO WS-EXIBE-MENSAGEM                                   
           END-IF.                                                              
                                                                                
       RTEMAIL-DEFINE-ESTILOSX.                                                 
                                                                                
      *-------------------------------------------------------------*           
      * Monta HTML completo do email                                *           
      *-------------------------------------------------------------*           
       RTEMAIL-MONTA-HTML              SECTION.                                 
                                                                                
           MOVE SPACES TO WS-HTML-COMPLETO.                                     
           MOVE 1      TO WS-POS.                                               
                                                                                
           PERFORM RTEMAIL-HTML-ABERTURA.                                       
           PERFORM RTEMAIL-HTML-HEADER.                                         
           PERFORM RTEMAIL-HTML-CORPO-METADADOS.                                
           IF EXIBE-PORTAS                                                      
              PERFORM RTEMAIL-HTML-LINHAS-PORTAS                                
           END-IF.                                                              
           PERFORM RTEMAIL-HTML-LINHA-ID.                                       
           IF EXIBE-MENSAGEM                                                    
              PERFORM RTEMAIL-HTML-CARD-MENSAGEM                                
           END-IF.                                                              
           PERFORM RTEMAIL-HTML-FOOTER.                                         
           PERFORM RTEMAIL-HTML-FECHAMENTO.                                     
                                                                                
       RTEMAIL-MONTA-HTMLX.                                                     
                                                                                
      *-------------------------------------------------------------*           
      * HTML: abertura <html><body> e tabela externa                *           
      *-------------------------------------------------------------*           
       RTEMAIL-HTML-ABERTURA           SECTION.                                 
                                                                                
           STRING                                                               
             '<html><body style="margin:0;padding:0;'                           
             'font-family:''Segoe UI'',Arial,'                                  
             'Helvetica,sans-serif;">'                                          
             '<table width="100%" cellpadding="0" '                             
             'cellspacing="0" border="0">'                                      
             '<tr><td align="center" '                                          
             'style="padding:24px 12px;">'                                      
             '<table width="600" cellpadding="0" '                              
             'cellspacing="0" border="0" '                                      
             'style="border:1px solid #d9dde2;'                                 
             'max-width:600px;">'                                               
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-HTML-ABERTURAX.                                                  
                                                                                
      *-------------------------------------------------------------*           
      * HTML: header (barra lateral colorida + eyebrow + titulo)    *           
      *-------------------------------------------------------------*           
       RTEMAIL-HTML-HEADER             SECTION.                                 
                                                                                
      *--- abertura do header com tabela interna 2 colunas ---                  
           STRING                                                               
             '<tr><td style="padding:0;">'                                      
             '<table width="100%" cellpadding="0" '                             
             'cellspacing="0" border="0"><tr>'                                  
             '<td width="6" '                                                   
             'style="background-color:'                                         
                                DELIMITED BY SIZE                               
             WS-TITULO-COR      DELIMITED BY '  '                               
             ';font-size:0;line-height:0;">&nbsp;</td>'                         
                                DELIMITED BY SIZE                               
             '<td style="padding:24px 32px;">'                                  
             '<table width="100%" cellpadding="0" '                             
             'cellspacing="0" border="0">'                                      
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
      *--- eyebrow ---                                                          
           STRING                                                               
             '<tr><td style="font-family:'                                      
             '''Segoe UI'',Arial,sans-serif;'                                   
             'font-size:11px;color:#6b7280;'                                    
             'letter-spacing:1.5px;'                                            
             'text-transform:uppercase;font-weight:700;'                        
             'padding-bottom:8px;">'                                            
                                DELIMITED BY SIZE                               
             WS-EYEBROW         DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
      *--- titulo principal (cor varia conforme sucesso/falha) ---              
           STRING                                                               
             '<tr><td style="font-family:'                                      
             '''Segoe UI'',Arial,sans-serif;'                                   
             'font-size:24px;color:'                                            
                                DELIMITED BY SIZE                               
             WS-TITULO-COR      DELIMITED BY '  '                               
             ';font-weight:700;line-height:1.2;">'                              
                                DELIMITED BY SIZE                               
             WS-TITULO          DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             '</table></td></tr></table></td></tr>'                             
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
      *--- linha divisoria (cor acompanha) ---                                  
           STRING                                                               
             '<tr><td style="border-top:2px solid '                             
                                DELIMITED BY SIZE                               
             WS-TITULO-COR      DELIMITED BY '  '                               
             ';font-size:0;line-height:0;">&nbsp;</td></tr>'                    
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-HTML-HEADERX.                                                    
                                                                                
      *-------------------------------------------------------------*           
      * HTML: bloco de metadados comum (data/hora, origem)          *           
      *-------------------------------------------------------------*           
       RTEMAIL-HTML-CORPO-METADADOS    SECTION.                                 
                                                                                
      *--- abertura da celula principal e tabela interna ---                    
           STRING                                                               
             '<tr><td style="padding:28px 32px 8px 32px;">'                     
             '<table width="100%" cellpadding="0" '                             
             'cellspacing="0" border="0" '                                      
             'style="font-family:''Segoe UI'','                                 
             'Arial,sans-serif;">'                                              
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
      *--- linha MIP ---                                                        
           STRING                                                               
             '<tr>'                                                             
             '<td width="160" style="padding:8px 0;'                            
             'font-size:12px;color:#6b7280;'                                    
             'text-transform:uppercase;letter-spacing:'                         
             '0.5px;vertical-align:top;">MIP</td>'                              
             '<td style="padding:8px 0;font-size:14px;'                         
             'color:#1f2937;font-family:Consolas,'                              
             '''Courier New'',monospace;font-weight:600;'                       
             'vertical-align:top;">'                                            
                                DELIMITED BY SIZE                               
             WCTN-MIP           DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
           PERFORM RTEMAIL-DIVISOR.                                             
                                                                                
      *--- linha data/hora ---                                                  
           STRING                                                               
             '<tr>'                                                             
             '<td style="padding:8px 0;'                                        
             'font-size:12px;color:#6b7280;'                                    
             'text-transform:uppercase;letter-spacing:'                         
             '0.5px;vertical-align:top;">Data / Hora</td>'                      
             '<td style="padding:8px 0;font-size:14px;'                         
             'color:#1f2937;vertical-align:top;">'                              
                                DELIMITED BY SIZE                               
             WS-DATA-HORA       DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
           PERFORM RTEMAIL-DIVISOR.                                             
                                                                                
      *--- linha origem ---                                                     
           STRING                                                               
             '<tr>'                                                             
             '<td style="padding:8px 0;font-size:12px;'                         
             'color:#6b7280;text-transform:uppercase;'                          
             'letter-spacing:0.5px;vertical-align:top;">'                       
             'Origem</td>'                                                      
             '<td style="padding:8px 0;font-size:14px;'                         
             'color:#1f2937;vertical-align:top;">'                              
                                DELIMITED BY SIZE                               
             WS-ORIGEM          DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
           PERFORM RTEMAIL-DIVISOR.                                             
                                                                                
      *--- linha simulacao ---                                                  
           STRING                                                               
             '<tr>'                                                             
             '<td style="padding:8px 0;font-size:12px;'                         
             'color:#6b7280;text-transform:uppercase;'                          
             'letter-spacing:0.5px;vertical-align:top;">'                       
             'Simulacao</td>'                                                   
             '<td style="padding:8px 0;font-size:14px;'                         
             'color:#1f2937;font-weight:600;'                                   
             'vertical-align:top;">'                                            
                                DELIMITED BY SIZE                               
             WS-SIMULACAO-TXT   DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-HTML-CORPO-METADADOSX.                                           
                                                                                
      *-------------------------------------------------------------*           
      * HTML: linhas de status das portas (so CTA e CTB)            *           
      *-------------------------------------------------------------*           
       RTEMAIL-HTML-LINHAS-PORTAS      SECTION.                                 
                                                                                
           PERFORM RTEMAIL-DIVISOR.                                             
                                                                                
      *--- linha porta 6005 CICS ---                                            
           STRING                                                               
             '<tr>'                                                             
             '<td style="padding:10px 0;font-size:12px;'                        
             'color:#6b7280;text-transform:uppercase;'                          
             'letter-spacing:0.5px;vertical-align:top;">'                       
             'Porta 6005 &middot; CICS</td>'                                    
             '<td style="padding:10px 0;font-size:14px;'                        
             'color:'                                                           
                                DELIMITED BY SIZE                               
             WS-CICS-COR        DELIMITED BY '  '                               
             ';font-weight:700;vertical-align:top;">'                           
                                DELIMITED BY SIZE                               
             WS-PORTA-CICS      DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
           PERFORM RTEMAIL-DIVISOR.                                             
                                                                                
      *--- linha porta 7005 AWS ---                                             
           STRING                                                               
             '<tr>'                                                             
             '<td style="padding:10px 0;font-size:12px;'                        
             'color:#6b7280;text-transform:uppercase;'                          
             'letter-spacing:0.5px;vertical-align:top;">'                       
             'Porta 7005 &middot; AWS</td>'                                     
             '<td style="padding:10px 0;font-size:14px;'                        
             'color:'                                                           
                                DELIMITED BY SIZE                               
             WS-AWS-COR         DELIMITED BY '  '                               
             ';font-weight:700;vertical-align:top;">'                           
                                DELIMITED BY SIZE                               
             WS-PORTA-AWS       DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-HTML-LINHAS-PORTASX.                                             
                                                                                
      *-------------------------------------------------------------*           
      * HTML: linha de ID e fechamento da tabela de metadados       *           
      *-------------------------------------------------------------*           
       RTEMAIL-HTML-LINHA-ID           SECTION.                                 
                                                                                
           PERFORM RTEMAIL-DIVISOR.                                             
                                                                                
           STRING                                                               
             '<tr>'                                                             
             '<td style="padding:8px 0;font-size:12px;'                         
             'color:#6b7280;text-transform:uppercase;'                          
             'letter-spacing:0.5px;vertical-align:top;">'                       
             'ID</td>'                                                          
             '<td style="padding:8px 0;font-size:13px;'                         
             'color:#4b5563;font-family:Consolas,'                              
             '''Courier New'',monospace;'                                       
             'vertical-align:top;">'                                            
                                DELIMITED BY SIZE                               
             WS-ID-PROC         DELIMITED BY '  '                               
             '</td></tr>'       DELIMITED BY SIZE                               
             '</table></td></tr>'                                               
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-HTML-LINHA-IDX.                                                  
                                                                                
      *-------------------------------------------------------------*           
      * HTML: card de mensagem com barra lateral laranja            *           
      *-------------------------------------------------------------*           
       RTEMAIL-HTML-CARD-MENSAGEM      SECTION.                                 
                                                                                
           STRING                                                               
             '<tr><td style="padding:20px 32px '                                
             '28px 32px;">'                                                     
             '<table width="100%" cellpadding="0" '                             
             'cellspacing="0" border="0"><tr>'                                  
             '<td width="3" '                                                   
             'style="background-color:#FF6B00;'                                 
             'font-size:0;line-height:0;">&nbsp;</td>'                          
             '<td style="padding:4px 0 4px 16px;">'                             
             '<div style="font-family:''Segoe UI'','                            
             'Arial,sans-serif;font-size:11px;'                                 
             'color:#6b7280;text-transform:uppercase;'                          
             'letter-spacing:0.8px;font-weight:700;'                            
             'padding-bottom:6px;">Mensagem</div>'                              
             '<div style="font-family:''Segoe UI'','                            
             'Arial,sans-serif;font-size:14px;'                                 
             'color:#1f2937;line-height:1.6;">'                                 
                                DELIMITED BY SIZE                               
             WS-MENSAGEM        DELIMITED BY '  '                               
             '</div>'           DELIMITED BY SIZE                               
             '</td></tr></table></td></tr>'                                     
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-HTML-CARD-MENSAGEMX.                                             
                                                                                
      *-------------------------------------------------------------*           
      * HTML: footer com borda no topo                              *           
      *-------------------------------------------------------------*           
       RTEMAIL-HTML-FOOTER             SECTION.                                 
                                                                                
           STRING                                                               
             '<tr><td style="padding:16px 32px;'                                
             'border-top:1px solid #eef0f3;'                                    
             'font-family:''Segoe UI'',Arial,sans-serif;'                       
             'font-size:11px;color:#9ca3af;'                                    
             'line-height:1.5;">'                                               
             'Mensagem automatica gerada pelo '                                 
             'Autorizador Debito.<br>'                                          
             'Nao responda este e-mail.'                                        
             '</td></tr>'                                                       
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-HTML-FOOTERX.                                                    
                                                                                
      *-------------------------------------------------------------*           
      * HTML: fechamento geral </table></body></html>               *           
      *-------------------------------------------------------------*           
       RTEMAIL-HTML-FECHAMENTO         SECTION.                                 
                                                                                
           STRING                                                               
             '</table></td></tr></table>'                                       
             '</body></html>'                                                   
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-HTML-FECHAMENTOX.                                                
                                                                                
      *-------------------------------------------------------------*           
      * HTML: divisor de linha (reutilizado entre as linhas)        *           
      *-------------------------------------------------------------*           
       RTEMAIL-DIVISOR                 SECTION.                                 
                                                                                
           STRING                                                               
             '<tr><td colspan="2" '                                             
             'style="border-bottom:1px solid #eef0f3;'                          
             'font-size:0;line-height:0;">&nbsp;</td></tr>'                     
                                DELIMITED BY SIZE                               
             INTO WS-HTML-COMPLETO                                              
             WITH POINTER WS-POS                                                
           END-STRING.                                                          
                                                                                
       RTEMAIL-DIVISORX.                                                        
                                                                                
