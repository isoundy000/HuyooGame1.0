@echo off
set /p a = ------------------按回车键开始----------------

:拷贝res和src到新的目录
rd /s/q 正式包
mkdir 正式包
mkdir 正式包\src
xcopy res 正式包\res\ /e
xcopy src 正式包\src\ /e

for /f "delims=" %%i in ('dir /b /a-d /s "正式包\src\*.lua"') do del %%i 
rd /s/q 正式包\src\version

:生成luac
start /wait E:\cocos2d-x-3.6\tools\cocos2d-console\bin\cocos luacompile -s %~dp0\src\ -d %~dp0\正式包\src\ -e True -k huyoo_79EEADB9D80587EF_key -b huyoo_79EEADB9D80587EF_sign --disable-compile

rd /s/q 正式包\res\achannel
rd /s/q 正式包\res\hall_2
rd /s/q 正式包\res\hall_3
rd /s/q 正式包\res\tszipai
rd /s/q 正式包\res\laopai
mkdir 正式包\res\achannel\16
xcopy res\achannel\16 正式包\res\achannel\16 /e


:资源文件加密
start /wait Encryption.exe 正式包\ 79EEADB9D80587EF

:版本信息生成
mkdir 正式包\src\version
rd /s/q 渠道16
mkdir 渠道16
xcopy 正式包 渠道16 /e
mkdir 正式包\src\version\16
mkdir 渠道16\src\version\16
copy ".\src\version\16\*" ".\渠道16\src\version\16\"
:这里删除不需要的文件夹，例如：rd /s/q 文件名
start /wait VerstionBuild.exe 渠道16\ 渠道16\src\version\16\version.manifest 渠道16\src\version\16\project.manifest
copy ".\渠道16\src\version\16\*" ".\正式包\src\version\16\"


echo --------------------完成！--------------------


pause

