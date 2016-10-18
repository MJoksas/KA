;	9.	Parasykite programa, kuri ivestoje simboliu eiluteje visus tarpu simbolius pakeicia po ju esanciais
;		simboliais ir atspausdina buvusiu tarpu skaiciu.
;		Pvz.: ivedus aeas lfg jli l kj1 asd turi atspausdinti aeasllfgjjlillkkj1aasd(tarpu 5)
;	Atliko: Martynas Joksas

.model small
.stack 100h
	 
.data
	request		db 'Programa ivestoje eiluteje visus tarpo simbolius pakeicia', 0Dh, 0Ah, 'po jais einanciu simbobliu.', 0Dh, 0Ah, 'Iveskite simboliu eilute:', 0Dh, 0Ah, '$'
	result    	db 0Dh, 0Ah, 'Rezultatas:', 0Dh, 0Ah, '$'
	space		db ' (tarpu: ', '$'
	buffer		db 100 ; cia skaitysim eilute

.code
 
start:
	MOV ax, @data                   ; perkelti data i registra ax
	MOV ds, ax                      ; perkelti ax (data) i data segmenta
	 
	; isvesti uzklausa
	MOV ah, 09h
	MOV dx, offset request
	int 21h

	; skaityti eilute
	MOV dx, offset buffer           ; skaityti i buffer offseta 
	MOV ah, 0Ah                     ; eilutes skaitymo subprograma
	INT 21h                         ; dos'o INTeruptas

	; kartoti
	MOV si, offset buffer           ; priskirti source index'ui bufferio koordinates
	INC si                          ; pridedam 1 prie si , nes pirmas kiek simboliu is viso
	MOV bh, [si]                    ; idedam i bh kiek simboliu is viso
	INC si                          ; pereiname prie pacio simbolio
	
	; isvesti rezultato pradzia	
	MOV ah, 09h
	MOV dx, offset result
	INT 21h

	MOV cx, 0001h					; istustinam ciklo skaitliuka				
	
; 1. imsime simboli,
; 2. tikrinsime tarpa,
; 3. jei tarpas, tai padidinsim loop'o registra, 
; 4. einame prie kito simbolio,
; 5. jei ne tarpas, spausdinam simboli tiek kartu, kiek cl yra lygu

	MOV bl, 00h						; nunulinam
char:	
	LODSB                        	; imti is es:si stringo dali ir dedame i al 
	CMP al, 0dh						; jei char 0
	JZ ending                   	; tai baigiame
	
	CMP al, ' '
	JE increase						; if yes, jump to increase
									
_1:	 
	MOV ah, 2                    	; isvedimui vieno simbolio
	MOV dl, al                    	; i dl padeti simboli is al
	INT 21h                        	; dos'o INTeruptas
	LOOP _1							; spausdinam kelis sykius
	MOV cx, 0001h					; istustinam ciklo skaitliuka, nes kitaip pereina i FFFF???

	DEC bh							; sumazinam ilgi
	CMP al, 0dh						; ar teksto pabaiga
	JZ ending						; jei perejom per visus simbolius
	JMP char						; jei ne, tai vykdom algoritma is naujo

increase:
	INC cl
	INC bl
	JMP char	
	 
ending:
	; isvesti kiek tarpu
	MOV ah, 09h
	MOV dx, offset space
	INT 21h

	;MOV ah, 02h					; isspausdina simbolio reiksme, o ne skaiciu
	;MOV dl, bl
	;INT 21h

	MOV  al, bl					; i al pasidedam skaiciu, kuri spausdinsim																																			; source: http://stackoverflow.com/questions/34254461/assembly-basics-output-register-value
	AAM							; Ascii adjust for multipliation : ah:=al div 10; al:=al mod 10
	ADD  ax, "00"				; pavercia desimtainiu skaiciu
	XCHG al, ah					; sukeicia registro baitus vietomis
	
	MOV  dx, ax					
	MOV  ah, 02h				; int 21,02 spausdina ekrane dl
	INT  21h

	MOV  dl, dh					; isspausdinam ir dh				
	INT  21h

	MOV ah, 02h			
	MOV dl, ')'						; skliausto pabaigos simbolis
	INT 21h
	
	MOV ax, 4c00h 					; griztame i dos'a
	INT 21h                        	; dos'o INTeruptas
	 
end start