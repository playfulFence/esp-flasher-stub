PROVIDE( esp_rom_spiflash_erase_chip = 0x40000110 );
PROVIDE( esp_rom_spiflash_erase_block = 0x40000134 );
PROVIDE( esp_rom_spiflash_erase_sector = 0x40000130 );
PROVIDE( esp_rom_spiflash_erase_area = 0x40000144 );
PROVIDE( esp_rom_spiflash_write = 0x40000138 );
PROVIDE( esp_rom_spiflash_read = 0x4000013c );
PROVIDE( esp_rom_spiflash_unlock = 0x40000140 );
PROVIDE( esp_rom_spiflash_attach = 0x40000178 );
PROVIDE( esp_rom_spiflash_config_param = 0x4000014c );
PROVIDE( esp_rom_spiflash_write_enable = 0x40000148 );
PROVIDE( uart_tx_one_char = 0x40000058 );
PROVIDE( uart_div_modify = 0x40000078 );
PROVIDE( software_reset = 0x40000088 );
PROVIDE( ets_delay_us = 0x40000044 );
PROVIDE( tinfl_decompress = 0x400000ec );
PROVIDE( get_security_info_proc = 0x400000b0 );
PROVIDE( esp_rom_spiflash_write_encrypted_enable = 0x40000108 );
PROVIDE( esp_rom_spiflash_write_encrypted_disable = 0x4000010c );
PROVIDE( esp_rom_spiflash_write_encrypted = 0x40000100 );
PROVIDE( spi_read_status_high = 0x40000170 );
PROVIDE( spi_write_status = 0x40000174 );

PROVIDE( mbedtls_md5_init = 0x40002bd8 );
PROVIDE( mbedtls_md5_free = 0x40002bdc );
PROVIDE( mbedtls_md5_clone = 0x40002be0 );
PROVIDE( mbedtls_md5_starts_ret = 0x40002be4 );
PROVIDE( mbedtls_md5_update_ret = 0x40002be8 );
PROVIDE( mbedtls_md5_finish_ret = 0x40002bec );
PROVIDE( mbedtls_internal_md5_process = 0x40002bf0 );
PROVIDE( mbedtls_md5_ret = 0x40002bf4 );
