@echo off
set /p a = ------------------���س�����ʼ----------------

:����res��src���µ�Ŀ¼
rd /s/q ��ʽ��
mkdir ��ʽ��
mkdir ��ʽ��\src
xcopy res ��ʽ��\res\ /e
xcopy src ��ʽ��\src\ /e

for /f "delims=" %%i in ('dir /b /a-d /s "��ʽ��\src\*.lua"') do del %%i 
rd /s/q ��ʽ��\src\version

:����luac
start /wait E:\cocos2d-x-3.6\tools\cocos2d-console\bin\cocos luacompile -s %~dp0\src\ -d %~dp0\��ʽ��\src\ -e True -k huyoo_79EEADB9D80587EF_key -b huyoo_79EEADB9D80587EF_sign --disable-compile


rd /s/q ��ʽ��\res\achannel
rd /s/q ��ʽ��\res\hall_1
rd /s/q ��ʽ��\res\hall_2
rd /s/q ��ʽ��\res\hall_4
rd /s/q ��ʽ��\res\hall_5
rd /s/q ��ʽ��\res\hall_6
rd /s/q ��ʽ��\res\hall_7
rd /s/q ��ʽ��\res\hall_8
rd /s/q ��ʽ��\res\hall_9
rd /s/q ��ʽ��\res\hall_10
rd /s/q ��ʽ��\res\hall_11
rd /s/q ��ʽ��\res\expression\sound_quick_qiyang
rd /s/q ��ʽ��\res\expression\sound_quick_yongzhou
rd /s/q ��ʽ��\res\majiang\sound\zhumadian
rd /s/q ��ʽ��\res\majiang\sound\yongzhou
rd /s/q ��ʽ��\res\puke\sound_sangong
rd /s/q ��ʽ��\res\zipai\sound\hengyang
rd /s/q ��ʽ��\res\zipai\sound\yongzhou
mkdir ��ʽ��\res\achannel\5
xcopy res\achannel\5 ��ʽ��\res\achannel\5 /e


:��Դ�ļ�����
start /wait Encryption.exe ��ʽ��\ 79EEADB9D80587EF

:�汾��Ϣ����
mkdir ��ʽ��\src\version
rd /s/q ����5
mkdir ����5
xcopy ��ʽ�� ����5 /e
mkdir ��ʽ��\src\version\5
mkdir ����5\src\version\5
copy ".\src\version\5\*" ".\����5\src\version\5\"
:����ɾ������Ҫ���ļ��У����磺rd /s/q �ļ���
start /wait VerstionBuild.exe ����5\ ����5\src\version\5\version.manifest ����5\src\version\5\project.manifest
copy ".\����5\src\version\5\*" ".\��ʽ��\src\version\5\"


echo --------------------��ɣ�--------------------


pause

