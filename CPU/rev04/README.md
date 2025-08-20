## RISC-V RV32I Single Cycle

## 메모리 구조

- 스택 영역
- 힢 영역
- .bss  초기화 안된 전역 변수 영역
- .data 초기화 된 전역 변수 영역
- .text Code 영역

```c
int adder (int a, int b);

int main()
{
    int a, b, c;
    a = 10;
    b = 20;
    c = adder (a, b);
    
    return 0;
}

int adder(int a, int b)
{
    return a + b;
}
```

```bash
        li      sp, 0x40    # 초기화 => sp위치를 알려줘야 한다.
main:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32    # s0 = 처음 위치       
        li      a5,10       # a5 = 10
        sw      a5,-20(s0)  
        li      a5,20       # a5 = 20
        sw      a5,-24(s0)
        lw      a1,-24(s0)  # a1 = 20
        lw      a0,-20(s0)  # a1 = 10
        call    adder      
        sw      a0,-28(s0)
        li      a5,0
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
adder:
        addi    sp,sp,-32   
        sw      ra,28(sp)
        sw      s0,24(sp)   # s0 처음 위치
        addi    s0,sp,32    
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        lw      a4,-20(s0)  # a4 = 10
        lw      a5,-24(s0)  # a5 = 20
        add     a5,a4,a5    # a5 = 30
        mv      a0,a5       # a0 = 30
        lw      ra,28(sp)   # ra = 2c
        lw      s0,24(sp)   # s0 = s0
        addi    sp,sp,32    # sp RAM 처음
        jr      ra          # return address (2c)
```

```bash
Disassembly of section .text:

0000000000000000 :
   0:	04000113          	li	sp,64

0000000000000004 
:
   4:	fe010113          	addi	sp,sp,-32
   8:	00112e23          	sw	ra,28(sp)
   c:	00812c23          	sw	s0,24(sp)
  10:	02010413          	addi	s0,sp,32
  14:	00a00793          	li	a5,10
  18:	fef42623          	sw	a5,-20(s0)
  1c:	01400793          	li	a5,20
  20:	fef42423          	sw	a5,-24(s0)
  24:	fe842583          	lw	a1,-24(s0)
  28:	fec42503          	lw	a0,-20(s0)
  2c:	020000ef          	jal	ra,4c 
  30:	fea42223          	sw	a0,-28(s0)
  34:	00000793          	li	a5,0
  38:	00078513          	mv	a0,a5
  3c:	01c12083          	lw	ra,28(sp)
  40:	01812403          	lw	s0,24(sp)
  44:	02010113          	addi	sp,sp,32
  48:	00008067          	ret

000000000000004c :
  4c:	fe010113          	addi	sp,sp,-32
  50:	00112e23          	sw	ra,28(sp)
  54:	00812c23          	sw	s0,24(sp)
  58:	02010413          	addi	s0,sp,32
  5c:	fea42623          	sw	a0,-20(s0)
  60:	feb42423          	sw	a1,-24(s0)
  64:	fec42703          	lw	a4,-20(s0)
  68:	fe842783          	lw	a5,-24(s0)
  6c:	00f707b3          	add	a5,a4,a5
  70:	00078513          	mv	a0,a5
  74:	01c12083          	lw	ra,28(sp)
  78:	01812403          	lw	s0,24(sp)
  7c:	02010113          	addi	sp,sp,32
  80:	00008067          	ret

Disassembly of section .heap:

0000000000010000 <_sheap>:
	...

Disassembly of section .stack:

0000000000010200 <_estack>:
	...
```

``` bash
04000113
fe010113
00112e23
00812c23
02010413
00a00793
fef42623
01400793
fef42423
fe842583
fec42503
020000ef
fea42223
00000793
00078513
01c12083
01812403
02010113
00008067
fe010113
00112e23
00812c23
02010413
fea42623
feb42423
fec42703
fe842783
00f707b3
00078513
01c12083
01812403
02010113
00008067
```