*-----------------------------------------------------------
* Title        : Connect3.X68
* Author Name  : Jason klutse
* Description  : Connect 3 (4x4 grid game)
*-----------------------------------------------------------
    
            ORG    $1000
_MAIN:                  

            
            jsr     setup_board         ;put initial characters into squares

LOOP        jsr     display_board       ;display 4x4 board on console
            jsr     get_move            ;player X goes first - get pointer to selected square
            move.b  #'X',(a0)           ;put X in square pointed at by A0
            jsr     display_board       ;update board with new square containing X
            jsr     check_win           ;check for a winning line of 3 and exit if found
            
            jsr     get_move            ;player O's turn - get pointer to selected square
            move.b  #'O',(a0)           ;put O in square pointed at by A0
            jsr     display_board       ;update board with new square containing O
            jsr     check_win           ;check for a winning line of 3 and exit if found

            bra     LOOP 

** end of main subroutine


** all subroutines follow below
          
**************************************************************
* setup_board: initializes 4x4 board data structure          *   
*                                                            *
*      ENTER: no parameters                                  * 
*       EXIT: no return value(s)                             *
*       Uses: no subroutines                                 *
**************************************************************
setup_board:
            lea     board,a0            
            move.b  #10,d0              
            move.b  #'0',d1             
L1          move.b  d1,(a0)+            
            add.b   #1,d1               
            subq.b  #1,d0
            bne     L1   
            move.b  #6,d0              
            move.b  #'A',d1             
L2          move.b  d1,(a0)+            
            add.b   #1,d1               
            subq.b  #1,d0
            bne     L2                
            rts      


*************************************************************
* display_board: show 4x4 board in top-left corner of console*   
*                                                           *
*      ENTER: no parameters                                 * 
*       EXIT: no return value(s)                            *
*       Uses: display_row, display_line subroutines         *
*************************************************************                                                                                                                            
display_board:         
            ;set cursor position in console to (0,0)       
            clr.l   d1                  ;COL = 0 (high byte) ROW = 0 (low byte)
            move.b  #11,d0              ;task 11
            trap    #15                 ;call operating system

            ;draw 4x4 board one row and separator at a time             
            lea     board,a0            ;put address of board in a0 
            jsr     display_row         ;show row 1
            jsr     display_line        ;show separator line
            jsr     display_row         ;show row 2
            jsr     display_line        ;show separator line
            jsr     display_row         ;show row 3
            jsr     display_line        ;show separator line
            jsr     display_row         ;show row 4
            rts


*************************************************************
* display_row: display 4 squares in current row on console  *   
*                                                           *
*      ENTER: A0 contains address of first square in row    * 
*       EXIT: no return value(s)                            *
*       Uses: display_square, display_char subroutines      *
*************************************************************      
display_row:
            move.b  #' ',d1
            jsr     display_char
            jsr     display_square
            move.b  #' ',d1
            jsr     display_char
            move.b  #'|',d1
            jsr     display_char
            move.b  #' ',d1
            jsr     display_char
            jsr     display_square
            move.b  #' ',d1
            jsr     display_char
            move.b  #'|',d1
            jsr     display_char
            move.b  #' ',d1
            jsr     display_char
            jsr     display_square
            move.b  #' ',d1
            jsr     display_char
            move.b  #'|',d1
            jsr     display_char
            move.b  #' ',d1
            jsr     display_char
            jsr     display_square
            jsr     newline  
            rts
            

*************************************************************
* display_line: display separator line for 4x4 on console   *
*                                                           *
*      ENTER: no parameters                                 * 
*       EXIT: no return value(s)                            *
*       Uses: newline, display_char subroutines             *
*************************************************************  
display_line:
            move.b  #'-',d1
            jsr     display_char
            jsr     display_char
            jsr     display_char
            move.b  #'+',d1
            jsr     display_char

            move.b  #'-',d1
            jsr     display_char
            jsr     display_char
            jsr     display_char
            move.b  #'+',d1
            jsr     display_char
            
            move.b  #'-',d1
            jsr     display_char
            jsr     display_char
            jsr     display_char
            move.b  #'+',d1
            jsr     display_char

            move.b  #'-',d1
            jsr     display_char
            jsr     display_char
            jsr     display_char
            
            jsr     newline
            rts


*************************************************************
* newline: send carriage return, linefeed chars to console  *
*                                                           *
*      ENTER: no parameters                                 * 
*       EXIT: no return value(s)                            *
*       Uses: display_char subroutine                       *
*************************************************************  
newline:
            move.b  #$d,d1          ;carriage return
            jsr     display_char    ;send to console
            move.b  #$a,d1          ;linefeed
            jsr     display_char    ;send to console
            rts
            
            
*************************************************************
* display_square: display character in square on console    *
*                                                           *
*      ENTER: A0 contains address of square                 * 
*       EXIT: A0 incremented to point to next square        *
*       Uses: display_char subroutine                       *
*************************************************************  
display_square:
            move.b  (a0)+,d1        ;get char in square
            jsr     display_char    ;display char
            rts


*************************************************************
* display_char: send ASCII character to console             *
*                                                           *
*      ENTER: character in D1.B                             * 
*       EXIT: no return value(s)                            *
*       Uses: no subroutines, calls OS routines             *
*************************************************************  
display_char:

        movem.l d0/d1,-(sp)         ;save working registers
        move.b  #6,d0               ;task number 6
        trap    #15                 ;call operating system
        movem.l (sp)+,d0/d1         ;restore registers
        rts

    
*************************************************************
* read_char: read key from keyboard with NO echo            *
*                                                           *
*      ENTER: no parameters                                 * 
*       EXIT: ASCII value of key in D1.B                    *
*       Uses: no subroutines, calls OS I/O routines         *
*************************************************************  
read_char:
        
        ;start by turning off keyboard echo
        clr.b   d1                  ;set lower byte to zero
        move.b  #12,d0              ;select task 12
        trap    #15                 ;call OS
        
        ;now read a single ascii character into D1.B
        move.b  #5,d0               ;select task 5  
        trap    #15                 ;call OS
        rts
        

*************************************************************
* get_move: gets valid player move and returns pointer in A0*
*                                                           *
*      ENTER: no parameters                                 *
*       EXIT: A0 contains address of selected board square  *
*       Uses: read_char, SIMHALT                            *
*************************************************************
get_move:
        movem.l d2-d3,-(sp)

READ_KEY:
        jsr     read_char

        ; Check for Escape
        cmpi.b  #$1B,d1
        beq     EXIT_GAME

        ; Accept only characters '0' through '3'
        cmpi.b  #'0',d1
        blo     READ_KEY
        cmpi.b  #'3',d1
        bhi     READ_KEY

        ; Convert ASCII column number into a number
        move.b  d1,d2
        andi.w  #$00FF,d2
        subi.w  #'0',d2

        ; Find the bottom square of the selected column
        lea     board,a0
        adda.w  #12,a0
        adda.w  d2,a0

        ; Check up to four squares in this column
        move.w  #4,d3

CHECK_SQUARE:
        move.b  (a0),d1

        ; Is this square occupied by X?
        cmpi.b  #'X',d1
        beq     MOVE_UP

        ; Is this square occupied by O?
        cmpi.b  #'O',d1
        bne     VALID_MOVE

MOVE_UP:
        suba.w  #4,a0
        subq.w  #1,d3
        bne     CHECK_SQUARE

        ; Column is full: ask for another column
        bra     READ_KEY

VALID_MOVE:
        movem.l (sp)+,d2-d3
        rts

EXIT_GAME:
        movem.l (sp)+,d2-d3
        SIMHALT


*************************************************************
* check_win: checks for 3-in-a-row winning line             *
*                                                           *
*      ENTER: no parameters                                 *
*       EXIT: exits via SIMHALT if win found, else returns  *
*       Uses: display_char, SIMHALT                         *
*************************************************************
check_win:
        lea     board,a0
        clr.l   d4
        clr.l   d5
        move.w  #9,d5
        ; Check horizontal combinations
LOOP        
        move.w  d4,d2
        move.w  #1,d3
        jsr     check_three
        
        addi.w  #1,d4
        
        subi.w  #1,d5
        cmpi.w  #1,d5
        bne     LOOP

        ; Check vertical combinations
        move.w  #0,d2
        move.w  #4,d3
        jsr     check_three

        move.w  #1,d2
        move.w  #4,d3
        jsr     check_three

        move.w  #2,d2
        move.w  #4,d3
        jsr     check_three

        move.w  #3,d2
        move.w  #4,d3
        jsr     check_three

        move.w  #4,d2
        move.w  #4,d3
        jsr     check_three

        move.w  #5,d2
        move.w  #4,d3
        jsr     check_three

        move.w  #6,d2
        move.w  #4,d3
        jsr     check_three

        move.w  #7,d2
        move.w  #4,d3
        jsr     check_three

        ; Check diagonal down-right
        move.w  #0,d2
        move.w  #5,d3
        jsr     check_three

        move.w  #1,d2
        move.w  #5,d3
        jsr     check_three

        move.w  #4,d2
        move.w  #5,d3
        jsr     check_three

        move.w  #5,d2
        move.w  #5,d3
        jsr     check_three

        ; Check diagonal down-left
        move.w  #2,d2
        move.w  #3,d3
        jsr     check_three

        move.w  #3,d2
        move.w  #3,d3
        jsr     check_three

        move.w  #6,d2
        move.w  #3,d3
        jsr     check_three

        move.w  #7,d2
        move.w  #3,d3
        jsr     check_three

        ; No winning line found
        rts


WIN_FOUND:
        ; D0 contains the winning character (X or O)
        move.b  d0,d1
        jsr     display_char

        move.b  #' ',d1
        jsr     display_char

        move.b  #'w',d1
        jsr     display_char

        move.b  #'i',d1
        jsr     display_char

        move.b  #'n',d1
        jsr     display_char

        move.b  #'s',d1
        jsr     display_char

        SIMHALT
        
*************************************************************
* check_three: checks three consecutive board squares       *
*                                                           *
*      ENTER: A0 = board address D2 = starting square offset D3 = distance between squares*
*      EXIT: branches to WIN_FOUND if three matching marks  *
*      Uses: yes                                            *
*************************************************************
check_three:
        ; Calculate address of first square
        movea.l a0,a1
        adda.w  d2,a1

        ; First square must contain X or O
        move.b  (a1),d0

        cmpi.b  #'X',d0
        beq     CHECK_REST

        cmpi.b  #'O',d0
        bne     CHECK_THREE_DONE

CHECK_REST:
        ; Compare second square
        cmp.b   0(a1,d3.w),d0
        bne     CHECK_THREE_DONE

        ; Compare third square
        adda.w  d3,a1
        cmp.b   0(a1,d3.w),d0
        beq     WIN_FOUND

CHECK_THREE_DONE:
        rts

* Allocate memory for 4x4 board data structure (16 bytes)

           org     $A000
board      ds.b    16          
           end    _MAIN        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
