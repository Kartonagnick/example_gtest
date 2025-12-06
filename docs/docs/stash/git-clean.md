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

Что нужно удалить:  
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

Что не нужно удалять:  
```  
  set e1=_*; google*; boost*; mingw* 
  set e2=external*; product*; build*; programs; cmake*;
  set exclude=%e1%; %e2%
```

Путь к репозиторию определяется стандартным для WorkSpace образом:  

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
<br/>


История изменений 
-----------------

|  ID  |    дата    | время |      ветка     | status  |  длительность  |
|:----:|:----------:|:-----:|:--------------:|:-------:|:--------------:|
| 0001 | 2025-12-06 | 15:40 | [#4-dev-stash] | VERSION | 21 час         |

[#4-dev-stash]: ../../history.md#-v004-dev
