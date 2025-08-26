# CPU-Design

📌 프로젝트 개요

RISC-V RV32I 기반 CPU 설계 프로젝트

Single-Cycle → Multi-Cycle 구조로 확장하면서 CPU 성능 개선 과정 기록

Verilog/SystemVerilog 기반 설계 및 Synopsys VCS/Verdi 환경에서 검증 수행

CPU-Design/
├── docs/           # 설계 보고서, 참고 자료
├── rtl/            # Verilog/SystemVerilog RTL 코드
│   ├── single/     # Single-Cycle CPU
│   ├── multi/      # Multi-Cycle CPU
│   └── common/     # 공용 모듈(ALU, Register File 등)
├── tb/             # Testbench 코드
├── sim/            # 시뮬레이션 스크립트 및 결과
└── README.md

🛠️ 설계 단계
1. Single-Cycle CPU

모든 명령어를 1클록 내에서 수행

장점: 구조 단순, 직관적인 동작

단점: 가장 긴 명령어 지연시간에 맞춰 클록 → 성능 저하

2. Multi-Cycle CPU

명령어를 여러 사이클로 나누어 실행 (IF, ID, EX, MEM, WB)

장점: 평균 CPI 개선, 자원 효율적 사용

단점: 제어 회로 복잡성 증가

📊 지원 명령어 (RV32I)

R-Type: ADD, SUB, AND, OR, SLT ...

I-Type: ADDI, LW, JALR ...

S-Type: SW ...

B-Type: BEQ, BNE ...

U-Type: LUI, AUIPC

J-Type: JAL

🧪 검증 및 시뮬레이션

Testbench를 활용한 명령어 단위 검증

Dhrystone 및 간단한 RISC-V 프로그램 실행

VCS/Verdi로 파형 분석

| 구조           | 장점                  | 단점        |
| ------------ | ------------------- | --------- |
| Single-Cycle | 설계 단순, 직관적          | 클록 주기 길어짐 |
| Multi-Cycle  | 성능 개선, 자원 효율적 사용 가능 | 제어회로 복잡   |

📚 향후 발전

Pipeline CPU 설계

Hazard 제어 (Forwarding, Stall, Branch Prediction)

Cache & MMU 확장