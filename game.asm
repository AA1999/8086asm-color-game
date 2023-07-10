.model small

.stack 50h


.data

	curC 	db ?     ; color of where it's clicked
	
	x2low  	dw ?
	x2high 	dw ?
	y2low  	dw ?
	y2high	dw ?
	r2low 	dw ?
	r2high 	dw ?
	
	xy2low	dw ?
	xy2high	dw ?

	pow2 macro a
		mov ax, a
		imul ax
	endm
	
	circle macro x, y, r, color
		
		local x_loop
		local y_loop
		local end_section
		local check_lows
		local inner_loop_done
		local draw_pixel
		
		
		mov si, r + 1   ; we'll decrease it once at the start of the loop
		mov di, r + 1
		
		; si is i
		; di is j
		
		x_loop:
			dec si
	 
			cmp si, -r  ; si = r to -r
			js end_section 
			y_loop:
				dec di
									
				pow2 si
				
				mov [x2low], ax
				mov [x2high], dx   
				
				pow2 di
				mov [y2low], ax
				mov [y2high], dx
				

				pow2 r
				mov [r2low], ax
				mov [r2high], dx
				
				mov ax, [x2low]
				add ax, [y2low]
				
				mov bx, [x2high]
				adc bx, [y2high]
				
				mov [xy2low], ax
				mov [xy2high], bx
				
				mov ax, [r2low]
				mov bx, [r2high]
				
				cmp [xy2high], bx	; if i ^ 2 + j ^ 2 <= r ^ 2
				
				js draw_pixel 
				je check_lows:		; if higher bits were equal, check lower bits
				
				check_lows:
					mov ax, [xy2low]
					cmp ax, [r2low]
					js draw_pixel
				cmp di, -r	
				js inner_loop_done 
					
			jmp y_loop
			
			inner_loop_done:
				mov di, r + 1
				jmp x_loop
			
		jmp x_loop
				
			draw_pixel:
				mov ah, 0ch
				mov al, color
				mov cx, x
				add cx, si
				mov dx, y
				add dx, di
				mov bx, 0
				
				int 10h
				jmp y_loop		
				 
		
				
		
		end_section:
	endm
	
	rectangle macro x1, y1, x2, y2, color
		
		mov si, x1
		mov di, y1
		
		local x_loop
		local y_loop
		local inner_loop_done
		local end_section
		
		x_loop:
			cmp si, x2
			jg end_section
			y_loop:
				cmp di, y2
				jl inner_loop_done
				
				push si
				push di
				
				mov ah, 0ch
				mov al, color
				mov bx, 0
				mov cx, si
				mov dx, di
			   	
			   	int 10h
			   	
			   	pop di
			   	pop si
			   	
			   	dec di
			   	
			jmp y_loop
				
	inner_loop_done:
		mov di, y1
		inc si
		jmp x_loop
			
		end_section:
	endm
	


.code

	main: 
		
	    mov ah, 0
	    mov al, 13h
	    mov bx, 0
	    int 10h ;graphical mode
    	
    	mov ax, @data
    	mov ds, ax
    	
    	;initial circles
        	
		circle 100 	50  20  5
		circle 150 	50  20  7
		circle 200 	50  20  0Bh
		circle 250  50  20  2
		circle 100	100 20  0Eh
		circle 150	100	20	1
		circle 200	100	20	4
		circle 250	100	20	3
		
		mov ax, 1
		int 33h 
		
		check_click:
			mov ax, 3
			mov bx, 0
			int 33h
			
			cmp bx, 1
			je interrupt
			jmp check_click	    
	      
	    interrupt:
	    	shr cx, 1 ; cx = cx / 2 -> int 33h documentation
			cmp dx, 149
			jge check_click
			
			mov ax, 2h
			int 33h
			
			mov ah, 0dh
			mov bx, 0
			int 10h
			
			cmp al, 0
			je check_click
		
			mov [curC], al
			
			mov ax, 1h
			int 33h
			
			mov ax, 2h
			int 33h
			
			rectangle 0 	199 	107 	149		curC
			rectangle 107	199		213		149		0Fh
			rectangle 213	199		319		149		curC
	    	
	  	  	mov ax, 1h
	    	int 33h
	    	
	    	jmp check_click

	jmp $
	
	end main    
    
	
