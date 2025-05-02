
[![logo](../logo.png)](../docs.md "документация") 

[M]: #main              "описание известных проблемы"
[H]: ../docs.md             "родитель"
[P]: ../icons/progress.png  "в процессе..."
[S]: ../icons/success.png   "ошибок не обнаружено"
[D]: ../icons/danger.png    "обнаружна проблема"

[ORIGIN]: https://github.com/Kart-cpp-tools/tools/blob/master/docs/other/problem.md

<a name="main"></a>
[![S]][H] problem v0.0.1
========================
В этом файле описываются различные известные проблемы,  
которые по каким либо причинам не были исправлены.  
<br/>


[![D]][H] mingw494:32:all:static
--------------------------------
Провоцирует ошибку линковки:  

<details>
  <summary>Пример текста ошибки</summary>
  
  > [ 66%] Linking CXX executable `mingw494-debug-32-static\test\test.exe`  
  > `lib/gcc/i686-w64-mingw32/4.9.4/../../../../i686-w64-mingw32/lib/../lib\libpthread.a`  
  >   (libwinpthread_la-clock.o):clock.c:(.text+0x270): undefined reference to `__divmoddi4'  
  > collect2.exe: error: ld returned 1 exit status  
  > mingw32-make.exe[2]: *** [CMakeFiles\test.dir\build.make:175: 'mingw494-debug-32-static/test/test.exe'] Error 1  
  > mingw32-make.exe[1]: *** [CMakeFiles\Makefile2:142: CMakeFiles/test.dir/all] Error 2  
  > mingw32-make.exe: *** [Makefile:90: all] Error 2  
  > [ERROR] cmake finished with errors  
</details>
<br/>  


[Здесь][PATCH] патч для компилятора for GCC 7.  
[Здесь][WA] обходной вариант решения этой проблемы.  

В нашем случае проблему решить не удалось.  
Поэтому конфигурация `mingw494:32:all:static` не поддерживается.  

[PATCH]: https://sourceforge.net/p/mingw-w64/mailman/message/35828127/
[WA]: https://gcc.gnu.org/legacy-ml/gcc-help/2017-05/msg00103.html
<br/>


[![D]][H] mingw810
------------------
С `mingw810` возникла проблема.  
Использование `thread_local` совместно с классами, которые используют динамическую память,  
в момент завершения работы приложения провоцирует ошибку `AccessViolation`  

```cpp
#include <string>
static thread_local std::string txt = "11";
int main()
{
    return 0;
}
```

Приложение завершается с кодом ошибки: -1073741819  
Т.е., уже после того как main возвращает управление, где то в недрах crt происходит сбой.  
Поэтому, вместо того, что бы вернуть 0, приложение возвращает -1073741819  

```bat
@echo off & cls
test.exe
echo [code][%errorlevel%]
if errorlevel 1 (echo [error])
```

Вывод в консоль:  
```
[code][-1073741819]
[error]
```
<br/>

--------------------------------------------------------------------------------

История изменений 
-----------------
Cсылка на оригинальный материал: [Kart-cpp-tools/tools][ORIGIN]  

|  ID  |    дата    | время |     ветка      | status  | длительность |
|:----:|:----------:|:-----:|:--------------:|:-------:|:------------:|
| 0001 | 2025-12-02 | 12:00 | [#1-rep-first] | VERSION |    30 мин    |

[#1-rep-first]: ../history.md#-v001-rep
