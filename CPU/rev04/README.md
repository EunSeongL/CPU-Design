## RISC-V RV32I Single Cycle

## 메모리 구조

- 스택 영역
- 힢 영역
- .bss  초기화 안된 전역 변수 영역
- .data 초기화 된 전역 변수 영역
- .text Code 영역

---
## Bubble Sorting C Code, Assemblier 분석하기
> Memory 공간에 Stack 영역의 변화과정과 변수의 Memory 할당 방식 이해
  배열, 포인터 동작 방식을 Memory 관점에서 분석하시오.
  Memory 그림을 그리면서 분석, Register File의 Register 할당 ABIname을 보면서 할당 방식 이해
  어셈블리어 명령 할당 하나하나 Memory와 RegFile 상호작용 내용을 글로 적으면서 분석하시오

## 정리
> **ABI(Application Binary Interface)** 
  ABI는 컴퓨터 과학의 저수준(low-level)에서, 컴파일된 애플리케이션 코드와 운영체제 또는 다른 라이브러리 간의 인터페이스를 정의하는 규약

```c
void sort(int *pData, int size);
void swap(int *pA, int *pB);

int main()
{
    int arData[6] = {5,4,3,2,1};

    sort(arData, 5);

    return 0;
}

void sort(int *pData, int size)
{
    for(int i = 0; i < size; i++){
        for(int j = 0; j < size - i - 1; j++){
            if(pData[j] > pData[j+1]) swap(&pData[j], &pData[j+1]);
        }
    }
}

void swap(int *pA, int *pB)
{
    int temp;
    temp = *pA;
    *pA = *pB;
    *pB = temp;
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
   4:	fd010113          	addi	sp,sp,-48
   8:	02112623          	sw	ra,44(sp)
   c:	02812423          	sw	s0,40(sp)
  10:	03010413          	addi	s0,sp,48
  14:	fc042c23          	sw	zero,-40(s0)
  18:	fc042e23          	sw	zero,-36(s0)
  1c:	fe042023          	sw	zero,-32(s0)
  20:	fe042223          	sw	zero,-28(s0)
  24:	fe042423          	sw	zero,-24(s0)
  28:	fe042623          	sw	zero,-20(s0)
  2c:	00500793          	li	a5,5
  30:	fcf42c23          	sw	a5,-40(s0)
  34:	00400793          	li	a5,4
  38:	fcf42e23          	sw	a5,-36(s0)
  3c:	00300793          	li	a5,3
  40:	fef42023          	sw	a5,-32(s0)
  44:	00200793          	li	a5,2
  48:	fef42223          	sw	a5,-28(s0)
  4c:	00100793          	li	a5,1
  50:	fef42423          	sw	a5,-24(s0)
  54:	fd840793          	addi	a5,s0,-40
  58:	00500593          	li	a1,5
  5c:	00078513          	mv	a0,a5
  60:	01c000ef          	jal	ra,7c 
  64:	00000793          	li	a5,0
  68:	00078513          	mv	a0,a5
  6c:	02c12083          	lw	ra,44(sp)
  70:	02812403          	lw	s0,40(sp)
  74:	03010113          	addi	sp,sp,48
  78:	00008067          	ret

000000000000007c :
  7c:	fd010113          	addi	sp,sp,-48
  80:	02112623          	sw	ra,44(sp)
  84:	02812423          	sw	s0,40(sp)
  88:	03010413          	addi	s0,sp,48
  8c:	fca42e23          	sw	a0,-36(s0)
  90:	fcb42c23          	sw	a1,-40(s0)
  94:	fe042623          	sw	zero,-20(s0)
  98:	09c0006f          	j	134 
  9c:	fe042423          	sw	zero,-24(s0)
  a0:	0700006f          	j	110 
  a4:	fe842783          	lw	a5,-24(s0)
  a8:	00279793          	slli	a5,a5,0x2
  ac:	fdc42703          	lw	a4,-36(s0)
  b0:	00f707b3          	add	a5,a4,a5
  b4:	0007a703          	lw	a4,0(a5)
  b8:	fe842783          	lw	a5,-24(s0)
  bc:	00178793          	addi	a5,a5,1
  c0:	00279793          	slli	a5,a5,0x2
  c4:	fdc42683          	lw	a3,-36(s0)
  c8:	00f687b3          	add	a5,a3,a5
  cc:	0007a783          	lw	a5,0(a5)
  d0:	02e7da63          	ble	a4,a5,104 
  d4:	fe842783          	lw	a5,-24(s0)
  d8:	00279793          	slli	a5,a5,0x2
  dc:	fdc42703          	lw	a4,-36(s0)
  e0:	00f706b3          	add	a3,a4,a5
  e4:	fe842783          	lw	a5,-24(s0)
  e8:	00178793          	addi	a5,a5,1
  ec:	00279793          	slli	a5,a5,0x2
  f0:	fdc42703          	lw	a4,-36(s0)
  f4:	00f707b3          	add	a5,a4,a5
  f8:	00078593          	mv	a1,a5
  fc:	00068513          	mv	a0,a3
 100:	058000ef          	jal	ra,158 
 104:	fe842783          	lw	a5,-24(s0)
 108:	00178793          	addi	a5,a5,1
 10c:	fef42423          	sw	a5,-24(s0)
 110:	fd842703          	lw	a4,-40(s0)
 114:	fec42783          	lw	a5,-20(s0)
 118:	40f707b3          	sub	a5,a4,a5
 11c:	fff78793          	addi	a5,a5,-1
 120:	fe842703          	lw	a4,-24(s0)
 124:	f8f740e3          	blt	a4,a5,a4 
 128:	fec42783          	lw	a5,-20(s0)
 12c:	00178793          	addi	a5,a5,1
 130:	fef42623          	sw	a5,-20(s0)
 134:	fec42703          	lw	a4,-20(s0)
 138:	fd842783          	lw	a5,-40(s0)
 13c:	f6f740e3          	blt	a4,a5,9c 
 140:	00000013          	nop
 144:	00000013          	nop
 148:	02c12083          	lw	ra,44(sp)
 14c:	02812403          	lw	s0,40(sp)
 150:	03010113          	addi	sp,sp,48
 154:	00008067          	ret

0000000000000158 :
 158:	fd010113          	addi	sp,sp,-48
 15c:	02112623          	sw	ra,44(sp)
 160:	02812423          	sw	s0,40(sp)
 164:	03010413          	addi	s0,sp,48
 168:	fca42e23          	sw	a0,-36(s0)
 16c:	fcb42c23          	sw	a1,-40(s0)
 170:	fdc42783          	lw	a5,-36(s0)
 174:	0007a783          	lw	a5,0(a5)
 178:	fef42623          	sw	a5,-20(s0)
 17c:	fd842783          	lw	a5,-40(s0)
 180:	0007a703          	lw	a4,0(a5)
 184:	fdc42783          	lw	a5,-36(s0)
 188:	00e7a023          	sw	a4,0(a5)
 18c:	fd842783          	lw	a5,-40(s0)
 190:	fec42703          	lw	a4,-20(s0)
 194:	00e7a023          	sw	a4,0(a5)
 198:	00000013          	nop
 19c:	02c12083          	lw	ra,44(sp)
 1a0:	02812403          	lw	s0,40(sp)
 1a4:	03010113          	addi	sp,sp,48
 1a8:	00008067          	ret

Disassembly of section .heap:

0000000000010000 <_sheap>:
	...

Disassembly of section .stack:

0000000000010200 <_estack>:
	...
```
