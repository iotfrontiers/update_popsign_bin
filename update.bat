@echo off
for /f "tokens=2 delims==" %%a in ('type "comport.txt" ^|findstr /bi "COM="') do (
    set "str=%%a" & goto :continue
)
:continue
echo "%str%"

esptool.exe erase_region 0xc90000 0x370000

esptool.exe --chip esp32 --port COM"%str%" --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size detect 0xe000 boot_app0.bin 0x1000 bootloader_qio_80m.bin 0x10000 popsign.ino.bin 0x8000 popsign.ino.partitions.bin


pause
 