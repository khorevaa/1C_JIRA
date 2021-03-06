﻿&НаКлиенте
Перем ИдентификаторФЗ;


&НаКлиенте
Процедура ПолучитьЗадачи(Команда)
	ИдентификаторФЗ = ЗапускЗадачНаСервере();
	Если ЗначениеЗаполнено(ИдентификаторФЗ) Тогда
		Элементы.СписокПолучитьЗадачи.Доступность = Ложь;
		ЭтаФорма.ПодключитьОбработчикОжидания("ПроверитьВыполненияФЗ", 1, Ложь);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьВыполненияФЗ()
	Если Не ЗначениеЗаполнено(ИдентификаторФЗ) Тогда
		Возврат;	
	КонецЕсли;
	
	Если ОбщегоНазначенияСервер.ЗаданиеВыполнено(ИдентификаторФЗ) Тогда
		Элементы.СписокПолучитьЗадачи.Доступность = Истина;	
		ЭтаФорма.ОтключитьОбработчикОжидания("ПроверитьВыполненияФЗ");
	КонецЕсли;
КонецПроцедуры



&НаКлиенте
Процедура ОбновитьИсториюСписаний(Команда)
	ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
	ОбновитьИсториюСписанийНаСервере(ВыделенныеСтроки);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИсториюПереходов(Команда)
	ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
	ОбновитьИсториюПереходовНаСервере(ВыделенныеСтроки);
КонецПроцедуры



&НаСервереБезКонтекста
Процедура ОбновитьИсториюПереходовНаСервере(Строки)
	Номера = Новый Массив();
	Для Каждого Стр Из Строки Цикл
		Номера.Добавить(Стр.Код);	
	КонецЦикла;
	РегистрыСведений.ИсторияИзмененияСтатусов.ОбновитьЗаписи(Номера);
КонецПроцедуры


&НаСервереБезКонтекста
Процедура ОбновитьИсториюСписанийНаСервере(Строки)
	Номера = Новый Массив();
	Для Каждого Стр Из Строки Цикл
		Номера.Добавить(Стр.Код);	
	КонецЦикла;
	РегистрыСведений.СписаниеВремени.ОбновитьЗаписи(Номера);
КонецПроцедуры


&НаСервереБезКонтекста
Функция ЗапускЗадачНаСервере()	
	ФЗ = ФоновыеЗадания.Выполнить("ОбработкаРегламентныхЗаданий.ОбновитьВсеДанные",, Строка(Новый УникальныйИдентификатор()), "Обновление задач");
	Возврат ФЗ.УникальныйИдентификатор;
КонецФункции

&НаСервереБезКонтекста
Процедура ОбновитьДанныеЗадачНаСервере(Строки)
	Номера = Новый Массив();
	Для Каждого Стр Из Строки Цикл
		Номера.Добавить(Стр.Код);	
	КонецЦикла;

	Справочники.Задачи.ОбновитьЗадачи(Номера);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеЗадач(Команда)
	ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
	ОбновитьДанныеЗадачНаСервере(ВыделенныеСтроки);
КонецПроцедуры
