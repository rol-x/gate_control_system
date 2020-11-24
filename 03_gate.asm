CLK			EQU P1.0			// Reference clock input.
PHOTOCELL	EQU P1.1			// Photocell sensor.
CLOSED		EQU P1.2			// Gate closed sensor.
OPEN		EQU P1.3			// Gate open sensor.
CONTROL		EQU P1.7			// Gate operating button.
MOTOR_CLOSE	EQU P3.2			// Motor closing operation (output signal).	
MOTOR_OPEN	EQU P3.3			// Motor opening operation (output signal).
OPEN_TIME	EQU 255				// Gate maximal open time before closing automatically.

DSEG AT 30
TIMER:		DS 1			// Timeout variable.

CSEG AT 0
RESET:
// Initialization.
	MOV		SP, #7FH
	MOV		P1, #0
	MOV		P3, #0
 	SETB	CLOSED

GATE_CLOSED:
	CLR		MOTOR_CLOSE
// Gate is closed until the button is pressed.
    JNB		CONTROL, $
// Buttons are instantaneously reset to mimic the behaviour of a real button.
	CLR 	CONTROL
// Initiate opening.
	SJMP	GATE_OPENING		// For clarity.
	
GATE_OPENING:
	CLR		MOTOR_CLOSE
	SETB	MOTOR_OPEN
// Gate is opening until the button is pressed again (revert to closing) or the gate is opened fully.
	CLR		CLOSED
	JNB		CLK, $
// Check the control button.
	JNB		CONTROL, CONT_OPENING
	CLR		CONTROL
	SJMP	GATE_CLOSING
CONT_OPENING:
	JNB		OPEN, GATE_OPENING
// Set the TIMEOUT.
	MOV		TIMER, OPEN_TIME
	SJMP	GATE_OPEN			// For clarity.

GATE_OPEN:
	CLR		MOTOR_OPEN
// Gate is open for set amount of time or until the button is pressed, provided there are no obstacles.
	JNB		CLK, $
	JB		CONTROL, CHECK_PHOTOCELL
	DJNZ	TIMER, GATE_OPEN
// When timeout reaches 0, is it reset to start over if there are obstacles.
	MOV		TIMER, OPEN_TIME
// Pressing the operating button, as well as waiting, initiates the photocell check before.
CHECK_PHOTOCELL:
	CLR		CONTROL
	JNB		PHOTOCELL, GATE_CLOSING
	SJMP	GATE_OPEN
	
GATE_CLOSING:
	CLR		MOTOR_OPEN
	SETB	MOTOR_CLOSE
// Gate is closing until the button is pressed or an obstacle is detected, or the gate is closed fully.
	CLR		OPEN
	JNB		CLK, $
// Check the photocell.
	JB		PHOTOCELL, GATE_OPENING
// Check the control button.
	JNB		CONTROL, CONT_CLOSING
	CLR		CONTROL
	SJMP	GATE_OPENING
CONT_CLOSING:
	JNB		CLOSED, GATE_CLOSING
	SJMP	GATE_CLOSED

END
