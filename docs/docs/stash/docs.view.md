[![logo](../../logo.png)](../stash.md "documentation") 

[H]: ../stash.md           "родитель"
[P]: ../../icons/progress.png  "в процессе..."
[S]: ../../icons/success.png   "ошибок не обнаружено"
   
[![P]][H] docs.view v0.0.1
==========================
Батник запускает броузер для просмотра документации.  
Документация пишется в формате `markdown`  

В настоящий момент батник поддерживает только два броузера: `edge` и `chrome`  
Сначала батник попробует запустить хром, но если хрома нет, тогда попробует эдж  
Батник выполняет запуск броузера, скармливая ему головной файл `README.md`  

Что бы броузеры понимали `markdown`, нужно установить расширение`Markdown Viewer`  
  - хром: https://chrome.google.com/webstore/detail/markdown-viewer/ckkdlimhmcjmikdlpkmbgfkaikojcbjk  
  - edge: https://microsoftedge.microsoft.com/addons/detail/markdown-viewer/cgfmehpekedojlmjepoimbfcafopimdg

Markdown Viewer
---
1. Параметры расширения -> File Access -> Allow Access  
   <details><summary>Доступ к файлам</summary> <img src="edge/mv-access.png"/></details>  
2. Кликаем на изображение расширения, и тогда откроется окошко с его настройками:
   <details><summary>кликаем по расширению</summary> <img src="edge/mv-settings-1.png"/></details>  
   <details><summary>откроются настройки</summary> <img src="edge/mv-settings-2.png"/></details>  
   <details><summary>Выбираем: Github-dark</summary> <img src="edge/mv-github-dark.png"/></details>  
3. Включаем все крыжики во вкладке CONENT
   <details><summary>настройка CONTENT</summary> <img src="edge/mv-content.png"/></details>  
4. Включаем все крыжики во вкладке COMPILER  
   <details><summary>настройка COMPILER</summary> 
     <img src="edge/mv-compiler-1.png"/>
     <img src="edge/mv-compiler-2.png"/>
   </details>

<br/>


История изменений 
-----------------

|  ID  |    дата    | время |      ветка     | status  |  длительность  |
|:----:|:----------:|:-----:|:--------------:|:-------:|:--------------:|
| 0001 | 2025-12-07 | 22:10 | [#4-dev-stash] | VERSION | 21 час         |

[#4-dev-stash]: ../../history.md#-v004-dev
