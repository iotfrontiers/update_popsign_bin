@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\
:: [전체 설명]
:: 컴퓨터에 연결된 포트들 중에서 팝사인이 연결된 포트 번호를 가져와서
:: 자동으로 팝사인 보드에 바이너리 파일을 씁니다.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: 전체 연결 포트 이름 확인
:: 그 중에서 CH340을 포함한 포트 이름만 추출
set "port_number=0"
for /f "tokens=1* delims==" %%I in ('wmic path win32_pnpentity get caption /format:list ^| find "CH340"') do (
    echo %%~J
    call :setCOM "%%~J" & goto :continue
    
)

:: :setCOM <WMIC_output_line>
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 넘어온 포트 이름에서 포트 번호를 추출하는 부분
setlocal
:setCOM <WMIC_output_line>
set "str=%~1"
set "num=%str:*(COM=%"
set "num=%num:)=%"
set "port_number=%num%"
echo %port_number%
esptool.exe --chip esp32 --port COM"%port_number%" erase_region 0xc90000 0x370000 
esptool.exe --chip esp32 --port COM"%port_number%" --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size detect 0xe000 boot_app0.bin 0x1000 bootloader_qio_80m.bin 0x10000 popsign.ino.bin 0x8000 popsign.ino.partitions.bin
endlocal
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:continue
pause