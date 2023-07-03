MEMORY
{
    /*
        https://github.com/espressif/esptool/blob/10828527038d143e049790d330ac4de76ce987d6/esptool/targets/esp32c6.py#L64-L76
        MEMORY_MAP = [[0x00000000, 0x00010000, "PADDING"],
                      [0x42800000, 0x43000000, "DROM"],
                      [0x40800000, 0x40880000, "DRAM"],
                      [0x40800000, 0x40880000, "BYTE_ACCESSIBLE"],
                      [0x4004AC00, 0x40050000, "DROM_MASK"],
                      [0x40000000, 0x4004AC00, "IROM_MASK"],
                      [0x42000000, 0x42800000, "IROM"],
                      [0x40800000, 0x40880000, "IRAM"]]
    */

    /* 512K of on soc RAM, 32K reserved for cache */
    ICACHE : ORIGIN = 0x40800000,  LENGTH = 0x8000
    /* Instruction and Data RAM */
    RAM : ORIGIN = 0x40800000 + 0x8000, LENGTH = 512K - 0x8000

    /* External flash */
    /* Instruction and Data ROM */
    ROM : ORIGIN =   0x42000000 + 0x20, LENGTH = 0x400000 - 0x20

    /* RTC fast memory (executable). Persists over deep sleep. */
    RTC_FAST : ORIGIN = 0x50000000, LENGTH = 16K /*- ESP_BOOTLOADER_RESERVE_RTC*/
  
}

REGION_ALIAS("REGION_TEXT", ROM);
REGION_ALIAS("REGION_RODATA", ROM);

REGION_ALIAS("REGION_DATA", RAM);
REGION_ALIAS("REGION_BSS", RAM);
REGION_ALIAS("REGION_HEAP", RAM);
REGION_ALIAS("REGION_STACK", RAM);

REGION_ALIAS("REGION_RWTEXT", RAM);
REGION_ALIAS("REGION_RTC_FAST", RTC_FAST);

/* --- --- --- --- --- --- --- 

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

/* The ESP32-C2 and ESP32-C3 have interrupt IDs 1-31, while the ESP32-C6 has
   IDs 0-31, so we much define the handler for the one additional interrupt
   ID: */
PROVIDE(interrupt0 = DefaultHandler);

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

  .text _stext :
  {
    /* Put reset handler first in .text section so it ends up as the entry */
    /* point of the program. */
    KEEP(*(.init));
    KEEP(*(.init.rust));
    KEEP(*(.text.abort));
    . = ALIGN(4);
    KEEP(*(.trap));
    KEEP(*(.trap.rust));

    *(.text .text.*);
    _etext = .;
  } > REGION_TEXT

  _text_size = _etext - _stext + 8;
  .rodata ORIGIN(ROM) + _text_size : AT(_text_size)
  {
    _srodata = .;
    *(.srodata .srodata.*);
    *(.rodata .rodata.*);

    /* 4-byte align the end (VMA) of this section.
       This is required by LLD to ensure the LMA of the following .data
       section will have the correct alignment. */
    . = ALIGN(4);
    _erodata = .;
  } > REGION_RODATA

  _rodata_size = _erodata - _srodata + 8;
  .data ORIGIN(RAM) : AT(_text_size + _rodata_size)
  {
    _data_start = .;
    /* Must be called __global_pointer$ for linker relaxations to work. */
    PROVIDE(__global_pointer$ = . + 0x800);
    *(.sdata .sdata.* .sdata2 .sdata2.*);
    *(.data .data.*);
    . = ALIGN(4);
    _data_end = .;
  } > REGION_DATA

  _data_size = _data_end - _data_start + 8;
  .rwtext ORIGIN(REGION_RWTEXT) + _data_size : AT(_text_size + _rodata_size + _data_size){
    _srwtext = .;
    *(.rwtext);
    . = ALIGN(4);
    _erwtext = .;
  } > REGION_RWTEXT
  _rwtext_size = _erwtext - _srwtext + 8;

  .rtc_fast.text : AT(_text_size + _rodata_size + _data_size + _rwtext_size) {
    _srtc_fast_text = .;
    *(.rtc_fast.literal .rtc_fast.text .rtc_fast.literal.* .rtc_fast.text.*)
    . = ALIGN(4);
    _ertc_fast_text = .;
  } > REGION_RTC_FAST
  _fast_text_size = _ertc_fast_text - _srtc_fast_text + 8;

  .rtc_fast.data : AT(_text_size + _rodata_size + _data_size + _rwtext_size + _fast_text_size)
  {
    _rtc_fast_data_start = ABSOLUTE(.);
    *(.rtc_fast.data .rtc_fast.data.*)
    . = ALIGN(4);
    _rtc_fast_data_end = ABSOLUTE(.);
  } > REGION_RTC_FAST
  _rtc_fast_data_size = _rtc_fast_data_end - _rtc_fast_data_start + 8;

  .rtc_fast.bss (NOLOAD) : ALIGN(4)
  {
    _rtc_fast_bss_start = ABSOLUTE(.);
    *(.rtc_fast.bss .rtc_fast.bss.*)
    . = ALIGN(4);
    _rtc_fast_bss_end = ABSOLUTE(.);
  } > REGION_RTC_FAST

  .rtc_fast.noinit (NOLOAD) : ALIGN(4)
  {
    *(.rtc_fast.noinit .rtc_fast.noinit.*)
  } > REGION_RTC_FAST

  .bss (NOLOAD) :
  {
    _bss_start = .;
    *(.sbss .sbss.* .bss .bss.*);
    . = ALIGN(4);
    _bss_end = .;
  } > REGION_BSS

  /* ### .uninit */
  .uninit (NOLOAD) : ALIGN(4)
  {
    . = ALIGN(4);
    __suninit = .;
    *(.uninit .uninit.*);
    . = ALIGN(4);
    __euninit = .;
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

  /* fake output .got section */
  /* Dynamic relocations are unsupported. This section is only used to detect
     relocatable code in the input files and raise an error if relocatable code
     is found */
  .got (INFO) :
  {
    KEEP(*(.got .got.*));
  }

  .eh_frame (INFO) : { KEEP(*(.eh_frame)) }
  .eh_frame_hdr (INFO) : { *(.eh_frame_hdr) }
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
