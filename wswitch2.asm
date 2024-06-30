format PE64 console

entry main

section ".code" code readable executable

macro wswitch wkey {
	common
	local switchID
	
	wswitch.ID equ switchID
	
	macro case key \{
		\local caseID
		switchID#.case equ caseID
		caseID\#.key equ key
		
		.\#caseID\#.def:
	\}
	
	macro default \{
		case
	\}
	
	macro break \{
		jmp .#switchID#.continue
	\}
	
	macro end.switch \{
		vpbroadcastw	ymm0,wkey
		mov	rcx,.#switchID#.keys
		
		@@:
		vpcmpeqw	ymm1,ymm0,[rcx]
		vpcmpeqw	ymm2,ymm0,[rcx + 0x20]
		vpackuswb	ymm1,ymm2,ymm1
		vpermq	ymm1,ymm1,11011000b
		vpmovmskb	edx,ymm1
		lzcnt	eax,edx
		test	edx,edx
		jnz	@f
		add	rcx,0x40
		cmp	rcx,.#switchID#.keys.end
		jb	@b
		jmp	.#switchID#.default
		
		align	4
		@@:
		lea	rcx,[rcx + rax * 2 - .#switchID#.keys]
		cmp	rcx,.#switchID#.keys.end - .#switchID#.keys
		jae	.#switchID#.default
		jmp	qword[.#switchID#.entry + rcx * 4]
		
		switchID#.mac
		jmp	.#switchID#.continue
		
		align 64
		.#switchID#.keys:
		irpv caseid, switchID#.case \\{
			if caseid\\#.key eq
				.#switchID#.default = .\\#caseid\\#.def
			else
				dw caseid\\#.key
			end if
		\\}
		if .#switchID#.default eq
			.#switchID#.default = .#switchID#.continue
		end if
		.#switchID#.keys.end:
		
		align 64
		.#switchID#.entry:
		irpv caseid, switchID#.case \\{
			if ~caseid\\#.key eq
				dq .\\#caseid\\#.def
			end if
		\\}
		.#switchID#.entry.end:
		align 64
		
		purge case
		purge default
		purge break
		purge end.switch
		.#switchID#.continue:
	\}
	macro switchID#.mac
}

main:
	wswitch [test0]
	{case 1
		mov	ebx,1
		break
	case 2
	case 3
	case 4
	case 5
	case 6
	case 7
	case 10
		wswitch [test1]
		\{case 0
		case 1
		case 3
		default
		\}end.switch
		break
	default
	}end.switch

section ".data" data writeable
test0	dw 10
test1	dw 3

section ".import" import data readable

