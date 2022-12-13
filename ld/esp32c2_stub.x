MEMORY
{
    /*
        https://github.com/espressif/esptool/blob/10828527038d143e049790d330ac4de76ce987d6/esptool/targets/esp32c2.py#L53-L62
        MEMORY_MAP = [[0x00000000, 0x00010000, "PADDING"],
                      [0x3C000000, 0x3C400000, "DROM"],
                      [0x3FCA0000, 0x3FCE0000, "DRAM"],
                      [0x3FC88000, 0x3FD00000, "BYTE_ACCESSIBLE"],
                      [0x3FF00000, 0x3FF50000, "DROM_MASK"],
                      [0x40000000, 0x40090000, "IROM_MASK"],
                      [0x42000000, 0x42400000, "IROM"],
                      [0x4037C000, 0x403C0000, "IRAM"]]
    */

    /* 272K of on soc RAM, 16K reserved for cache */
    ICACHE : ORIGIN = 0x4037C000,  LENGTH = 0x4000
    /* Instruction RAM */
    IRAM : ORIGIN = 0x4037C000 + 0x4000, LENGTH = 272K - 0x4000
    /* Data RAM */
    DRAM : ORIGIN = 0x3FCA0000, LENGTH = 0x30000

    /* External flash */
    /* Instruction ROM */
    IROM : ORIGIN =   0x42000000 + 0x20, LENGTH = 0x400000 - 0x20
    /* Data ROM */
    DROM : ORIGIN = 0x3C000000, LENGTH = 0x400000  
}

REGION_ALIAS("REGION_TEXT", IROM);
REGION_ALIAS("REGION_RODATA", DROM);

REGION_ALIAS("REGION_DATA", DRAM);
REGION_ALIAS("REGION_BSS", DRAM);
REGION_ALIAS("REGION_HEAP", DRAM);
REGION_ALIAS("REGION_STACK", DRAM);

REGION_ALIAS("REGION_RWTEXT", IRAM);


ENTRY(_start_hal)
PROVIDE(_start_trap = _start_trap_hal);

PROVIDE(_stext = ORIGIN(REGION_TEXT));
PROVIDE(_stack_start = ORIGIN(REGION_STACK) + LENGTH(REGION_STACK));
PROVIDE(_max_hart_id = 0);
PROVIDE(_hart_stack_size = 2K);
PROVIDE(_heap_size = 0);

PROVIDE(UserSoft = DefaultHandler);
PROVIDE(SupervisorSoft = DefaultHandler);
PROVIDE(MachineSoft = DefaultHandler);
PROVIDE(UserTimer = DefaultHandler);
PROVIDE(SupervisorTimer = DefaultHandler);
PROVIDE(MachineTimer = DefaultHandler);
PROVIDE(UserExternal = DefaultHandler);
PROVIDE(SupervisorExternal = DefaultHandler);
PROVIDE(MachineExternal = DefaultHandler);

PROVIDE(DefaultHandler = DefaultInterruptHandler);
PROVIDE(ExceptionHandler = DefaultExceptionHandler);

/* # Pre-initialization function */
/* If the user overrides this using the `#[pre_init]` attribute or by creating a `__pre_init` function,
   then the function this points to will be called before the RAM is initialized. */
PROVIDE(__pre_init = default_pre_init);

/* A PAC/HAL defined routine that should initialize custom interrupt controller if needed. */
PROVIDE(_setup_interrupts = default_setup_interrupts);

/* # Multi-processing hook function
   fn _mp_hook() -> bool;

   This function is called from all the harts and must return true only for one hart,
   which will perform memory initialization. For other harts it must return false
   and implement wake-up in platform-dependent way (e.g. after waiting for a user interrupt).
*/
PROVIDE(_mp_hook = default_mp_hook);

SECTIONS
{
  .text.dummy (NOLOAD) :
  {
    /* This section is intended to make _stext address work */
    . = ABSOLUTE(_stext);
  } > REGION_TEXT

  .text : ALIGN(4) {
    _irwtext = LOADADDR(.text);
    _srwtext = .;
    *(.init.literal .literal .text .init.literal.* .literal.* .text.* .rwtext .rwtext.*)
    . = ALIGN(4);

    KEEP(*(.init));
    KEEP(*(.init.rust));
    KEEP(*(.trap));
    KEEP(*(.trap.rust));

    *(.iram1)
    *(.iram1.*)

    _erwtext = .;
  } > REGION_RWTEXT

  /* similar as text_dummy */
  .ram_dummy (NOLOAD) : {
    . = ALIGN(ALIGNOF(.text));
    . = . + SIZEOF(.text);
  } > REGION_DATA

  .data : ALIGN(4)
  {
    _sidata = LOADADDR(.data);
    _sdata = .;
    /* Must be called __global_pointer$ for linker relaxations to work. */
    PROVIDE(__global_pointer$ = . + 0x800);
    *(.sdata .sdata.* .sdata2 .sdata2.*);
    *(.data .data.*);
    *(.rodata .rodata.*);
    *(.data1)
    *(.srodata .srodata.*);
    . = ALIGN(4);
    _edata = .;
  } > REGION_DATA

  .bss (NOLOAD) :
  {
    _sbss = .;
    *(.sbss .sbss.* .bss .bss.*);
    . = ALIGN(4);
    _ebss = .;
  } > REGION_BSS

  /* fictitious region that represents the memory available for the heap */
  .heap (NOLOAD) :
  {
    _sheap = .;
    . += _heap_size;
    . = ALIGN(4);
    _eheap = .;
  } > REGION_HEAP

  /* fictitious region that represents the memory available for the stack */
  .stack (NOLOAD) :
  {
    _estack = .;
    . = ABSOLUTE(_stack_start);
    _sstack = .;
  } > REGION_STACK

}

/* Do not exceed this mark in the error messages above                                    | */


PROVIDE(interrupt1 = DefaultHandler);
PROVIDE(interrupt2 = DefaultHandler);
PROVIDE(interrupt3 = DefaultHandler);
PROVIDE(interrupt4 = DefaultHandler);
PROVIDE(interrupt5 = DefaultHandler);
PROVIDE(interrupt6 = DefaultHandler);
PROVIDE(interrupt7 = DefaultHandler);
PROVIDE(interrupt8 = DefaultHandler);
PROVIDE(interrupt9 = DefaultHandler);
PROVIDE(interrupt10 = DefaultHandler);
PROVIDE(interrupt11 = DefaultHandler);
PROVIDE(interrupt12 = DefaultHandler);
PROVIDE(interrupt13 = DefaultHandler);
PROVIDE(interrupt14 = DefaultHandler);
PROVIDE(interrupt15 = DefaultHandler);
PROVIDE(interrupt16 = DefaultHandler);
PROVIDE(interrupt17 = DefaultHandler);
PROVIDE(interrupt18 = DefaultHandler);
PROVIDE(interrupt19 = DefaultHandler);
PROVIDE(interrupt20 = DefaultHandler);
PROVIDE(interrupt21 = DefaultHandler);
PROVIDE(interrupt22 = DefaultHandler);
PROVIDE(interrupt23 = DefaultHandler);
PROVIDE(interrupt24 = DefaultHandler);
PROVIDE(interrupt25 = DefaultHandler);
PROVIDE(interrupt26 = DefaultHandler);
PROVIDE(interrupt27 = DefaultHandler);
PROVIDE(interrupt28 = DefaultHandler);
PROVIDE(interrupt29 = DefaultHandler);
PROVIDE(interrupt30 = DefaultHandler);
PROVIDE(interrupt31 = DefaultHandler);