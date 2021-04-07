IDEAL
MODEL small
STACK 6000h
DATASEG
	initialX dw 0 
	x dw 0
	y dw 0
	h dw 0
	l dw 0
	count dw 0
	count2 dw 0
	color db 3
	colorSave db 3
	secColor db 3
	colorFind db 3
	colorInc db 1
	brushSize dw 2
	right dw 0
	clicked dw 0
	colorToChange db 0
	death dw 0
CODESEG
start:
	mov ax, @data
	mov ds, ax
	
	; Graphics mode
	mov ax,13h
	int 10h
	; Initializes the mouse
	mov ax,0h
	int 33h
	; Show mouse
	mov ax,1h
	int 33h
	
	call drawScreen
	;run the main program
	main:
	
	; check for mouse click
	MouseLP :
	mov ax,3h
	int 33h
	cmp bx, 01h ; check left mouse click
	je mouser ;if it is, go to mousepressed
	cmp bx, 10b ; check left mouse click
	je righer ;if it is, go to mousepressed
	cmp bx, 00b
	jne w 
	mov [clicked],0
	w:
	in  al, 64h    ; Read keyboard status port 
	cmp   al, 10b    ; Data in buffer  ? 
	je con2    ; if there is no data skip
	in  al, 60h    ; Get keyboard data 
	
	cmp   al, 1h     ; Is it the ESC key  ? 
	je continue ; go to exit
	
	cmp   al, 2h     ; Is it the 1 key  ? 
	je onepressed ; go to onepressed
	
	cmp   al, 3h     ; Is it the 2 key  ? 
	je twopressed ; go to twopressed
	
	cmp   al, 4h     ; Is it the 3 key  ? 
	je threepressed ; go to threepressed
	
	cmp   al, 5h     ; Is it the 4 key  ? 
	je fill_pressed ; go to fill_pressed
	
	cmp   al, 0fh     ; Is it the tab key  ? 
	je clear ; go to clear
	con2:
	
	jmp main
	
	onepressed:
		mov [color], 1
	jmp main
	righer:
	jmp rightPressed
	twopressed:
		mov [color], 2
	jmp main
	mouser:
	jmp mousepressed
	threepressed:
		mov [color], 3
	jmp main
	fill_pressed:
		; hide mouse
		mov ax,2h
		int 33h
		
		mov ax,3h
		int 33h
		shr cx,1
		sub dx, 1
		mov bh, 0h
		mov ah, 0Dh
		int 10h
		mov [colorToChange], al
		mov [death], 10000
		push cx
		push dx
		call fill
		; Show mouse
		mov ax,1h
		int 33h
	jmp main
	
	clear:
		;hide mouse
		mov ax,2h
		int 33h
		call clearScreen
		; Show mouse
		mov ax,1h
		int 33h
	jmp main
	mainers:
	jmp main
	continue:
	jmp cont
	rightPressed:
		mov [right], 1
	
	
	
	mousepressed:
		shr cx,1 ; adjust cx to range 0-319, to fit screen
		cmp cx, 289
		jg but1
		;cmp [right],1
		;je a
		call drawNearMouse
		jmp MouseLP
		;the previous thing I tried----------
		;a:
		;	push [word ptr color]
		;	push ax
		;	mov al, [secColor]
		;	mov [color], al
		;	pop ax
		;	call drawNearMouse
		;	pop [word ptr color]
		;	mov [right],0
		;-------------------------------------
		;check if button1 was pressed
		cmp bx, 00b ; check left mouse click
		jne mainers ;if it is, go to mousepressed
		mov [clicked], 0
		but1:
			;check the x
			cmp cx, 299
			jl but2
			cmp cx, 315
			jg but2
			;check the y
			cmp dx, 80
			jl but2
			cmp dx, 90
			jg but2
			;if it was pressed
			cmp [right], 1
			je rP ;right pressed
			call clearScreen
			jmp main
			rp:
				;set the settings for the background
				mov [x], 0
				mov [y], 0
				mov [h], 200
				mov [l], 290
				mov al, [color]
				mov [colorFind], al
				push ax
				mov [color], 0fh
				
				push [l]
				push [y]
				push [x]
				push [h]
				call clearOnly
				pop ax
				mov [color], al
				mov [right],0
		jmp main
		
		but2:
			;check the x
			cmp cx, 293
			jl plus
			cmp cx, 318
			jg plus
			;check the y
			cmp dx, 95
			jl plus
			cmp dx, 135
			jg plus
			;if it was pressed
			sub dx, 1 ; move one pixel, so the pixel will not be hidden by mouse
			mov bh, 0h
			mov ah, 0Dh
			int 10h
			cmp [right], 1
			je right1
			mov [color], al
			jmp left
			right1:
				mov [secColor], al
				mov [right],0
			left:
			call colorShower
		
		jmp main
		mainer:
		jmp main
		plus:
			;check the x
			cmp cx, 297
			jl minus
			cmp cx, 304
			jg minus
			;check the y
			cmp dx, 149
			jl minus
			cmp dx, 156
			jg minus
			;if it was pressed
			cmp [clicked], 0
			jne mainer
			mov [clicked], 1
			inc [brushSize]
			cmp [brushSize], 7
			jne mainer
			mov [brushSize], 6
		jmp main
		minus:
			;check the x
			cmp cx, 308
			jl but3
			cmp cx, 315
			jg but3
			;check the y
			cmp dx, 149
			jl but3
			cmp dx, 156
			jg but3
			;if it was pressed
			cmp [clicked], 0
			jne mainer
			mov [clicked], 1
			dec [brushSize]
			cmp [brushSize], 0
			jne mainer
			mov [brushSize], 1
		jmp main
		but3:
		
	jmp MouseLP
	
	cont:
	; Press any key to continue
	mov ah,00h
	int 16h
	mov ax, 4c00h
	int 21h
	
	; Text mode
	mov ax,3h
	int 10h
	
	
	
	proc drawNearMouse
		; Print dot near mouse location
		;shr cx,1 ; adjust cx to range 0-319, to fit screen
		;check if the right click was pressed
		cmp [right], 1
		jne notRight
		push ax ;save ax before use
		;save the color in colorSave
		mov al, [color]
		mov [colorSave],al
		;move the secColor to color
		mov ah, [secColor]
		mov [color], ah
		pop ax ;pop ax after use
		
		notRight:
		sub cx, [word ptr brushSize]
		add cx, 1
		cmp cx, 0;check for overlap with the border of the screen
		jg q
		mov cx,0
		q:
		sub dx, [word ptr brushSize] ; move one pixel, so the pixel will not be hidden by mouse
		
		;set the settings for the brush 
		push [word ptr brushSize];[l]
		push dx;[y]
		push cx;[x]
		push [word ptr brushSize];[h]
		call drawSquare; draw it
		
		;check if the right click was pressed
		cmp [right], 1
		jne en ;if not go to the end of the proc
		push ax;save ax before use
		;move the colorSave to color
		mov al ,[colorSave]
		mov [color], al
		mov [right], 0 ;uncheck the mouse right var
		pop ax ;pop ax after use
		
		;the previous thing I tried------
		;mov bh,0h
		;mov al,[color]
		;mov ah,0Ch
		;int 10h
		;--------------------------------
		en:
		ret 
	endp
	
	proc draw
		; pushing the registers into the stack for later use
		push bx
		push cx
		push dx
		push ax
		
		mov bh,0h
		;mov cx,[x]
		;mov dx,[y]
		mov al,[color]
		mov ah,0ch
		int 10h
		
		; pop the registers from the stack
		pop ax
		pop dx
		pop cx
		pop bx
		ret
	endp
	
	proc drawSquare ; x, y = the left up position, h,l the hieght and length, color = the color
		; pushing the registers into the stack for later use
		; h = bp + 2
		; x = bp + 4
		; y = bp + 6
		; l = bp + 8
		; color = bp + 9
		mov bp, sp
		
		push si
		push di
		push bx
		push cx
		push dx
		push ax
		
		; Print the square
		mov cx, [bp + 2]  ;[h]
		mov [count2], cx
		mov dx, [bp + 4]  ;[x]	
		mov [initialX], dx 	;resetting the initial x 
		again:
			mov dx, [bp + 8]
			mov[count], dx
			
			again2:
				mov cx, [word ptr bp + 4]
				mov dx, [word ptr bp + 6]
				call draw
				inc [word ptr bp + 4]
			dec [count]
			cmp [count], 0
			jne again2
			;for debugging reasons-----
			;mov ah,00h
			;int 16h
			;--------------------------
			mov dx, [bp + 8]
			mov [count], dx
			mov dx, [initialX]
			mov [bp + 4], dx
			inc [word ptr bp + 6]
			dec [count2]
			cmp [count2], 0
			je s
		loop again
		s:
		; pop the registers from the stack
		pop ax
		pop dx
		pop cx
		pop bx
		pop di
		pop si
		
		ret 8
	endp
	
	proc clearScreen ; clear the screen
		
		
		;makes each pixel white
		mov [x], 0
		mov [y], 0
		mov [h], 200
		mov [l], 290
		mov al, [color]
		push ax
		mov [color], 0fh
		push [l]
		push [y]
		push [x]
		push [h]
		call drawSquare			
		;pop [l]
		;pop y
		;pop x
		;pop h
		pop ax
		mov [color], al
		;get the mouse back after clearing the screen
		

		ret
	endp
	
	proc drawScreen
		;hide mouse
		mov ax,2h
		int 33h
		call clearScreen
		; Show mouse
		mov ax,1h
		int 33h
		;draw the background for the buttons
		
		;set the settings for the background
		mov [x], 290
		mov [y], 0
		mov [h], 200
		mov [l], 30
		mov al, [color]
		push ax
		mov [color], 16h
		
		push [l]
		push [y]
		push [x]
		push [h]
		call drawSquare	
		
		;draw the button1
		
		;set the settings for the button
		mov [x], 300
		mov [y], 80
		mov [h], 10
		mov [l], 15
		mov [color], 14h
		push [l]
		push [y]
		push [x]
		push [h]
		call drawSquare	
		
		
		;draw the palette
		mov [colorInc],1
		mov [count], 0
		mov [count2], 0
		mov [x], 293
		mov [y], 95
		mov [color], 1h
		againp2:
			push [count2]
			againp:
				
				;for debugging reasons-----
				;mov ah,00h
				;int 16h
				;--------------------------
				push [count] 
				call drawPal
				pop [count]
				add [x], 5
				add [count],5
				mov al, [colorInc]
				add [color], al
				cmp [count], 25
				jl againp
			mov [count], 0
			mov [x], 293
			add [y], 5
			pop [count2]
			add [count2], 5
			cmp [count2], 20
			jne b
			mov [colorInc], 2
			b:
			cmp [count2], 40
			jl againp2
			
				
		; to continue
		
		call colorShower
		call drawPlus
		call drawMinus
		pop ax
		mov [color], al
		
		ret
	endp


	proc drawPal
		;set the settings for the color button

		mov [h], 5
		mov [l], 5

		push [l]
		push [y]
		push [x]
		push [h]
		call drawSquare		
		
		ret
	endp
	
	proc colorShower
		;show the primary color and the secondary color
		;secondary color
		push [word ptr color]
		mov al,[secColor]
		mov [color], al
		
		push 5;[l]
		push 25;[y]
		push 310;[x]
		push 15;[h]
		call drawSquare	
		
		push 10;[l]
		push 35;[y]
		push 300;[x]
		push 5;[h]
		call drawSquare	
		pop [word ptr color]
		
		
		;primary color
		push 15;[l]
		push 20;[y]
		push 295;[x]
		push 15;[h]
		call drawSquare		
		
		ret
	endp
	mainering:
	jmp mainer
	proc clearOnly
		; pushing the registers into the stack for later use
		; h = bp + 2
		; x = bp + 4
		; y = bp + 6
		; l = bp + 8
		; color = bp + 9
		mov bp, sp
		
		push si
		push di
		push bx
		push cx
		push dx
		push ax
		
		; Print the square
		mov cx, [bp + 2]  ;[h]
		mov [count2], cx
		mov dx, [bp + 4]  ;[x]	
		mov [initialX], dx 	;resetting the initial x 
		againer:
			mov dx, [bp + 8]
			mov[count], dx
			
			againer2:
				mov cx, [word ptr bp + 4]
				mov dx, [word ptr bp + 6]
				mov bh, 0h
				mov ah, 0Dh
				int 10h
				cmp al, [colorFind]
				jne co
				call draw
				co:
				inc [word ptr bp + 4]
			dec [count]
			cmp [count], 0
			jne againer2
			;for debugging reasons-----
			;mov ah,00h
			;int 16h
			;--------------------------
			mov dx, [bp + 8]
			mov [count], dx
			mov dx, [initialX]
			mov [bp + 4], dx
			inc [word ptr bp + 6]
			dec [count2]
			cmp [count2], 0
			je f
		loop againer
		f:
		; pop the registers from the stack
		pop ax
		pop dx
		pop cx
		pop bx
		pop di
		pop si
		
		ret 8
		
		ret
	endp
	mainly:
	jmp mainering
	proc drawPlus
		push [word ptr color]
		mov [color], 0
		;plus
		push 7;[l]
		push 149;[y]
		push 297;[x]
		push 7;[h]
		call drawSquare	
		mov [color], 15
		
		push 1;[l]
		push 150;[y]
		push 300;[x]
		push 5;[h]
		call drawSquare	
		push 5;[l]
		push 152;[y]
		push 298;[x]
		push 1;[h]
		call drawSquare	
		pop [word ptr color]
		ret
	endp 
	
	proc drawMinus
		push [word ptr color]
		mov [color], 0
		;minus
		push 7;[l]
		push 149;[y]
		push 308;[x]
		push 7;[h]
		call drawSquare	
		mov [color], 15
		
		push 5;[l]
		push 152;[y]
		push 309;[x]
		push 1;[h]
		call drawSquare	
		pop [word ptr color]
		ret
	endp
	proc fill
		cmp [death], 0
		jne not_die
		;ret 4
		not_die:
		dec [death]
		mov bp, sp
		
		;locating the color at the x, y
		mov cx, [bp+4]
		mov dx, [bp+2]
		mov bh, 0h
		mov ah, 0Dh
		int 10h
		
		cmp al, [colorToChange]
		jne notTheColor ;if its not the color to change go to end
		cmp [word ptr bp+4], 290
		jg notTheColor ; if its out of the border go to end
		
		;if it is color the spot
		push [bp+4]
		push [bp+2]
		call colorSpot
		mov bp, sp
		;--- for debugging reasons-----
		;mov ah,00h
		;int 16h
		;mov sp, bp
		;------------------------------

		
		;call the proc again for each of the pixels near the painted pixel----
		
		; south
		mov ax, [bp+2]
		add ax, 1b
		push [bp+4] 
		push ax
		call fill
		mov bp, sp
		
		;north
		mov ax, 0
		mov ax, [bp+2]
		sub ax, 1b
		push [bp+4] 
		push ax
		call fill
		mov bp, sp
		
		;west
		mov bx, 0
		mov bx, [bp+4]
		sub bx, 1b
		push bx 
		push [bp+2]
		call fill
		mov bp, sp
		
		;east
		mov bx, 0
		mov bx, [bp+4]
		add bx, 1b
		push bx 
		push [bp+2]
		call fill
		mov bp, sp
		
		;----------------------------------------------------------------------
		notTheColor:
		ret 4
	endp
	
	proc colorSpot
		
		;getting the values entered into the stack
		mov bp, sp
		
		;pushing the registers before use
		push ax
		push bx
		push cx
		push dx
		
		cmp [word ptr bp+4], 290 ;if out of borders dont paint
		jg not1
		mov bx, 0h
		mov cx, [bp+4]
		mov dx, [bp+2]
		mov al, [color]
		mov ah,0ch
		int 10h
		
		not1:
		;popping the registers after use
		pop dx
		pop cx
		pop bx
		pop ax
		ret 4
	endp
	
exit:
	mov ax, 4c00h
	int 21h
END start


