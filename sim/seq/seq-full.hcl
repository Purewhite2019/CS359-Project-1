<<<<<<< HEAD
#/* $begin seq-all-hcl */
####################################################################
#  HCL Description of Control for Single Cycle Y86 Processor SEQ   #
#  Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2010       #
####################################################################

=======
#/* $begin seq-full-hcl */
####################################################################
#  HCL Description of Control for Single Cycle Y86 Processor SEQ   #
#  Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2010       #
#  "iaddl" & "leave" implemented by Qi Liu(519021910529)		   #
####################################################################

## Implementation Description:

## iaddl V, rB: <[0xC](4 bit), [fn=0x0](4 bit), [0xF](4 bit), rB(4 bit), V(4 byte)> ~ 6 byte, reference: CS:APP2e, P452
##
## Fetch: 		icode:ifun ← M(1)[PC]	(It seems that ifun doesn`t matter.)
##		  		rA:rB ← M(1)[PC+1]	(In fact rA doesn`t matter at all.)
##		  		valC ← M(4)[PC+2]
##		  		valP ← PC+6
## Decode: 		valB ← R[rB]
## Execute: 	valE ← valB + valC
##				Set CC
## Memory:
## Write Back: 	R[rB] ← valE
## PC update:	PC ← valP

## leave: <[0xD](4 bit), [fn=0x0](4 bit)> ~ 1 byte, reference: CS:APP2e, P453
## equivalent to:
##				rrmovl %ebp, %esp Set stack pointer to beginning of frame
##				popl %ebp Restore saved %ebp and set stack ptr to end of caller’s frame
##
## Fetch: 		icode:ifun ← M(1)[PC]	(It seems that ifun doesn`t matter.)
##		  		valP ← PC+1
## Decode: 		valA ← R[%ebp]
##				valB ← R[%ebp]
## Execute: 	valE ← valB + 4	(valA + 4 is also OK.)
## Memory:		valM ← M(4)[valA]
## Write Back: 	R[%esp] ← valE
##				R[%ebp] ← valM
## PC update:	PC ← valP


>>>>>>> dev-purewhite
## Your task is to implement the iaddl instruction
## The file contains a declaration of the icodes
## for iaddl (IIADDL) .
## Your job is to add the rest of the logic to make it work

####################################################################
#    C Include's.  Don't alter these                               #
####################################################################

quote '#include <stdio.h>'
quote '#include "isa.h"'
quote '#include "sim.h"'
quote 'int sim_main(int argc, char *argv[]);'
quote 'int gen_pc(){return 0;}'
quote 'int main(int argc, char *argv[])'
quote '  {plusmode=0;return sim_main(argc,argv);}'

####################################################################
#    Declarations.  Do not change/remove/delete any of these       #
####################################################################

##### Symbolic representation of Y86 Instruction Codes #############
intsig INOP 	'I_NOP'
intsig IHALT	'I_HALT'
intsig IRRMOVL	'I_RRMOVL'
intsig IIRMOVL	'I_IRMOVL'
intsig IRMMOVL	'I_RMMOVL'
intsig IMRMOVL	'I_MRMOVL'
intsig IOPL	'I_ALU'
intsig IJXX	'I_JMP'
intsig ICALL	'I_CALL'
intsig IRET	'I_RET'
intsig IPUSHL	'I_PUSHL'
intsig IPOPL	'I_POPL'
# Instruction code for iaddl instruction
intsig IIADDL	'I_IADDL'

<<<<<<< HEAD
=======
# Instruction code for leave instruction, added by Qi Liu(519021910529)
intsig ILEAVE	'I_LEAVE'

>>>>>>> dev-purewhite
##### Symbolic represenations of Y86 function codes                  #####
intsig FNONE    'F_NONE'        # Default function code

##### Symbolic representation of Y86 Registers referenced explicitly #####
intsig RESP     'REG_ESP'    	# Stack Pointer
intsig REBP     'REG_EBP'    	# Frame Pointer
intsig RNONE    'REG_NONE'   	# Special value indicating "no register"

##### ALU Functions referenced explicitly                            #####
intsig ALUADD	'A_ADD'		# ALU should add its arguments

##### Possible instruction status values                             #####
intsig SAOK	'STAT_AOK'		# Normal execution
intsig SADR	'STAT_ADR'	# Invalid memory address
intsig SINS	'STAT_INS'	# Invalid instruction
intsig SHLT	'STAT_HLT'	# Halt instruction encountered

##### Signals that can be referenced by control logic ####################

##### Fetch stage inputs		#####
intsig pc 'pc'				# Program counter
##### Fetch stage computations		#####
intsig imem_icode 'imem_icode'		# icode field from instruction memory
intsig imem_ifun  'imem_ifun' 		# ifun field from instruction memory
intsig icode	  'icode'		# Instruction control code
intsig ifun	  'ifun'		# Instruction function
intsig rA	  'ra'			# rA field from instruction
intsig rB	  'rb'			# rB field from instruction
intsig valC	  'valc'		# Constant from instruction
intsig valP	  'valp'		# Address of following instruction
boolsig imem_error 'imem_error'		# Error signal from instruction memory
boolsig instr_valid 'instr_valid'	# Is fetched instruction valid?

##### Decode stage computations		#####
intsig valA	'vala'			# Value from register A port
intsig valB	'valb'			# Value from register B port

##### Execute stage computations	#####
intsig valE	'vale'			# Value computed by ALU
boolsig Cnd	'cond'			# Branch test

##### Memory stage computations		#####
intsig valM	'valm'			# Value read from memory
boolsig dmem_error 'dmem_error'		# Error signal from data memory


####################################################################
#    Control Signal Definitions.                                   #
####################################################################

################ Fetch Stage     ###################################

# Determine instruction code
int icode = [
	imem_error: INOP;
	1: imem_icode;		# Default: get from instruction memory
];

# Determine instruction function
int ifun = [
	imem_error: FNONE;
	1: imem_ifun;		# Default: get from instruction memory
];

bool instr_valid = icode in 
	{ INOP, IHALT, IRRMOVL, IIRMOVL, IRMMOVL, IMRMOVL,
<<<<<<< HEAD
	       IOPL, IJXX, ICALL, IRET, IPUSHL, IPOPL };
=======
	       IOPL, IJXX, ICALL, IRET, IPUSHL, IPOPL, IIADDL, ILEAVE };
>>>>>>> dev-purewhite

# Does fetched instruction require a regid byte?
bool need_regids =
	icode in { IRRMOVL, IOPL, IPUSHL, IPOPL, 
<<<<<<< HEAD
		     IIRMOVL, IRMMOVL, IMRMOVL };

# Does fetched instruction require a constant word?
bool need_valC =
	icode in { IIRMOVL, IRMMOVL, IMRMOVL, IJXX, ICALL };
=======
		     IIRMOVL, IRMMOVL, IMRMOVL, IIADDL };

# Does fetched instruction require a constant word?
bool need_valC =
	icode in { IIRMOVL, IRMMOVL, IMRMOVL, IJXX, ICALL, IIADDL };
>>>>>>> dev-purewhite

################ Decode Stage    ###################################

## What register should be used as the A source?
int srcA = [
	icode in { IRRMOVL, IRMMOVL, IOPL, IPUSHL  } : rA;
	icode in { IPOPL, IRET } : RESP;
<<<<<<< HEAD
=======
	icode == ILEAVE : REBP;
>>>>>>> dev-purewhite
	1 : RNONE; # Don't need register
];

## What register should be used as the B source?
int srcB = [
<<<<<<< HEAD
	icode in { IOPL, IRMMOVL, IMRMOVL  } : rB;
	icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
=======
	icode in { IOPL, IRMMOVL, IMRMOVL, IIADDL  } : rB;
	icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
	icode == ILEAVE : REBP;
>>>>>>> dev-purewhite
	1 : RNONE;  # Don't need register
];

## What register should be used as the E destination?
int dstE = [
	icode in { IRRMOVL } && Cnd : rB;
<<<<<<< HEAD
	icode in { IIRMOVL, IOPL} : rB;
	icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
=======
	icode in { IIRMOVL, IOPL, IIADDL} : rB;
	icode in { IPUSHL, IPOPL, ICALL, IRET, ILEAVE } : RESP;
>>>>>>> dev-purewhite
	1 : RNONE;  # Don't write any register
];

## What register should be used as the M destination?
int dstM = [
	icode in { IMRMOVL, IPOPL } : rA;
<<<<<<< HEAD
=======
	icode == ILEAVE : REBP;
>>>>>>> dev-purewhite
	1 : RNONE;  # Don't write any register
];

################ Execute Stage   ###################################

## Select input A to ALU
int aluA = [
	icode in { IRRMOVL, IOPL } : valA;
<<<<<<< HEAD
	icode in { IIRMOVL, IRMMOVL, IMRMOVL } : valC;
	icode in { ICALL, IPUSHL } : -4;
	icode in { IRET, IPOPL } : 4;
=======
	icode in { IIRMOVL, IRMMOVL, IMRMOVL, IIADDL } : valC;
	icode in { ICALL, IPUSHL } : -4;
	icode in { IRET, IPOPL, ILEAVE } : 4;
>>>>>>> dev-purewhite
	# Other instructions don't need ALU
];

## Select input B to ALU
int aluB = [
	icode in { IRMMOVL, IMRMOVL, IOPL, ICALL, 
<<<<<<< HEAD
		      IPUSHL, IRET, IPOPL } : valB;
=======
		      IPUSHL, IRET, IPOPL, IIADDL, ILEAVE } : valB;
>>>>>>> dev-purewhite
	icode in { IRRMOVL, IIRMOVL } : 0;
	# Other instructions don't need ALU
];

## Set the ALU function
int alufun = [
	icode == IOPL : ifun;
	1 : ALUADD;
];

## Should the condition codes be updated?
<<<<<<< HEAD
bool set_cc = icode in { IOPL };
=======
bool set_cc = icode in { IOPL, IIADDL };
>>>>>>> dev-purewhite

################ Memory Stage    ###################################

## Set read control signal
<<<<<<< HEAD
bool mem_read = icode in { IMRMOVL, IPOPL, IRET };
=======
bool mem_read = icode in { IMRMOVL, IPOPL, IRET, ILEAVE };
>>>>>>> dev-purewhite

## Set write control signal
bool mem_write = icode in { IRMMOVL, IPUSHL, ICALL };

## Select memory address
int mem_addr = [
	icode in { IRMMOVL, IPUSHL, ICALL, IMRMOVL } : valE;
<<<<<<< HEAD
	icode in { IPOPL, IRET } : valA;
=======
	icode in { IPOPL, IRET, ILEAVE } : valA;
>>>>>>> dev-purewhite
	# Other instructions don't need address
];

## Select memory input data
int mem_data = [
	# Value from register
	icode in { IRMMOVL, IPUSHL } : valA;
	# Return PC
	icode == ICALL : valP;
	# Default: Don't write anything
];

## Determine instruction status
int Stat = [
	imem_error || dmem_error : SADR;
	!instr_valid: SINS;
	icode == IHALT : SHLT;
	1 : SAOK;
];

################ Program Counter Update ############################

## What address should instruction be fetched at

int new_pc = [
	# Call.  Use instruction constant
	icode == ICALL : valC;
	# Taken branch.  Use instruction constant
	icode == IJXX && Cnd : valC;
	# Completion of RET instruction.  Use value from stack
	icode == IRET : valM;
	# Default: Use incremented PC
	1 : valP;
];
<<<<<<< HEAD
#/* $end seq-all-hcl */
=======
#/* $end seq-full-hcl */
>>>>>>> dev-purewhite
