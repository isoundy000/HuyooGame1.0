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
mkdir ��ʽ��\res\achannel\4
xcopy res\achannel\4 ��ʽ��\res\achannel\4 /e


:��Դ�ļ�����
start /wait Encryption.exe ��ʽ��\ 79EEADB9D80587EF

:�汾��Ϣ����
mkdir ��ʽ��\src\version
rd /s/q ����4
mkdir ����4
xcopy ��ʽ�� ����4 /e
mkdir ��ʽ��\src\version\4
mkdir ����4\src\version\4
copy ".\src\version\4\*" ".\����4\src\version\4\"
:����ɾ������Ҫ���ļ��У����磺rd /s/q �ļ���
start /wait VerstionBuild.exe ����4\ ����4\src\version\4\version.manifest ����4\src\version\4\project.manifest
copy ".\����4\src\version\4\*" ".\��ʽ��\src\version\4\"


echo --------------------��ɣ�--------------------


pause

