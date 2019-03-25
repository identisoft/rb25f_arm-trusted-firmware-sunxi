OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
MEMORY {
    RAM (rwx): ORIGIN = (0x00044000), LENGTH = (0x00044000 + (64 << 10)) - (0x00044000)
}
SECTIONS
{
    . = (0x00044000);
    ASSERT(. == ALIGN(4096),
           "BL31_BASE address is not aligned on a page boundary.")
    ro . : {
        __RO_START__ = .;
        KEEP(*bl31_entrypoint.o(.text*))
        *(.text*)
        *(.rodata*)
        . = ALIGN(8);
        __RT_SVC_DESCS_START__ = .;
        KEEP(*(rt_svc_descs))
        __RT_SVC_DESCS_END__ = .;
        . = ALIGN(8);
        __CPU_OPS_START__ = .;
        KEEP(*(cpu_ops))
        __CPU_OPS_END__ = .;
        *(.vectors)
        __RO_END_UNALIGNED__ = .;
        . = NEXT(4096);
        __RO_END__ = .;
    } >RAM
    ASSERT(__CPU_OPS_END__ > __CPU_OPS_START__,
           "cpu_ops not defined for this platform.")
    .data . : {
        __DATA_START__ = .;
        *(.data*)
        __DATA_END__ = .;
    } >RAM
    ASSERT(. <= ((0x00044000 + (64 << 10)) - 0x6000), "BL3-1 progbits has exceeded its limit.")
    stacks (NOLOAD) : {
        __STACKS_START__ = .;
        *(tzfw_normal_stacks)
        __STACKS_END__ = .;
    } >RAM
    .bss : ALIGN(16) {
        __BSS_START__ = .;
        *(.bss*)
        *(COMMON)
        __BSS_END__ = .;
    } >RAM
    xlat_table (NOLOAD) : {
        *(xlat_table)
    } >RAM
    coherent_ram (NOLOAD) : ALIGN(4096) {
        __COHERENT_RAM_START__ = .;
        *(tzfw_coherent_mem)
        __COHERENT_RAM_END_UNALIGNED__ = .;
        . = NEXT(4096);
        __COHERENT_RAM_END__ = .;
    } >RAM
    __BL31_END__ = .;
    __BSS_SIZE__ = SIZEOF(.bss);
    __COHERENT_RAM_UNALIGNED_SIZE__ =
        __COHERENT_RAM_END_UNALIGNED__ - __COHERENT_RAM_START__;
    ASSERT(. <= (0x00044000 + (64 << 10)), "BL3-1 image has exceeded its limit.")
}
