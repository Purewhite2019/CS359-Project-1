	.file	"ncopy.c"
	.text
	.p2align 4
	.globl	ncopy
	.type	ncopy, @function
ncopy:
.LFB0:
	.cfi_startproc
	endbr64
	testl	%edx, %edx
	jle	.L14
	leaq	15(%rdi), %rax
	subq	%rsi, %rax
	cmpq	$30, %rax
	leal	-1(%rdx), %eax
	jbe	.L3
	cmpl	$4, %eax
	jbe	.L3
	movl	%edx, %ecx
	pxor	%xmm1, %xmm1
	xorl	%eax, %eax
	shrl	$2, %ecx
	movdqa	%xmm1, %xmm2
	salq	$4, %rcx
	.p2align 4,,10
	.p2align 3
.L4:
	movdqu	(%rdi,%rax), %xmm0
	movups	%xmm0, (%rsi,%rax)
	pcmpgtd	%xmm2, %xmm0
	addq	$16, %rax
	psubd	%xmm0, %xmm1
	cmpq	%rcx, %rax
	jne	.L4
	movdqa	%xmm1, %xmm0
	movl	%edx, %r8d
	psrldq	$8, %xmm0
	andl	$-4, %r8d
	paddd	%xmm0, %xmm1
	movl	%r8d, %ecx
	movdqa	%xmm1, %xmm0
	salq	$2, %rcx
	psrldq	$4, %xmm0
	addq	%rcx, %rdi
	addq	%rcx, %rsi
	movl	%edx, %ecx
	paddd	%xmm0, %xmm1
	subl	%r8d, %ecx
	movd	%xmm1, %eax
	cmpl	%r8d, %edx
	je	.L1
	movl	(%rdi), %edx
	testl	%edx, %edx
	movl	%edx, (%rsi)
	setg	%dl
	movzbl	%dl, %edx
	addl	%edx, %eax
	cmpl	$1, %ecx
	je	.L1
	movl	4(%rdi), %edx
	testl	%edx, %edx
	movl	%edx, 4(%rsi)
	setg	%dl
	movzbl	%dl, %edx
	addl	%edx, %eax
	cmpl	$2, %ecx
	je	.L1
	movl	8(%rdi), %edx
	testl	%edx, %edx
	movl	%edx, 8(%rsi)
	setg	%dl
	movzbl	%dl, %edx
	addl	%edx, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L14:
	xorl	%eax, %eax
.L1:
	ret
	.p2align 4,,10
	.p2align 3
.L3:
	movl	%eax, %r8d
	xorl	%edx, %edx
	xorl	%eax, %eax
	jmp	.L12
	.p2align 4,,10
	.p2align 3
.L15:
	movq	%rcx, %rdx
.L12:
	movl	(%rdi,%rdx,4), %ecx
	testl	%ecx, %ecx
	movl	%ecx, (%rsi,%rdx,4)
	setg	%cl
	movzbl	%cl, %ecx
	addl	%ecx, %eax
	leaq	1(%rdx), %rcx
	cmpq	%r8, %rdx
	jne	.L15
	ret
	.cfi_endproc
.LFE0:
	.size	ncopy, .-ncopy
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
