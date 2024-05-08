# cipher

### 1. Translated the Python sm4 implementation to VHDL using ChatGPT

```
https://raw.githubusercontent.com/0x10001/sm4/main/sm4/core.py
```

### 2. Implementation Result

In VHDL, you can organize your code in a way that suits your project's structure and your specific needs. Typically, VHDL projects consist of multiple files divided into two main types:

1. **Entity/Architecture Files**: These files describe the structure and behavior of the hardware components. An entity defines the interface (ports) of the component, and the architecture provides the implementation details.

2. **Package Files**: Packages are used to define and group related declarations such as types, constants, functions, and procedures that can be reused across multiple entities or architectures.

For the cryptographic functions you're working with, such as `rotate_left`, `tau`, `linear_substitution_0`, and `linear_substitution_1`, you can either:

### Option 1: Include Functions Directly in the Architecture
If these functions are specific to a single entity and not intended for reuse elsewhere, you can define them directly within the architecture of that entity. This keeps all related code in one file, which can simplify management if the functions are tightly coupled with the specific implementation of that entity.

### Option 2: Use a Package
If you anticipate that these functions could be useful in multiple entities or architectures, or if you want to keep your code organized and maintainable, you should define them in a package. Here’s how you can structure it:

1. **Create a Package Declaration File**: This file (typically named something like `cipher_pkg.vhd`) contains the declarations of all constants, types, and subprograms (functions and procedures). Here, you would declare your functions and any types or constants they use.

   ```vhdl
   -- File: cipher_pkg.vhd
   library IEEE;
   use IEEE.STD_LOGIC_1164.ALL;
   use IEEE.NUMERIC_STD.ALL;

   package cipher_pkg is
       -- Declare types and constants
       type S_box_type is array (0 to 255) of std_logic_vector(7 downto 0);
       constant S: S_box_type := (
           x"D6", x"90", x"E9", -- Only a partial list shown
           others => x"00"  -- Default for unspecified values
       );
       -- Declare functions
       function rotate_left(i32 : unsigned; k : integer) return unsigned;
       function tau(i32 : unsigned) return unsigned;
       function linear_substitution_0(i32 : unsigned) return unsigned;
       function linear_substitution_1(i32 : unsigned) return unsigned;
   end package cipher_pkg;
   ```

2. **Create a Package Body File**: This file (named `cipher_pkg-body.vhd`) contains the implementation of the declared subprograms.

   ```vhdl
   -- File: cipher_pkg-body.vhd
   package body cipher_pkg is
       function rotate_left(i32 : unsigned; k : integer) return unsigned is
       begin
           return (i32 sll k) or (i32 srl (32 - k));
       end function;

       function tau(i32 : unsigned) return unsigned is
           variable result : unsigned(31 downto 0);
       begin
           result(31 downto 24) := unsigned(S(to_integer(unsigned(i32(31 downto 24)))));
           result(23 downto 16) := unsigned(S(to_integer(unsigned(i32(23 downto 16)))));
           result(15 downto 8) := unsigned(S(to_integer(unsigned(i32(15 downto 8)))));
           result(7 downto 0) := unsigned(S(to_integer(unsigned(i32(7 downto 0)))));
           return result;
       end function;

       function linear_substitution_0(i32 : unsigned) return unsigned is
       begin
           return i32 xor rotate_left(i32, 2) xor rotate_left(i32, 10) xor rotate_left(i32, 18) xor rotate_left(i32, 24);
       end function;

       function linear_substitution_1(i32 : unsigned) return unsigned is
       begin
           return i32 xor rotate_left(i32, 13) xor rotate_left(i32, 23);
       end function;
   end package body;
   ```

3. **Use the Package in Entities**: In your entity/architecture files, you can then include this package and use the functions defined in it. You do this by adding `use work.cipher_pkg.all;` at the beginning of your architecture.

Using a package helps maintain clean separation between generic definitions and their implementations, promoting code reuse and simplifying testing and maintenance.