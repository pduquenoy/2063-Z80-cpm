;****************************************************************************
;
;    VDP Graphics Mode 1 Test App
;
;    Copyright (C) 2021,2022 John Winans
;
;    This library is free software; you can redistribute it and/or
;    modify it under the terms of the GNU Lesser General Public
;    License as published by the Free Software Foundation; either
;    version 2.1 of the License, or (at your option) any later version.
;
;    This library is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;    Lesser General Public License for more details.
;
;    You should have received a copy of the GNU Lesser General Public
;    License along with this library; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
;    USA
;
;
;****************************************************************************

; Graphics MODE1 test app based on example from the TI VDP Programmer's Guide - SPPU004

.vdp_vram:	equ	0x80	; VDP port for accessing the VRAM
.vdp_reg:	equ	0x81	; VDP port for accessing the registers

	org	0x100

	ld	sp,.stack

	;******************************************
	; Initialize the VDP into graphics mode 1
	;******************************************

	ld	hl,.mode1init
	ld	b,.mode1init_len
	ld	c,.vdp_reg
	otir				; write the config bytes

	;******************************************
	; Initialize the VRAM with useful patterns
	;******************************************

	ld	hl,.vraminit		; buffer-o-bytes to send
	ld	bc,.vraminit_len	; number of bytes to send
	ld	de,0x0000		; VDP address of the VRAM is 0
	call	vdp_write_slow

	jp	0		; warm boot




;**********************************************************************
; Copy a given memory buffer into the VDP buffer.  
;
; The VDP can require up to 8usec per VRAM write in Graphics modes
; 1 and 2 when painting the active display area.
; (TMS9918 manual page 2-4)
;
; This runs slow enough to be used during active display.
;
; DE = VDP target memory address
; HL = host memory address
; BC = number of bytes to write
; Clobbers: AF, BC, DE, HL
;**********************************************************************
vdp_write_slow:
	; copy the new sprite location values into the VRAM
	; Set the VRAM write address
	ld	a,e
	out	(.vdp_reg),a		; VRAM address LSB to write
	ld	a,d
	or	0x40
	out	(.vdp_reg),a		; VRAM address MSB to write

	push	bc
	pop	de			; DE = byte count

	ld	c,.vdp_vram		; the I/O port number

.vdp_write_slow_loop:
	outi				; note: this clobbers B

	; Waste time between transfers (8.36 usec update rate @ 10 MHZ)
	push	hl
	pop	hl
	push	hl
	pop	hl

	; counter logic 
	dec	de
	ld	a,d
	or	e
	jr	nz,.vdp_write_slow_loop
	ret


;*********************************************************************
; initialization data for the VDP registers
;*********************************************************************

.mode1init:
	db	0x00,0x80	; R0 = graphics mode, no EXT video
	db	0xc0,0x81	; R1 = 16K RAM, enable display, disable INT, 8x8 sprites, mag off
	db	0x05,0x82	; R2 = name table = 0x1400
	db	0x80,0x83	; R3 = color table = 0x0200
	db	0x01,0x84	; R4 = pattern table = 0x0800
	db	0x20,0x85	; R5 = sprite attribute table = 0x1000
	db	0x00,0x86	; R6 = sprite pattern table = 0x0000
	db	0x1f,0x87	; R7 = bg color = white
.mode1init_len: equ	$-.mode1init	; number of bytes to write




;*********************************************************************
; initialization data that is sent to the VRAM
;*********************************************************************

	; padd the initializer table % 0x1000 to make debugging addresses easy
	ds	0x1000-(($+0x1000)&0x0fff)

.vraminit:
	; 0x0000-0x07ff sprite patterns
	ds      0x800,0xf0       		

.pat_start:
	; 0x0800-0x0fff pattern table 
	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	; 00000000  (blank)
	db	0x00,0x00,0x80,0x80,0x80,0x80,0x80,0x80	; 10000000
	db	0x00,0x00,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0	; 11000000
	db	0x00,0x00,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0	; 11110000
	db	0x00,0x00,0xf8,0xf8,0xf8,0xf8,0xf8,0xf8	; 11111000
	db	0x00,0x00,0xfc,0xfc,0xfc,0xfc,0xfc,0xfc	; 11111100
	db	0x00,0x00,0xfe,0xfe,0xfe,0xfe,0xfe,0xfe	; 11111110
	db	0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff	; 11111111

	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	; 00000000  (blank)
	db	0x00,0x00,0x80,0x80,0x80,0x80,0x80,0x80	; 10000000
	db	0x00,0x00,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0	; 11000000
	db	0x00,0x00,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0	; 11110000
	db	0x00,0x00,0xf8,0xf8,0xf8,0xf8,0xf8,0xf8	; 11111000
	db	0x00,0x00,0xfc,0xfc,0xfc,0xfc,0xfc,0xfc	; 11111100
	db	0x00,0x00,0xfe,0xfe,0xfe,0xfe,0xfe,0xfe	; 11111110
	db	0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff	; 11111111

	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	; 00000000  (blank)
	db	0x00,0x00,0x80,0x80,0x80,0x80,0x80,0x80	; 10000000
	db	0x00,0x00,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0	; 11000000
	db	0x00,0x00,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0	; 11110000
	db	0x00,0x00,0xf8,0xf8,0xf8,0xf8,0xf8,0xf8	; 11111000
	db	0x00,0x00,0xfc,0xfc,0xfc,0xfc,0xfc,0xfc	; 11111100
	db	0x00,0x00,0xfe,0xfe,0xfe,0xfe,0xfe,0xfe	; 11111110
	db	0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff	; 11111111

	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	; 00000000  (blank)
	db	0x00,0x00,0x80,0x80,0x80,0x80,0x80,0x80	; 10000000
	db	0x00,0x00,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0	; 11000000
	db	0x00,0x00,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0	; 11110000
	db	0x00,0x00,0xf8,0xf8,0xf8,0xf8,0xf8,0xf8	; 11111000
	db	0x00,0x00,0xfc,0xfc,0xfc,0xfc,0xfc,0xfc	; 11111100
	db	0x00,0x00,0xfe,0xfe,0xfe,0xfe,0xfe,0xfe	; 11111110
	db	0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff	; 11111111

	ds	0x800-($-.pat_start),0x55		; 1-pixel-width stripes: 01010101  


	ds	0x080,0xd0	; 0x1000-0x107f sprite attributes
	ds	0x380,0x00	; 0x1080-0x13ff unused

.vraminit_name:
	; 0x1400-0x17ff name table
	db	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07
	db	0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f
	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	db	0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17
	db	0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f

	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	db	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

	db	0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
	db	0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
	db	0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
	db	0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03

	db	0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
	db	0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
	db	0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
	db	0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03

	ds	0x400-($-.vraminit_name),0x20		; 0x20 is a pattern that is set to 10101010

.vraminit_name_len:	equ	768				; Note: not ALL names are used

	ds	0x800,0x00	; 0x1800-0x1fff unused

	; For the color table, each entry represents 8 patterns
	db	0xf1		; white on black
	db	0x74		; cyan on dark blue
	db	0x84		; red on dark blue
	db	0xc4		; green on dark blue
	db	0xf1		; white on black
	db	0xf1		; white on black
	db	0xf1		; white on black
	db	0xf1		; white on black
	db	0xf1,0xf1,0xf1,0xf1,0xf1,0xf1,0xf1,0xf1	; white on black
	db	0xf1,0xf1,0xf1,0xf1,0xf1,0xf1,0xf1,0xf1	; white on black
	db	0xf1,0xf1,0xf1,0xf1,0xf1,0xf1,0xf1,0xf1	; white on black

.vraminit_len:	equ	$-.vraminit

	ds	1024
.stack:	equ	$