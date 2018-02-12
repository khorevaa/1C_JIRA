﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОбновитьПояснение();
	ОбновитьСписокВерсий();
КонецПроцедуры

&НаСервере
Процедура ОбновитьПояснение()
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Пользователи.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	НЕ Пользователи.ПометкаУдаления
		|	И Пользователи.Родитель = ЗНАЧЕНИЕ(Справочник.Пользователи.Разработка)";
	
	Разработчики.ЗагрузитьЗначения(Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка"));
	Элементы.ВерсииИнфоРазработка.Заголовок = СтрШаблон("Участвуют ""%1"" разработчиков ~""%2""ч/версия", Разработчики.Количество(), Разработчики.Количество() * 8 * 10);
КонецПроцедуры


&НаКлиенте
Процедура Закрыть_(Команда)
	ЭтаФорма.Закрыть();
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокВерсий()
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Релизы.Ссылка КАК Версия,
		|	Задачи.Ссылка КАК Задача,
		|	СУММА(Задачи.Оценка) КАК ОценкаОбщая,
		|	СУММА(ВЫБОР
		|			КОГДА НЕ Задачи.Статус В (&КонечныеСтатусы)
		|				ТОГДА Задачи.Оценка
		|			ИНАЧЕ 0
		|		КОНЕЦ) КАК ОценкаОстаток
		|ИЗ
		|	Справочник.Релизы КАК Релизы
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Задачи.Версии КАК ЗадачиВерсии
		|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Задачи КАК Задачи
		|			ПО ЗадачиВерсии.Ссылка = Задачи.Ссылка
		|		ПО (ЗадачиВерсии.Версия = Релизы.Ссылка)
		|ГДЕ
		|	Релизы.ДатаНачала >= &ДатаНачала
		|
		|СГРУППИРОВАТЬ ПО
		|	Релизы.Ссылка,
		|	Задачи.Ссылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	Релизы.ДатаНачала
		|ИТОГИ
		|	СУММА(ОценкаОбщая),
		|	СУММА(ОценкаОстаток)
		|ПО
		|	Версия";
	
	Запрос.УстановитьПараметр("ДатаНачала", НачалоДня(ТекущаяДатаСеанса()));
	Запрос.УстановитьПараметр("КонечныеСтатусы", СтрРазделить("Закрыт,Сделан,Предоставлено ПР", ","));
	Выборка = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	//ЗначениеВРеквизитФормы(Дерево, "Версии");
	
	Версии.ПолучитьЭлементы().Очистить();
	Пока Выборка.Следующий() Цикл
		НовСтр = Версии.ПолучитьЭлементы().Добавить();
		ЗаполнитьЗначенияСвойств(НовСтр, Выборка);
		
		ВыборкаЭлементы = Выборка.Выбрать();
		Пока ВыборкаЭлементы.Следующий() Цикл
			Если Не ЗначениеЗаполнено(ВыборкаЭлементы.Задача) Тогда
				Продолжить;	
			КонецЕсли;
			
			НовСтр2 = НовСтр.ПолучитьЭлементы().Добавить();
			ЗаполнитьЗначенияСвойств(НовСтр2, ВыборкаЭлементы);
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиВВерсию(Команда)
	Если Элементы.Список.ВыделенныеСтроки.Количество() = 0 Тогда
		Сообщить("Выбелите строки с задачами для переноса");
		Возврат;
	КонецЕсли;
	Если Элементы.Версии.ВыделенныеСтроки.Количество() = 0 Тогда
		Сообщить("Выбелите строки с версиями для переноса");
		Возврат;
	КонецЕсли;
	
	ЗадачиДляПереноса = Новый Массив();
	Для Каждого Задача Из Элементы.Список.ВыделенныеСтроки Цикл
		Оценка = ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Задача, "Оценка");
		Если Оценка = 0 Тогда
			Сообщить(СтрШаблон("Не удалось перенести задачу ""%1"" т.к. не установлена оценка", Задача));
			Продолжить;
		КонецЕсли;
		ЗадачиДляПереноса.Добавить(Задача);
	КонецЦикла;
	
	ПереместитьВВерсиюНаСервере(ЗадачиДляПереноса, Элементы.Версии.ТекущиеДанные.Версия);
	//ЭтаФорма.Модифицированность = ЗадачиДляПереноса.Количество() > 0;
	Элементы.Список.Обновить();
	ОбновитьСписокВерсий();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПереместитьВВерсиюНаСервере(СписокЗадач, НоваяВерсия)
	Справочники.Релизы.ПереместитьВВерсию(СписокЗадач, НоваяВерсия);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Если ЗавершениеРаботы = Истина Тогда
		Возврат;	
	КонецЕсли;
	
	Если ЭтаФорма.Модифицированность Тогда
		Отказ = Истина;
		
		ОО = Новый ОписаниеОповещения("ПередЗакрытиемЗавершение", ЭтотОбъект);
		ПоказатьВопрос(ОО, "Сохранить изменения?", РежимДиалогаВопрос.ДаНетОтмена,,, "Возможна потеря изменений");
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытиемЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		Сохранение();
		Закрыть();
	ИначеЕсли РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		ЭтаФорма.Модифицированность = Ложь;
		Закрыть();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура Сохранение()
	
	ЭтаФорма.Модифицированность = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОценкуЗадаче(Команда)
	ПоказатьВводЧисла(Новый ОписаниеОповещения("УстановитьОценкуЗадачеЗавершение", ЭтотОбъект), 0, "Оценка в часах", 5, 2);
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОценкуЗадачеЗавершение(Число, ДополнительныеПараметры) Экспорт
	Если Число = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	
	Для Каждого Стр Из Элементы.Список.ВыделенныеСтроки Цикл
		НомерЗадачи = ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Стр, "Код");
		Данные = Новый Структура("Оценки", Новый Структура("Общая", Число));
		ВзаимодействиеC_JIRA_КлиентСервер.УстановитьОценкуВыполненияИВремяЗадачи(НомерЗадачи, Данные);
		//ВзаимодействиеC_JIRA_КлиентСервер.ОбновитьДанныеСабтасков(НомерЗадачи, Данные);
		
		ОбновитьОценкуВЗадаче(Стр, Число);
	КонецЦикла;
	Элементы.Список.Обновить();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОбновитьОценкуВЗадаче(Задача, Оценка)
	Если Не ЗначениеЗаполнено(Задача) Тогда
		Возврат;
	КонецЕсли;
	
	ЗадачаОбъект = Задача.ПолучитьОбъект();
	ЗадачаОбъект.Оценка = Оценка;
	ЗадачаОбъект.Записать();	
КонецПроцедуры


&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьВБраузере(Элемент, ВыбраннаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ВерсииВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьВБраузере(Элемент, ВыбраннаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьВБраузере(Элемент, ВыбраннаяСтрока)
	ТекСтрока = Элемент.ДанныеСтроки(ВыбраннаяСтрока);
	Если ТекСтрока <> Неопределено Тогда
		Если ТекСтрока.Свойство("Номер") Тогда
			ВзаимодействиеC_JIRA_КлиентСервер.ОткрытьЗадачуВБраузере(ТекСтрока.Номер);
		ИначеЕсли ТекСтрока.Свойство("Задача") Тогда
			НомерЗадачи = ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(ТекСтрока.Задача, "Код");
			ВзаимодействиеC_JIRA_КлиентСервер.ОткрытьЗадачуВБраузере(НомерЗадачи);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	// из ПриАктивизацииСтроки нельзя вызывать серверные методы 
	ЭтаФорма.ПодключитьОбработчикОжидания("ОбновитьИтогОценки", 0.3, Истина);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИтогОценки() Экспорт 
	ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
	ИтогОценки = ПолучитьИтогОценки(ВыделенныеСтроки);
	Если ИтогОценки <> Неопределено Тогда
		Элементы.Декорация3.Заголовок = СтрШаблон("Выбрано задач для переноса на ""%1"" часов.", Формат(ИтогОценки, "ЧГ="));
	КонецЕсли;
КонецПроцедуры


&НаСервереБезКонтекста
Функция ПолучитьИтогОценки(СписокЗадач)
	// Удаляем элементы не являющиеся задачами
	Для а = -(СписокЗадач.Количество()-1) По 0 Цикл
		Если ТипЗнч(СписокЗадач[-а]) <> Тип("СправочникСсылка.Задачи") Тогда
			СписокЗадач.Удалить(-а);
		КонецЕсли;
	КонецЦикла;

	Если СписокЗадач.Количество() = 0 Тогда
		Возврат Неопределено;	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СУММА(Задачи.Оценка) КАК Оценка
		|ИЗ
		|	Справочник.Задачи КАК Задачи
		|ГДЕ
		|	Задачи.Ссылка В(&СписокЗадач)";
		
	Запрос.УстановитьПараметр("СписокЗадач", СписокЗадач);
	Выборка = Запрос.Выполнить().Выбрать(); 
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Оценка;	
	КонецЕсли;
КонецФункции


&НаКлиенте
Процедура ВерсииПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	СтрокаНазначение = Элементы.Версии.ДанныеСтроки(Строка);
	Если СтрокаНазначение = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	
	Если ТипЗнч(ПараметрыПеретаскивания.Значение) = Тип("Массив") Тогда
		ЗадачиДляПереноса = Новый Массив();
		Для Каждого Задача Из ПараметрыПеретаскивания.Значение Цикл
			Оценка = ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Задача, "Оценка");
			Если Оценка = 0 Тогда
				Сообщить(СтрШаблон("Не удалось перенести задачу ""%1"" т.к. не установлена оценка", Задача));
				Продолжить;
			КонецЕсли;
			ЗадачиДляПереноса.Добавить(Задача);
		КонецЦикла;
		
		ПереместитьВВерсиюНаСервере(ЗадачиДляПереноса, СтрокаНазначение.Версия);
		Элементы.Список.Обновить();
	ИначеЕсли ТипЗнч(ПараметрыПеретаскивания.Значение) = Тип("Число") Тогда
		СтрокаИсточник = Элементы.Версии.ДанныеСтроки(ПараметрыПеретаскивания.Значение);
		Задачи = Новый Массив();
		Задачи.Добавить(СтрокаИсточник.Задача);
		ПереместитьВВерсиюНаСервере(Задачи, СтрокаНазначение.Версия);
	КонецЕсли;
	
	ОбновитьСписокВерсий();
КонецПроцедуры


&НаКлиенте
Процедура ИнфоРазработка(Команда)
	Если Разработчики <> Неопределено Тогда
		МРазработчики = Разработчики.ВыгрузитьЗначения();
		Сообщить(СтрСоединить(МРазработчики, Символы.ПС));	
	КонецЕсли;
КонецПроцедуры

