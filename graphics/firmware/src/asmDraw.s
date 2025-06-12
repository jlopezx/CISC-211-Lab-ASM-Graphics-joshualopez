/*** asmEncrypt.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

/*   #include <xc.h> */

/* Declare the following to be in data memory  */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Joshua Lopez"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them
 * (in this lab we return the pointer, so strictly speaking,
 * doesn't really need to be defined as global)
 */

.equ NUM_WORDS_IN_BUF, 40
.equ NUM_BYTES_IN_BUF, (4 * NUM_WORDS_IN_BUF)
 
.align
 
/* records the current frame number so asmDraw can choose appropriate buffer */
asmFrameCounter: .word 0

.global rowA00ptr
.type rowA00ptr,%gnu_unique_object
rowA00ptr: .word rowA00

/* Flying Saucer!!!
 * If you choose to modify this starting graphic, make sure your replacement
 * is exactly 2 words wide and 20 rows high, just like this one.
 */
rowA00: .word 0b00000000000000000000000000000000,0b00000000000000000000000000000000
rowA01: .word 0b01111101001001110010010100100000,0b00000100010111101001010000000000
rowA02: .word 0b00010001001010001011010101000000,0b00000010100100101001010000000000
rowA03: .word 0b00010001111011111011110110000000,0b00000001000100101001010000000000
rowA04: .word 0b00010001001010001010110101000000,0b00000001000100101001000000000000
rowA05: .word 0b00010001001010001010010100100000,0b00000001000111101111010000000000
rowA06: .word 0b00000000000000000000000000000000,0b00000000000000000000000000000000
rowA07: .word 0b00000000000000000000000000000000,0b00000000000000000000000000000000
rowA08: .word 0b00000000000000000000000000000011,0b11000000000000000000000000000000
rowA09: .word 0b00000000000000000000000000000100,0b00100000000000000000000000000000
rowA10: .word 0b00000000000000000000000000000011,0b11000000000000000000000000000000
rowA11: .word 0b00000000000000000000000000000001,0b10000000000000000000000000000000
rowA12: .word 0b00000000000000000000000001111111,0b11000000000000000000000000000000
rowA13: .word 0b00000000000000000000000000000001,0b10100000000000000000000000000000
rowA14: .word 0b00000000000000000000000000000001,0b10010000000000000000000000000000
rowA15: .word 0b00000000000000000000000000000001,0b10001000000000000000000000000000
rowA16: .word 0b00000000000000000000000000000001,0b10000000000000000000000000000000
rowA17: .word 0b00000000000000000000000000000001,0b10000000000000000000000000000000
rowA18: .word 0b00000000000000000000000000000001,0b10000000000000000000000000000000
rowA19: .word 0b00000000000000000000000000000001,0b10000000000000000000000000000000

/*
 * display buffers 0 and 1: 2 words (64 bits) wide, by 20 words high,
 * initialized at boot time to pre-determined values
 * REMEMBER! These are only initialized once, before the first time asmDraw
 * is called. If you want to clear them (i.e. set all bits to 0), you need to
 * add a function to do this in your assembly code.
 */
 
buf0: .space NUM_BYTES_IN_BUF, 0xF0
buf1: .space NUM_BYTES_IN_BUF, 0x0F

/* Tell the assembler that what follows is in instruction memory    */
.text
.align


    
/********************************************************************
function name: asmDraw(downUp, rightLeft, reset)
function description:
Note: r0 and r1 are optional. The C test code uses them 
as shown below. However, your code can choose to ignore them, and update
buf0 and buf1 any way you'd like whenever asmDraw is called.
However, r2 should always reset your animation to its starting value
         
Inputs: r0: upDown:    -N: move up (towards row00) N pixels
                        0: do not move in the vertical direction
                        N: (positive number): move down (towards row19)
        r1: leftRight: -N: move left N pixels
                        0: do not move in the horizontal direction
                        N: (positive number): move right N pixels
        r2: reset:      0: do the commands specified by other input
                           parameters
                        1: ignore the other input parameters. Reset the
                           display to its original state.
 Outputs: r0: pointer to memory buffer containing updated display data

 Notes: * Do not modify the data in any of the rowA** loctions! Use
          it as your reset data, to start over when commanded.
          Use the space allocated for buf0 and buf1 to capture your
          output data. 
        * The first call to the asmDraw code will always be a reset, so that
          you can copy clean data from rowA** into an output buffer.
        * The reset should always return the address of buf0 in r0,
                 e.g.   LDR r0,=buf0
        * Each subsequent call with a valid non-reset command should return
          the address of the other buffer. This allows you to copy and
          modfiy data from the previous buffer to generate your next
          buffer. So, if the last call returned buf0, the current call 
          should return buf1. And the call after that should once again 
          return buf0.
        * You can create more bufs if you need them for some reason.
        * You should create your own mem locations to store info such
          as which buf was the last one used.

********************************************************************/     
.global asmDraw
.type asmDraw,%function
asmDraw:   

    /*
     * STUDENTS: The code below is provided as a starting point. It ignores
     *           the inputs in r0, r1, and r2. It just alternates between
     *           buf0 and buf1 and returns the addresses of one or the
     *           other buffer. The C code displays the default values stored
     *           in those buffers. You can completely delete this code and 
     *           replace it with your own creation.
     */
    
    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
   /* Mov r2, 0*/
    cbz r2, getNextFrame /* if the reset flag in r2 was NOT set, get the next frame */
    
    /* reset the frame counter */
    ldr r4,=asmFrameCounter
    ldr r5,=0
    str r5,[r4]
    /* TODO: copy rowA** data to buf0 */
    /* for now, just use whatever is currently stored in buf0 */
    ldr r0,=buf0
    ldr r1, =rowA00
    ldr r8, [r0]
    ldr r7, =0xF0F0F0F0  /*Loading this to check if we're in the 1st buffer or not
			   This hex value is what is originally stored in buffer 0*/
    cmp r8, r7		 /*Comparing it with buffer 0*/
    bne getNextFrame
    /*Since our loop assignment is pre-indexing, we have to do one load-store before we enter the loop or 
    else we will miss the first row assignment*/
    ldr r4, [r1]
    str r4, [r0]
    add r3, r0, 156 /*Use this as a stopper for my loop_assignment. 156 bytes because 
     that's how many bytes we have to go through after our first load-store*/
    /*Simple overwrites the buffers with the the rows to initialize my code*/
    loop_assignment:
    ldr r4, [r1, 4]!	/*This pre-indexes the next word in rowA and loads it into r4 while also modifying the index in r1*/
    str r4, [r0, 4]!	/*This pre-indexes the next word in buf0 and loads it into r4 while also modifying the index in r0*/
    
    cmp r0, r3		/*Checks to see if we reached the end of the loop so we can stop looping*/
    bne loop_assignment /*This is used to keep looping if r0 isn't equal to r3*/
    ldr r0,=buf0	/*Returns buff0 to r0 as required by the calling convention*/
    b done
    
getNextFrame:
    /* STUDENTS: This is where you decide what to do in the next
     *  animation frame. */
  
    /* STUDENT CODE BELOW THIS LINE vvvvvvvvvvvvvvvvvvv */
    
    /*-----------------------------------Wave Caller-----------------------------------------------*/
    /*Code initalizes both buffers, it only runs with buff's 1st row is in position to the reset position.
    This is intentional to get a continuous movement of the THANK YOU!*/
    ldr r8, =buf0	      /*Loading r8 with buf0's mem address to load from it later*/
    ldr r8, [r8, 8]	      /*We preindex with 8 to skip over rowA00 and be in rowA01, and load the value from that index*/
    ldr r7, =0x7D272520	      /*This checks rowA01 to see if it has the top of THANK*/
    cmp r8, r7		      /*Compares r8 with the hex value above to see if we're in the original position*/
    /*If rowA01 is the above hex, then our THANK is in its original position, and we can call wave
    again, we do not really need to call it again, but this code runs every time, so we need a way to only call it
     when we need it or else it's going to reset my THANK position every time because wave initalize my 
     buffers to the original position.*/		
    bleq wave		      /*Caller of wave subroutine*/
	
    /*--------------------------------Frame Shift Handler------------------------------------------*/
    /*The point of frame shift handler is to load the state in the previous buffer from the last frame and load it into the 
    current buffer in the current frame. This is essentially a handoff between the buffers as they transverse the frames*/
    ldr r7, =asmFrameCounter  /*Using the frame counter to test it for even and odd frames*/
    ldr r7, [r7]	      /*Pulling the value in asmFrameCounter to test it for the next instruction*/
    tst r7, 1		      /*Makes a decision if we use buffer 0 or buffer 1 to alternate between the buffers*/
 
    /*Equal means we're even and displaying buffer 0*/
    ldreq r1, =buf1	      /*(LOAD FROM)If the frame counter is even, we want to copy from buf1 and store to buf0*/
    ldreq r2, =buf0	      /*(STORE TO)Loads r2 with buff 0 to store to later*/
    
    /*Not equal means we're odd and displaying buffer 1*/
    ldrne r1, =buf0	      /*(LOAD FROM)If we're in an odd frame, we want to copy from buf0 and store to buf1*/
    ldrne r2, =buf1	      /*(STORE TO) Loads r2 with buff 0 to store to later*/
    
   
    /*------------------------------------Word Shifter---------------------------------------------*/
    add r8, r1, 40	    /*Used to mark the end of the index I need to iterate through*/
    ldr r6, =0x1	    /*Mask to check last bit*/
    ldr r7, =0x80000000	    /*Used to add a bit after bit needs to move to the other word column*/
    word_loop:
    mov r9, 0		    /*r9 is used to hold the decision if we need to rotate bits or not*/
    add r2, r2, 8	    /*Shift buffer in r2 to skip over the top row (rowA00)*/
    ldr r4, [r1, 8]!	    /*Loading from buffer in r1*/
    ldr r5, [r1, 4]	    /*Loads the word over to r5 (word on the right) */
    
    and r3, r4, r6	    /*Mask what was loaded from buffer in r1*/
    cmp r3, 1		    /*Checking if there's a bit in the LS bit*/
    orreq r9, r9, 0b01	    /*This means we have to push the 2nd word out and put a bit in the MS bit position*/
    
    and r3, r5, r6	    /*Mask what was loaded from buffer in r1 + 4 which is a word over*/
    cmp r3, 1		    /*Checks if the LS bit is 1, if it is, we need move it to the other word in the same row*/
    orreq r9, r9, 0b10	    /*This means we have to push the 1st word and put a bit in the MS bit position*/
    
    /*These are the different scenarios that need to be handled in regards to the least significant bits*/
    cmp r9, 0b11	    /*This is scenario 0b11 meaning both words have a bit in their LS bit positions*/
    beq double_word_shift
    cmp r9, 0b01	    /*This is scenario 0b01 meaning the 1st word has a bit in their LS bit positions*/
    beq second_word_shift
    cmp r9, 0b10	    /*This is scenario 0b10 meaning the 2nd word has a bit in their LS bit positions*/
    beq first_word_shift
    
    /*No bits in the LS positions for both words(basically 0b00)*/
    /*Shifts both words without "rotating bits"*/
    lsr r4, r4, 1	/*Uses a logical shift right on the 1st word to move it right once and keep the bits moving to the right*/
    str r4, [r2]	/*Stores this new shifted result to the buffer in r2*/
    lsr r5, r5, 1	/*Uses a logical shift right on the 2nd word to move it right once and keep the bits moving to the right*/
    str r5, [r2, 4]	/*Stores the new value in r5 to the buffer's 2nd word in the current row. 4 is used to offet to the next word over.*/
    b continue
    first_word_shift:
    /*This means there's a bit in the LS bit position of the 2nd word and we need to put this in the MS bit position
     for the first word. This also means there isn't a bit in the LS bit position for word 1 so we just shift word 2*/
    lsr r4, r4, 1	/*Uses a logical shift right on the 1st word to move it right once and keep the bits moving to the right*/
    orr r4, r4, r7	/*OR bitwise r4 with the hex value in r7 to add a bit in the MS bit position in the 1st word */
    str r4, [r2]	/*Stores the new value in r4 to the buffer's 1st word in the current row*/
    
    lsr r5, r5, 1	/*Uses a logical shift right on the  2nd word to move it right once and keep the bits moving to the right*/
    str r5, [r2, 4]	/*Stores the new value in r5 to the buffer's 2nd word in the current row.*/
    b continue
    second_word_shift:
    /*This means there's a bit in the LS bit position of the 1st word and we need to put this in the MS bit position
     for the 2nd word. This also means there isn't a bit in the LS bit position for word 2 so we just shift word 1*/
    lsr r5, r5, 1	/*Uses a logical shift right on the 2nd word to move it right once and keep the bits moving to the right*/
    orr r5, r5, r7	/*OR bitwise r5 with the hex value in r7 to add a bit in the MS bit position in the 2nd word */
    str r5, [r2, 4]	/*Stores the new value in r5 to the buffer's 2nd word in the current row.*/
    
    lsr r4, r4, 1	/*Uses a logical shift right on the 1st word to move it right once and keep the bits moving to the right*/
    str r4, [r2]	/*Stores the new value in r4 to the buffer's 1st word in the current row*/
    b continue
    
    /*This means we have to shift both words and put a bit in their MS bit position*/
    double_word_shift: 
    /*Shift the 1st word*/
    lsr r4, r4, 1	/*Uses a logical shift right on the 1st word to move it right once and keep the bits moving to the right*/
    orr r4, r4, r7	/*OR bitwise r4 with the hex value in r7 to add a bit in the MS bit position in the 1st word */
    str r4, [r2]	/*Stores the new value in r4 to the buffer's 1st word in the current row*/

    /*Shift the 2nd word*/
    lsr r5, r5, 1	/*Uses a logical shift right on the 2nd word to move it right once and keep the bits moving to the right*/
    orr r5, r5, r7 	/*OR bitwise r5 with the hex value in r7 to add a bit in the MS bit position in the 2nd word */
    str r5, [r2, 4]	/*Stores the new value in r5 to the buffer's 2nd word in the current row.*/
    
    continue:		/*Simple label used as an anchor for code to branch to*/
    
    /*Checks to see if we're done looping, if not, loop again*/
    cmp r1, r8		/*r8 holds our r1 + 40 bytes and compares it against r1 as it increments on each loop*/
    bne word_loop	/*Will keep branching if r1 and r8 are not equal. It will stop once it's done looping through the rows*/
    
  
    b frame_done	/*Simply used to go over the Wave Subroutine below*/

    
    /*--------------------------------Wave Subroutine------------------------------------------*/
    /*Wave subroutine is called when first initalizing or if buf0 is in the original posiiton
     *This function sets buffer 1 to the original state then the left arm is modified*/
    wave:
    push {r4-r11, lr}	/*Save registers and lr*/
    
    ldr r0,=buf1	/*Calls buf1's mem address and loads it to r0*/
    ldr r1, =rowA00	/*Using rowA00 to initalize buf1 with*/
    ldr r4, [r1]	/*Loading rowA's data, into r4 to store into buf1*/
    str r4, [r0]	/*I'm making this intital load-store because I'm pre-indexing in the loop, else I won't be able to
			  initialize the first word in the first row of buf1*/
    add r3, r0, 156	/*Offsetting r3 to use as our stopper by 156 bytes as it'll put us at the end of our rows. Skipping over 
			   1 word because we called it in the load-store before this instruction*/
    
    wave_loop:
    ldr r4, [r1, 4]!	/*Pre-indexes with a writeback, the core of our loop to load*/
    str r4, [r0, 4]!	/*pre-indexes with a writeback, the core of our loop to store*/
    
    cmp r0, r3		/*Loop is going to compare until r0 equals r3 which means we looped through all our rows*/
    bne wave_loop 
    
    /*This code modifies the left arm in buffer 1. The hex numbers create the arm moving up*/
    ldr r0,=buf1	/*Simply loads r0 with buf1's mem address to load from it later*/
    ldr r4, =0x14	/*0000 0000 0000 0000 0000 0000 0001 0100*/
    str r4, [r0, 72]!	/*shifts to the row position where the arm starts which is rowA09 in the 1st word and overwrites it with the above value*/
    ldr r4, =0xB	/*0000 0000 0000 0000 0000 0000 0000 1011*/
    str r4, [r0, 8]!	/*Shifts r0 to the next row below which should be rowA10 in the 1st word and overwrites it with the above value*/
    ldr r4, =0x5	/*0000 0000 0000 0000 0000 0000 0000 0101*/
    str r4, [r0, 8]!	/*Shifts r0 to the next row below which should be rowA11 in the 1st word and overwrites it with the above value*/
    ldr r4, =0x3	/*0000 0000 0000 0000 0000 0000 0000 0011*/
    str r4, [r0, 8]!	/*Shifts r0 to the next row below which should be rowA12 in the 1st word and overwrites it with the above value*/
    
    pop {r4-r11, lr}    /* Restore saved registers and lr*/
    bx lr		/* Return from the function*/
    /*-----------------------------------------------------------------------------------------*/

     frame_done: /*I use this label to skip over the wave subroutines above*/
    
    
    
    /* STUDENT CODE ABOVE THIS LINE ^^^^^^^^^^^^^^^^^^^ */
    
    /* increment the frame counter */
    LDR r4,=asmFrameCounter
    LDR r5,[r4]  /* load counter from mem */
    ADD r5,r5,1  /* incr the counter */
    STR r5,[r4]  /* store it back to mem */
    
    LDR r0,=buf0 /* set the return value to buf0 */
    /* if the cycle count is an odd number set it to the alternate buffer */
    TST r5,1
    LDRNE r0,=buf1 
    B done /* branch for clarity... in case someone adds code after this. */
        
    done:
    
    /* STUDENTS:
     * If you just want to see the UFO, uncomment the next line.
     * But this is ONLY for demonstration purposes! Your final code
     * should flip between buf0 and buf1 and return one of those two. */
    
    /* LDR r0,=rowA00 */
 
    /* restore the caller's registers, as required by the ARM calling convention */
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




