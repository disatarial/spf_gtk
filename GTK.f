\ все библиотеки имеют си-шный интерфейс подключения

STARTLOG
 REQUIRE CAPI: lib/win/api-call/capi.f 
REQUIRE  { lib\ext\locals.f
REQUIRE STR@         ~ac/lib/str5.f

\ пользовательский интерфейс  сишные функции
\ в принципе можно использовать автоподключение функций из библиотеки
\ но на мой на "обучение" так будет  лучше

\ функции окон управления
CVAPI: gtk_init					libgtk-3-0.dll
CVAPI: gtk_widget_destroy			libgtk-3-0.dll
CVAPI: gtk_widget_hide				libgtk-3-0.dll
CVAPI: gtk_widget_show				libgtk-3-0.dll
CVAPI: gtk_widget_set_sensitive			libgtk-3-0.dll
CVAPI: gtk_builder_new				libgtk-3-0.dll
CVAPI: gtk_builder_add_from_file		libgtk-3-0.dll
CVAPI: gtk_builder_get_object			libgtk-3-0.dll
CVAPI: gtk_main					libgtk-3-0.dll
CVAPI: gtk_main_quit				libgtk-3-0.dll

CVAPI: gtk_entry_set_text			libgtk-3-0.dll
CVAPI: gtk_entry_get_text    			libgtk-3-0.dll
CVAPI: gtk_entry_get_text_length		libgtk-3-0.dll


\ CALLBACK функция связи gtk-шных библиотек форт-слов
CVAPI: g_signal_connect_data			libgobject-2.0-0.dll

\ обрабока ошибок, не помню что и почему так сделано, но по моему  где-то было найдено.... 
\ 0
\ CELL -- domain
\ CELL -- code \ 
\ CELL -- message
\ CONSTANT GError
\ HERE DUP >R GError  DUP ALLOT ERASE VALUE GtkError

VARIABLE error  \ сюда скидывать номер ошибки 
\ оболочка пользователя
\ переменные для передачачи параметров в программу с командной строки
VARIABLE pargv
VARIABLE pargs

\ переменные для подключения окошек glade
VARIABLE builder   
VARIABLE window
VARIABLE button_start
VARIABLE entry_result

\ функцииобратного вызова
\ требуются для взаимодействия нарисованного в glade окошка и форт программы
\ вот здесь я кое-что не пойму, а именно какие данные передаются сюда из "вне"
\ есть некоторые предположения, но их так и не проверь как следует...

:NONAME   BYE 	window @ ;  1 CELLS  CALLBACK: on_window_destroy 

\ 
:NONAME   ." button .... " 
    entry_result @ 1 gtk_entry_get_text_length   DUP 0 > 
    IF 
	entry_result  @ 1 gtk_entry_get_text    SWAP
	 TYPE	
    ELSE DROP ."  Error: entry_result  empty "   THEN
 CR	window @ ;  1 CELLS  CALLBACK: but_start_click 



: work_windows
 pargv pargs  2  gtk_init  DROP  \ берем командную строку и принимаем из нее  данные 
   0 gtk_builder_new   builder ! \ создаем "главный" обьект
   \ подключаем файл glade
 error  " windows.glade"  >R R@ STR@  DROP  builder @ 3 gtk_builder_add_from_file DROP   R> STRFREE 
 " window1"  >R R@ STR@  DROP builder @ 2 gtk_builder_get_object window !  R> STRFREE \ 2DROP
   window @  1 gtk_widget_show DROP  \ включаем видимость окна

\ далее назначаем форт-слова  функциями обратного вызова
\ правильные названия в "" требуется определять в документациик gtk
\ при ошибках пишет "warning"  и пропускает даннео соединение

\ закрытие программы
" destroy"  >R 0 0 0  ['] on_window_destroy  R@ STR@ DROP window @ 6 g_signal_connect_data   R> STRFREE  DROP \ 2DROP 2DROP 2DROP
   \ связь кнопки и  окошка, 
" button1" >R  R@ STR@  DROP builder @ 2 gtk_builder_get_object button_start !    R> STRFREE \ 2DROP
 \ теперь указывая   переменную button_start пожем управлять кнопкой используя gtk-шные функции
 \ связь  "нажатия" (clicked)  кнопки с форт-словом.
 " clicked"  >R 0 0 0  ['] but_start_click   R@ STR@ DROP button_start @ 6 g_signal_connect_data   R> STRFREE  DROP \ 2DROP 2DROP 2DROP

   \ связь окошка ввода (entry) и  форт-переменной, 
" entry1"   >R  R@ STR@  DROP builder @ 2 gtk_builder_get_object entry_result !     R> STRFREE 

\ выводим в окошко текст:

 " test "   >R  R@ STR@  DROP  entry_result @ 2 gtk_entry_set_text DROP   R> STRFREE 



\ запуск  функционирования окошка
  0 gtk_main  DROP 
;


work_windows