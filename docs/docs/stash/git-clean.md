[![logo](../../logo.png)](../stash.md "documentation") 

[H]: ../stash.md           "родитель"
[P]: ../../icons/progress.png  "в процессе..."
[S]: ../../icons/success.png   "ошибок не обнаружено"
   
[![P]][H] git-clean v0.0.1
==========================
Работает только с проектами WorkSpace  
  - удаляет всякий мусор, используя утилиту `garbage.exe`  
  - запускает очистку git-репозитория.  


garbage
-------
Для очистки мусора используется утилита `garbage`  


В норме утилита располагается в каталоге workspace:  
```
C:\workspace\scripts\cmd\garbage.exe
```
Так же, её можно расположить в каталоге `cmd`
```
_stash/example_gtest
 |--- cmd/garbage.exe
  `-- git-clean.bat
```

Либо нужно указать путь к программе в переменной `PATH`  
```
rem предположим здесь хранится garbage.exe 
set "DIR_CUSTOM_CMD=X:\cmd"
rem тогда в PATH нужно записать
set "PATH=%DIR_CUSTOM_CMD%;%PATH%"
```

Следующим образом указывается, что нужно удалить:  
```
  set m1=build; build-*; product; _products; _ready
  set m2=Release; release; release32; release64
  set m3=Debug; debug; debug32; debug64
  set m4=RelWithDebInfo; MinSizeRel
  set m5=.vs; *.suo; *.ncb; *.sdf; ipch; *.VC.db; *.aps;
  set m6=log.txt; cmdlog.txt; debug.txt;
  set m7=_cache*.bat; _cache
  set mask=%m1%; %m1%; %m2%; %m3%; %m4%; %m5%; %m6%; %m7%
```

А таким образом указывается, что не нужно удалять:  
```  
  set e1=_*; google*; boost*; mingw* 
  set e2=external*; product*; build*; programs; cmake*;
  set exclude=%e1%; %e2%
```

Путь к репозиторию определяется стандартным для WorkSpace способом:  

```
rem запуск из стэш-каталога

call :getName eNAME "%~dp0."
set "eDIR_REPO=%~dp0..\..\%eNAME%"

garbage.exe            ^
  "--start: eDIR_REPO" ^
  "--mask: %mask%"     ^
  "--es: %exclude%"
```
<br/>


git-clean
---------
Синопсис:  
```bat
set "FILTER_BRANCH_SQUELCH_WARNING=1"
git reflog expire --expire=now --all
git gc --prune=now --aggressive     
```

После того как был удален основной мусор из репозитория,  
запускается этап очистки репозитория на уровне git-команд.  
Удаляются недостяжимые коммиты, и временные файлы.  
<br/>


История изменений 
-----------------

|  ID  |    дата    | время |      ветка     | status  |  длительность  |
|:----:|:----------:|:-----:|:--------------:|:-------:|:--------------:|
| 0001 | 2025-12-07 | 22:10 | [#4-dev-stash] | VERSION | 21 час         |

[#4-dev-stash]: ../../history.md#-v004-dev
