﻿/////////////// Защита модуля ///////////////
// @protect                                //
/////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Функция - Получает текст из чтения XML.
//
// Параметры:
//   ЧтениеXML - ЧтениеXML - объект чтения.
//
// Возвращаемое значение:
//   Строка - полученный текст.
//
&НаСервере
Функция ПолучитьТекстИзЧтениеXML(ЧтениеXML) Экспорт 
  Перем ДокументDOM, DOM; 
  
  DOM = Новый ПостроительDOM;
	ДокументDOM = DOM.Прочитать(ЧтениеXML); 
  
  Возврат УтилитыDOM.ПолучитьТекстИзДокументDOM(ДокументDOM);
КонецФункции

// Функция - Создать из текста чтение XML.
//
// Параметры:
//   Текст - Строка - текст для разбора.
//
// Возвращаемое значение:
//   ЧтениеXML - объект для чтения.
//
Функция СоздатьИзТекста(Текст) Экспорт
  Результат = Новый ЧтениеXML();
  Результат.УстановитьСтроку(Текст);
  Возврат Результат;
КонецФункции

// Функция - Создать из файла чтение XML.
//
// Параметры:
//   ИмяФайла - Строка - имя файла;
//   Кодировка - Строка - кодировка файла.
//
// Возвращаемое значение:
//   ЧтениеXML - объект для чтения.
//
Функция СоздатьИзФайла(ИмяФайла, Кодировка = Неопределено) Экспорт
  Результат = Новый ЧтениеXML();
  Если ЗначениеЗаполнено(Кодировка) Тогда 
  // И Кодировка <> Перечисления.БФТ_ОбменКодировкаXML.НеУказано Тогда .
  //  Результат.ОткрытьФайл(ИмяФайла,,, КодировкаВСтроку(Кодировка)); 
    Результат.ОткрытьФайл(ИмяФайла,,, Кодировка); 
  Иначе 
    Результат.ОткрытьФайл(ИмяФайла);
  КонецЕсли;
  
  Возврат Результат;
КонецФункции

#КонецОбласти


