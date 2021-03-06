@echo off
:: Find the port to which the board is connected.
set "port_number=0"
for /f "tokens=1* delims==" %%I in ('wmic path win32_pnpentity get caption /format:list ^| find "CH340"') do (
    call :setCOM "%%~J" & goto :continue
)

:: Extract the port number from the port name and write the bin file.
setlocal
:setCOM <WMIC_output_line>
set "str=%~1"
set "num=%str:*(COM=%"
set "num=%num:)=%"
set "port_number=%num%"
esptool.exe --chip esp32 --port COM"%port_number%" erase_region 0x9000 0xFF7000
esptool.exe --chip esp32 --port COM"%port_number%" --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size detect 0xe000 boot_app0.bin 0x1000 bootloader_qio_80m.bin 0x10000 popsign.ino.bin 0x8000 popsign.ino.partitions.bin
endlocal

:continue
pause