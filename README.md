<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright © Telecom Paris
Copyright © Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
https://cecill.info/licences/Licence_CeCILL_V2.1-en.html
-->

The final project of the DigitalSystems course

---

[TOC]

---

# Summary

The goal of the project is to implement a message encryption and decryption system.
The input messages and output messages are stored in the external memory.
A hardware accelerator mapped in the FPGA fabric of the Zynq core is used to speed up the cryptographic operations.
The software part that runs on the ARM processor stores a message to encrypt or decrypt in memory.
It then configures the hardware accelerator by storing parameters in its interface registers:

- a secret key,
- an initialization vector,
- the address of the input message in memory,
- the address of the output message in memory,
- the byte length of the input message.

The software launches the processing and the hardware accelerator runs autonomously until the complete message has been processed and the output message stored in memory.
The software controls the hardware accelerator thanks to 2 more interface registers: a control register which content modifies the behaviour of the accelerator (soft reset, freeze...), and a status register which content reflects the current state of the accelerator (busy or not, error situations...)

# Evaluation

The project accounts for 50% of the final grade.
All members of the group will get the same grade.
It will be evaluated based on your source code and your report which you will write in markdown format in the `/REPORT.md` file.
Do not neglect the report, it will have a significant weight.
Keep it short but complete:

- Provide block diagrams with a clear identification of the registers and of the combinatorial parts; name the registers, explain what the combinatorial parts do.
- Provide state diagrams and detailed explanations for your state machines.
- Explain what each VHDL source file contains and what its role is in the global picture.
- Detail and motivate your design choices (partitioning, scheduling of operations...)
- Explain how you validated each part.
- Comment your synthesis results (maximum clock frequency, resource usage...)
- Provide an overview of the performance of your cryptographic accelerator (e.g., in Mb/s).
- Document the companion software components you developed (drivers, scripts, libraries...)
- Provide a user documentation showing how to use your cryptographic accelerator and its companion software components.
- ...

The deadline for the submission of source codes and report is the day **before** the written exam at 23:59.
It is a sharp deadline after which the repository will become read-only and there will be no way to modify anything any more.
Your source codes and your report must be pushed before the deadline in a branch named `final` of your project's git repository.
Please check twice that you did not forget anything in another branch, the `final` branch is the only branch that will be considered.

# Use of existing resources

Smart engineers optimize their work by reusing what can reasonably be reused.
Smart reuse of existing resources is thus encouraged and will be rewarded if and only if:

- You cite the original source, explain why you decided to use it, what you changed, why and how.
- It is **not** parts of the work of other groups, even after obfuscation, renaming of user identifiers...
  Plagiarism is not accepted.
  
About VHDL code that you may find on Internet: be careful, my experience shows that most of it was written by students like you, not by experts.
A significant proportion does not work at all and contains basic errors showing that the authors did not really understand digital hardware design and/or hardware description languages like VHDL.
Another significant proportion is written at a disappointing low level (e.g., one entity/architecture pair for any 2 inputs multiplexer).
Sometimes the VHDL code you find was generated automatically from gate-level entry GUI tools, automatically translated into VHDL from another language, or from a netlist obtained after logic synthesis.
So, before reusing such code, please look at it carefully and ask yourself if it's really worth reusing.

A validated VHDL design with its simulation environment is of much higher value than a not validated VHDL design without a simulation environment.
So, try to also design simulation environments and to validate what you did by simulation.

# Functional specifications

The hardware accelerator is named `crypto`.
It communicates with its environment with a 32-bits AXI4 lite slave interface `s0_axi` and a 32-bits AXI4 lite master interface `m0_axi`.
It receives parameters and commands from `s0_axi`.
The environment also uses `s0_axi` to read status information about `crypto`.
`crypto` reads the input message and writes the encrypted message through `m0_axi` (it is what is called a Direct Memory Access (DMA) capable peripheral).

![`crypto` in its environment](../../images/crypto_in_environment-fig.png)  
_`crypto` in its environment_

## Encryption / decryption

`crypto` encrypts and decrypts messages with a symmetric block cipher (denoted BC in the following) used in _counter mode_.
Different block ciphers are allocated to the different groups but all block ciphers have 128 bits secret keys and 128 bits blocks.
In case your block cipher supports other key or block lengths ignore them and implement only the 128 bits variant.
In _counter mode_ the underlying block cipher is used only to encrypt, you can thus safely ignore the decryption part of the specification of your block cipher.
BC can be considered as a function of two 128 bits parameters, the key K and the input block A; it returns the 128 bits encrypted block BC(K, A).

`crypto` can encrypt and decrypt arbitrary length messages (up to the size of the memory that stores them).
Input messages are padded prior being passed to `crypto` such that their length is always a multiple of 128 bits.
Input messages are split in 128 bits blocks and the blocks are processed independently, one after the other.
If the length of input message P is 128 x n bits, we denote P(1), ..., P(n) the n blocks and C(1), ..., C(n) the corresponding output blocks.

The _counter mode_ uses a 128 bits counter CNT split in a 96 bits left part CNT[127..32] and a 32 bits right part CNT[31..0].
The counter is initialized with a 128 bits Initial Counter Block value: ICB.
The encryption (or decryption) of a n-blocks input message P with secret key K and Initial Counter Block ICB is as follows, where `XOR` is the bitwise exclusive OR and `^` is the exponentiation:

```
CNT <-- ICB
for i = 1 to n {
  C(i) <-- P(i) XOR BC(K, CNT)
  CNT[31..0] <-- (CNT[31..0] + 1) mod 2^32
}
```

A nice property of the counter mode is that decryption is exactly the same as encryption, with the same secret key and the same ICB, such that encrypting twice produces the original input message.
A drawback is that the same counter value shall never be used to encrypt more than one block with the same secret key, else the security is compromised.
This can be guaranteed by limiting the length of the input messages to $2^{32} \times 128$ bits (64 GB), and by always using a fresh value for the 96 bits leftmost part of ICB to encrypt a new message.

## The `s0_axi` 32-bits AXI4 lite slave interface

The `s0_axi` 32-bits AXI4 lite slave interface is used by the environment to access the interface registers of `crypto`.
The address buses are 12-bits wide (the minimum supported by Xilinx tools).
The corresponding 4kB address space is the following (byte offsets from the base address of `crypto`):

| Name   | Byte offset | Byte length | Description                           |
| :----  | :----       | :----       | :----                                 |
| K      | 0           | 16          | secret Key                            |
| ICB    | 16          | 16          | Initial Counter Block                 |
| IBA    | 32          | 4           | Input Byte Address, multiple of 16    |
| OBA    | 36          | 4           | Output Byte Address, multiple of 16   |
| MBL    | 40          | 4           | Message Byte Length, multiple of 16   |
| CTRL   | 44          | 4           | ConTRoL register                      |
| STATUS | 48          | 4           | STATUS register                       |
| -      | 52          | 4044        | unmapped                              |

You can add more interface registers in the unmapped region if you wish (debugging, timer for performance measurements...)
CPU read or write accesses to unmapped addresses shall receive a DECERR response.
All CPU accesses are considered word-aligned: the 2 LSB of the read and write addresses are ignored; reading at addresses 0, 1, 2 or 3 returns the same 32 bits word.

IBA (OBA) is the byte address in memory of the first byte of the input (output) message; it is aligned on a 128-bits (16 bytes) boundary.
MBL is the byte length of the input (and output) message; it is also a multiple of 16.
To guarantee that IBA, OBA and MBL are multiples of 16 their four Least Significant Bits (LSB) are hard-wired to zero: they always read as zeros and writing them has no effect.
`crypto` is little endian: the rightmost byte of K (K[7..0]) is stored at byte offset 0 and the leftmost byte of K (K[127..120]) is stored at byte offset 15; same for the other parameters.
Remember that the ARM processor is also little endian; when it reads a 32-bits word (4 bytes) at byte offset 4 we should have `s0_axi_rdata(0) = K[32]` and `s0_axi_rdata(31) = K[63]`.

The 32-bits CTRL register is represented on the following figure:

![The CTRL control register](../../images/ctrl-fig.png)  
_The CTRL control register_

- RST is a soft active high ReSeT; when RST is high `crypto` is entirely reset, except of course its `s0_axi` interface and its interface registers (else it would be impossible to recover from a soft reset).
- CE is a Chip Enable flag; when CE is low (and RST is low) `crypto` is entirely frozen, all registers keep their current value, except of course its `s0_axi` interface and its interface registers (else it would be impossible to recover from a chip disable).
- IE is an Interrupt Enable flag; when IE is high, and a message processing ends, `crypto` raises its `irq` output for one clock period; when IE is low `irq` is maintained low, even at the end of a message processing.

Writing the other bits has no effect; they read as zero.

The 32-bits STATUS register is represented on the following figure:

![The STATUS status register](../../images/status-fig.png)  
_The STATUS status register_

- BSY is a BuSY flag; when a message processing is ongoing BSY is high, else, when `crypto` is idle, BSY is low.
- EOP is a End Of Processing flag; when a message processing ends, even if it is because an error was encountered, EOP is set to one.
- ERR is an ERRor flag; when an AXI4 read/write error is encountered on `m0_axi` during a processing, the processing ends immediately (after the ongoing transactions on `s0_axi` and `m0_axi` are properly terminated according the AXI4 protocol) and the ERR flag is set to one.
- CAUSE is a 3-bits error code indicating the cause of an error:

  | Code  | Description                      |
  | :---- | :----                            |
  | 000   | No error (reset value)           |
  | 010   | Read slave error (AXI4 SLVERR)   |
  | 011   | Read decode error (AXI4 DECERR)  |
  | 110   | Write slave error (AXI4 SLVERR)  |
  | 111   | Write decode error (AXI4 DECERR) |
  | Other | Reserved                         |

When STATUS is read the current value of EOP and ERR are returned as part of the read word, after which EOP and ERR are set to zero.
When STATUS is written the written value is ignored; if `crypto` is idle (BSY is low) this write operation is considered as a start processing command, else it is ignored.

**Important**: IBA, OBA, MBL, K and ICB are valid only when the STATUS register is written to start a new message processing.
The cryptographic engine shall not rely on them past the start command because the environment can modify them any time to prepare for the next message processing.
When a start processing command is detected (and `crypto` is not busy) the content of IBA, OBA, MBL, K and ICB must thus be copied inside the cryptographic engine, before the next write request on `s0_axi` is served, and it is these copies that must be used during the current message processing.

## The `m0_axi` 32-bits AXI4 lite master interface

The `m0_axi` 32-bits AXI4 lite master interface is used by `crypto` to read the input message and to write the encrypted message from/to memory.
The address buses are 32-bits wide, that is a total address space of 4GB.
The input message and the encrypted message are stored somewhere in this address space in little endian order: if the starting byte address of the memory region to process is IBA, P(1)[7..0] is stored at address IBA, P(1)[127..120] at address IBA+15, P2[7..0] at address IBA+16...
Again, as the ARM processor is also little endian, when reading a 32-bits word (4 bytes) at address IBA+8 we should have `m0_axi_rdata(0) = P(1)[64]` and `m0_axi_rdata(31) = P(1)[95]`.

# Interface specifications

The interface of `crypto` is the following:

| Name             | Type                             | Direction | Description                                                |
| :----            | :----                            | :----     | :----                                                      |
| `aclk`           | `std_ulogic`                     | in        | master clock                                               |
| `aresetn`        | `std_ulogic`                     | in        | **synchronous** active **low** reset                       |
| `s0_axi_araddr`  | `std_ulogic_vector(11 downto 0)` | in        | read address from CPU (12 bits = 4kB)                      |
| `s0_axi_arvalid` | `std_ulogic`                     | in        | read address valid from CPU                                |
| `s0_axi_arready` | `std_ulogic`                     | out       | read address acknowledge to CPU                            |
| `s0_axi_awaddr`  | `std_ulogic_vector(11 downto 0)` | in        | write address from CPU (12 bits = 4kB)                     |
| `s0_axi_awvalid` | `std_ulogic`                     | in        | write address valid flag from CPU                          |
| `s0_axi_awready` | `std_ulogic`                     | out       | write address acknowledge to CPU                           |
| `s0_axi_wdata`   | `std_ulogic_vector(31 downto 0)` | in        | write data from CPU                                        |
| `s0_axi_wstrb`   | `std_ulogic_vector(3 downto 0)`  | in        | write byte enables from CPU                                |
| `s0_axi_wvalid`  | `std_ulogic`                     | in        | write data and byte enables valid from CPU                 |
| `s0_axi_wready`  | `std_ulogic`                     | out       | write data and byte enables acknowledge to CPU             |
| `s0_axi_rdata`   | `std_ulogic_vector(31 downto 0)` | out       | read data response to CPU                                  |
| `s0_axi_rresp`   | `std_ulogic_vector(1 downto 0)`  | out       | read status response (OKAY, SLVERR or DECERR) to CPU       |
| `s0_axi_rvalid`  | `std_ulogic`                     | out       | read data and status response valid flag to CPU            |
| `s0_axi_rready`  | `std_ulogic`                     | in        | read response acknowledge from CPU                         |
| `s0_axi_bresp`   | `std_ulogic_vector(1 downto 0)`  | out       | write status response (OKAY, SLVERR or DECERR) to CPU      |
| `s0_axi_bvalid`  | `std_ulogic`                     | out       | write status response valid to CPU                         |
| `s0_axi_bready`  | `std_ulogic`                     | in        | write response acknowledge from CPU                        |
| `m0_axi_araddr`  | `std_ulogic_vector(31 downto 0)` | out       | read address to memory (32 bits = 4GB)                     |
| `m0_axi_arvalid` | `std_ulogic`                     | out       | read address valid to memory                               |
| `m0_axi_arready` | `std_ulogic`                     | in        | read address acknowledge from memory                       |
| `m0_axi_awaddr`  | `std_ulogic_vector(31 downto 0)` | out       | write address to memory (32 bits = 4GB)                    |
| `m0_axi_awvalid` | `std_ulogic`                     | out       | write address valid flag to memory                         |
| `m0_axi_awready` | `std_ulogic`                     | in        | write address acknowledge from memory                      |
| `m0_axi_wdata`   | `std_ulogic_vector(31 downto 0)` | out       | write data to memory                                       |
| `m0_axi_wstrb`   | `std_ulogic_vector(3 downto 0)`  | out       | write byte enables to memory                               |
| `m0_axi_wvalid`  | `std_ulogic`                     | out       | write data and byte enables valid to memory                |
| `m0_axi_wready`  | `std_ulogic`                     | in        | write data and byte enables acknowledge from memory        |
| `m0_axi_rdata`   | `std_ulogic_vector(31 downto 0)` | in        | read data response from memory                             |
| `m0_axi_rresp`   | `std_ulogic_vector(1 downto 0)`  | in        | read status response (OKAY, SLVERR or DECERR) from memory  |
| `m0_axi_rvalid`  | `std_ulogic`                     | in        | read data and status response valid flag from memory       |
| `m0_axi_rready`  | `std_ulogic`                     | out       | read response acknowledge to memory                        |
| `m0_axi_bresp`   | `std_ulogic_vector(1 downto 0)`  | in        | write status response (OKAY, SLVERR or DECERR) from memory |
| `m0_axi_bvalid`  | `std_ulogic`                     | in        | write status response valid from memory                    |
| `m0_axi_bready`  | `std_ulogic`                     | out       | write response acknowledge to memory                       |
| `irq`            | `std_ulogic`                     | out       | interrupt request to CPU                                   |
| `sw`             | `std_ulogic_vector(3 downto 0)`  | in        | wired to the four user slide switches                      |
| `btn`            | `std_ulogic_vector(3 downto 0)`  | in        | wired to the four user press buttons                       |
| `led`            | `std_ulogic_vector(3 downto 0)`  | out       | wired to the four user LEDs                                |

The slide switches, press buttons and LEDs have no specified role, use them as you wish (debugging...)
The entity declaration is already coded in `/vhdl/crypto/crypto.vhd`.
Please do not modify this entity declaration.

# Performance specifications

Try to implement the most powerful accelerator you can (multiple processing rounds per clock cycle, pipelining, other types of parallel architectures...)
Remember that the performance also depends on the clock frequency: computing twice more in a twice longer clock period does not change the processing power.
The performance on the `s0_axi` slave interface is not critical but things are different on the `m0_axi` master interface where the accesses shall be optimized in order to not slow down the processing.
Read and write operations shall probably be parallel, read and write requests shall probably not be delayed while waiting for responses...

Note that with a 32-bits wide `m0_axi` interface, even if it is optimized, reading or writing a block takes at least 4 clock cycles.
When targeting the maximum performance for your hardware accelerator do not try to go below 4 clock cycles to processa block, it would be a waste.

And remember that the resources in the FPGA fabric are limited.
Before designing a super-sophisticated deeply pipelined architecture check that it fits...

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
