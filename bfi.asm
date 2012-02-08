global main

section .data
    i          dd   0     ;mi servirà per salvare lo stato di edi
    lenfile    dd   0
    addr       dd   0
    erroropen  db   "Error to open file"
    usage      db   "Usage: <./name> <file.bf>\n"
        
section .bss           
    buff    resb  3000     ;alloco 3000 byte sul seg bss 
    mem     resb  6000     ;alloco 6000 byte sul seg bss
    
section .text
          
main       : 
            pop eax   ;prendo argc dallo stack
            pop esi   ;prendo ProgramName 
            pop ebx   ;infine il filename
            cmp eax,2      
            jl  errorarg ;se argc < 2 jmp errorarg

            mov eax, 5   ;open
            mov ecx, 0 
            mov edx, 0
            int 0x80
            cmp eax,0
            jl  erroropen ;se eax < 0 jmp erroropen

            mov ebx, eax
            mov eax, 3    ;read file
            mov ecx, buff
            mov edx, 3000
            int 0x80
            mov [lenfile],eax
            
            mov eax, 6 ;close file
            int 0x80 

            xor edi, edi ; edi contatore per buff
            xor esi, esi ; esi contatore per mem           
            xor eax, eax ; eax conterrà di volta in volta il byte del file

interpret  :
            mov byte al, [buff+edi]  ;metto in al il byte buff[edi]
            cmp edi, [lenfile]       ;controllo se edi è fuori file
            jg  exit
            inc edi
            
            ;inizio switch-case
            cmp al, '+'
            je  plus
            cmp al, '-'
            je  minus
            cmp al, '>'
            je  major
            cmp al, '<'
            je  lower
            cmp al, '.'
            je  putch
            cmp al, ','
            je  getch
            cmp al, '['
            je  squareop
            cmp al, ']'
            je  squarecl
            jmp interpret  ;default è un commento
            
plus       :                  ;mem[esi]++
            inc byte [mem+esi]
            jmp interpret

minus      :                  ;mem[esi]--
            dec byte [mem+esi]
            jmp interpret

major      :                  ;esi++
            inc  esi       
            jmp interpret

lower      :
            dec  esi          ;esi--
            jmp interpret

putch      :                  ;putchar(mem[esi])
            mov ecx, esi    
            add ecx, mem      ;mem[esi]
            mov eax, 4
            mov ebx, 1
            mov edx, 1
            int 0x80
            jmp interpret

getch      :                  ;mem[esi]=getchar()   
            mov ecx, esi
            add ecx, mem      ;mem[esi]
            mov eax, 3
            mov ebx, 0
            mov edx, 1
            int 0x80
            jmp interpret

squareop   :                     ;while(*ptr){ 
            cmp byte [mem+esi],0 ;se mem(esi) == 0 va avanti fino a ']'
            je  squarecl         
            mov [i], edi         ;else salva edi in i
            jmp interpret        ;interpreta byte nel ciclo

squarecl   :                       ;}
            cmp byte [mem+esi], 0  ;se mem[esi] !=0
            jne editk              ; vai all'istruzione dopo [
            jmp interpret          


editk      :
            mov edi, [i]           ;reimposta in edi [i] così da ricominciare il byte dopo '['
            jmp interpret 
            
errorarg   :                       ;mostra errore ed esce
            mov eax,4
            mov ebx,1
            mov ecx,usage
            mov edx,29
            int 0x80
            
            mov eax,1
            mov ebx,0
            int 0x80

erropen    :                       ;mostra errore ed esce
            mov eax, 4
            mov ebx, 1
            mov ecx, erroropen
            mov edx, 20
            int 0x80
            
            mov eax, 1
            mov ebx, 0
            int 0x80

exit       :                       ;end
            mov eax, 1
            int 0x80
     
