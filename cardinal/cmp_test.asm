;; CMP Test Program
;; Function:
;; 1. Read 15 64-bit data entries from DMEM[0..14]
;; 2. Send all of them out through the NIC (SD + 0xC003)
;; 3. Receive 15 data entries back from the NIC (LD + 0xC001)
;; 4. Write the received data back to DMEM[16..30]
;; 5. Finally, perform a HALT (Hard Drive)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; --------------------------------------------------------------
;; Transmission Phase: Retrieve data from DMEM[0..14] and send it to the NIC
;; --------------------------------------------------------------

00: LD   r1, 0x0000      ; r1 = DMEM[0]
01: SD   r1, 0xC003      ; send r1 → NIC OUT_DATA

02: LD   r1, 0x0001      ; r1 = DMEM[1]
03: SD   r1, 0xC003

04: LD   r1, 0x0002
05: SD   r1, 0xC003

06: LD   r1, 0x0003
07: SD   r1, 0xC003

08: LD   r1, 0x0004
09: SD   r1, 0xC003

10: LD   r1, 0x0005
11: SD   r1, 0xC003

12: LD   r1, 0x0006
13: SD   r1, 0xC003

14: LD   r1, 0x0007
15: SD   r1, 0xC003

16: LD   r1, 0x0008
17: SD   r1, 0xC003

18: LD   r1, 0x0009
19: SD   r1, 0xC003

20: LD   r1, 0x000A
21: SD   r1, 0xC003

22: LD   r1, 0x000B
23: SD   r1, 0xC003

24: LD   r1, 0x000C
25: SD   r1, 0xC003

26: LD   r1, 0x000D
27: SD   r1, 0xC003

28: LD   r1, 0x000E
29: SD   r1, 0xC003


;; --------------------------------------------------------------
;; Receiving stage: Read 15 packets from the NIC and write them back to the DME.
;; The NIC read operation uses LD r1, 0xC001.
;; Since imm16[14:15] == 2'b01 → NIC_IN_DATA

30: LD   r1, 0xC001      ; r1 = NIC received packet 0
31: SD   r1, 0x0010      ; DMEM[16] = r1

32: LD   r1, 0xC001
33: SD   r1, 0x0011

34: LD   r1, 0xC001
35: SD   r1, 0x0012

36: LD   r1, 0xC001
37: SD   r1, 0x0013

38: LD   r1, 0xC001
39: SD   r1, 0x0014

40: LD   r1, 0xC001
41: SD   r1, 0x0015

42: LD   r1, 0xC001
43: SD   r1, 0x0016

44: LD   r1, 0xC001
45: SD   r1, 0x0017

46: LD   r1, 0xC001
47: SD   r1, 0x0018

48: LD   r1, 0xC001
49: SD   r1, 0x0019

50: LD   r1, 0xC001
51: SD   r1, 0x001A

52: LD   r1, 0xC001
53: SD   r1, 0x001B

54: LD   r1, 0xC001
55: SD   r1, 0x001C

56: LD   r1, 0xC001
57: SD   r1, 0x001D

58: LD   r1, 0xC001
59: SD   r1, 0x001E

60: BEZ  r0, +1          ; r0 永远为 0 → 永远跳转
61: NOP                  ; 被跳过
62: NOP                  ; HALT（F0000000）
