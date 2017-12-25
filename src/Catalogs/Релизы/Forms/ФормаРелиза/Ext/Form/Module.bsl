﻿&НаКлиенте
Перем ИдентификаторФЗ;


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗадачиПопавшиеВРелиз.Параметры.УстановитьЗначениеПараметра("КонечныеСтатусы", СтрРазделить("Закрыт,Сделан,Предоставлено ПР", ","));
	ЗадачиПопавшиеВРелиз.Параметры.УстановитьЗначениеПараметра("ТекРелиз", Объект.Ссылка);
	ЗадачиПопавшиеВРелиз.Параметры.УстановитьЗначениеПараметра("ПрименитьОтбор", Ложь);	
	ЗадачиПопавшиеВРелиз.Параметры.УстановитьЗначениеПараметра("НачалоРелиза", Объект.ДатаНачала);	
	ЗадачиПопавшиеВРелиз.Параметры.УстановитьЗначениеПараметра("ОкончаниеРелиза", Объект.ДатаРелиза);	
	ЗадачиПопавшиеВРелиз.Параметры.УстановитьЗначениеПараметра("ТекРелизВыпущен", Объект.РелизВыпущен);	
	
	ДатаРелизаДоИзменений = Объект.ДатаРелиза;
	ИнициализироватьШаги();
КонецПроцедуры


&НаКлиенте
Процедура Собрать(Команда)
	Если Элементы.грОшибка.Видимость Тогда
		Сообщить("Существуют задачи запланированные, но не сделанные в текущем релизе");
		Возврат;	
	КонецЕсли;
	Если Объект.ДатаРелиза <> НачалоДня(ТекущаяДата()) Тогда
		Сообщить("Необходимо изменить дату выпуска релиза");
		Возврат;
	КонецЕсли;
	Если ЭтаФорма.Модифицированность Тогда
		Сообщить("Необходимо сохраниться");  // так надо, потому что при сохранении есть диалоговое окно вопроса
		Возврат;
	КонецЕсли;
	Элементы.Вкладки.ТекущаяСтраница = Элементы.грПроцесс;
	ЗапуститьПроцессСборкиНаСервере();
	
	Данные = Новый Структура("released", Истина);
	ВзаимодействиеC_JIRA_КлиентСервер.ИзменитьДанныеВерсии(Формат(Объект.Код, "ЧГ="), Объект.Наименование, Данные);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗапуститьПроцессСборкиНаСервере()
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьШаги()
	Задания.ПолучитьЭлементы().Очистить();
	
	СтрокаЛогаРодитель = Задания.ПолучитьЭлементы().Добавить();
	СтрокаЛогаРодитель.Комментарий = "Сборка расширения";
	СтрокаЛогаРодитель.АдресХранилища = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор());
	СтрокаЛогаРодитель.Картинка = 0;
	
	СтрокаЛогаРодитель = Задания.ПолучитьЭлементы().Добавить();
	СтрокаЛогаРодитель.Комментарий = СтрШаблон("Выгрузка актуальной конфигурации из хранилища ""%1""", Константы.АдресХранилища.Получить());
	СтрокаЛогаРодитель.АдресХранилища = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор());
	СтрокаЛогаРодитель.Картинка = 0;
	ИнициализироватьВложенныеШаги(СтрокаЛогаРодитель);

	
	СтрокаЛогаРодитель = Задания.ПолучитьЭлементы().Добавить();
	СтрокаЛогаРодитель.Комментарий = "Обновление версии АЦК БУ";
	СтрокаЛогаРодитель.Картинка = 0;
	
	//СтрокаЛогаРодитель.ИдентификаторЗадания = ВыгрузитьНаСервере(НомерРевизии, СтрокаЛогаРодитель.АдресХранилища);
КонецПроцедуры


&НаСервере
Процедура ИнициализироватьВложенныеШаги(СтрокаЛогаРодитель)
	
	НовСтр = СтрокаЛогаРодитель.ПолучитьЭлементы().Добавить();
	НовСтр.Комментарий = "Создание временной файловой БД";
	НовСтр.Метод = "СоздатьВременнуюБД";
	НовСтр.Картинка = 0;
	
	НовСтр = СтрокаЛогаРодитель.ПолучитьЭлементы().Добавить();
	НовСтр.Комментарий = "Получить конфигурацию из хранилища";
	НовСтр.Метод = "ПолучитьКонфигурациюИзХранилища";
	НовСтр.ОбратныйМетод = "ПолучитьКонфигурациюИзВременногоХранилища";
	НовСтр.Картинка = 0;
КонецПроцедуры

#region callback

&НаКлиенте
Процедура ПолучитьКонфигурациюИзВременногоХранилища(АдресХранилища)
	ПолучитьФайл(АдресХранилища, ПутьККаталогуСРелизом + СтрШаблон("\%1.cf", Объект.Наименование), Ложь);
КонецПроцедуры

#endregion

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	Запрос = Новый Запрос(ЗадачиПопавшиеВРелиз.ТекстЗапроса);
	Запрос.Параметры.Вставить("КонечныеСтатусы", СтрРазделить("Закрыт,Сделан,Предоставлено ПР", ","));
	Запрос.Параметры.Вставить("ТекРелиз", Объект.Ссылка);
	Запрос.Параметры.Вставить("ПрименитьОтбор", Истина);	
	Запрос.Параметры.Вставить("НачалоРелиза", Объект.ДатаНачала);	
	Запрос.Параметры.Вставить("ОкончаниеРелиза", Объект.ДатаРелиза);
	Запрос.Параметры.Вставить("ТекРелизВыпущен", Объект.РелизВыпущен);	
	
	Элементы.грОшибка.Видимость = Не Запрос.Выполнить().Пустой();
КонецПроцедуры


&НаСервере
Процедура ОтборЗадачНаСервере()
	ЗадачиПопавшиеВРелиз.Параметры.УстановитьЗначениеПараметра("ПрименитьОтбор", ОтборПрименен);	
КонецПроцедуры


&НаКлиенте
Процедура ОтборЗадач(Команда)
	ОтборПрименен = Не ОтборПрименен;
	ОтборЗадачНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиЗадачиВДругуюВерсию(Команда)
	ВыделенныеСтроки = Элементы.ЗадачиПопавшиеВРелиз.ВыделенныеСтроки;
	СписокЗадач = Новый Массив();
	Для Каждого Стр Из ВыделенныеСтроки Цикл
		Если ТипЗнч(Стр) = Тип("СправочникСсылка.Задачи") Тогда
		  СписокЗадач.Добавить(Стр);
		КонецЕсли;
	КонецЦикла;
	
	Если СписокЗадач.Количество() = 0 Тогда
		Сообщить("Выделите строки с задачами");
		Возврат;	
	КонецЕсли;
	
	Парам = Новый Структура("РелизыПозжеЧем, ТолькоНеВыпущенные", ТекущаяДата(), Истина);
	ДД = Новый Структура("СписокЗадач", СписокЗадач);
	ОткрытьФорму("Справочник.Релизы.ФормаВыбора", Парам,,,,, Новый ОписаниеОповещения("ПеренестиЗадачиВДругуюВерсиюЗавершение", ЭтотОбъект, ДД), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиЗадачиВДругуюВерсиюЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат <> Неопределено Тогда
		ПереместитьВВерсию(ДополнительныеПараметры.СписокЗадач, Результат);	
		ЭтаФорма.Прочитать();
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПереместитьВВерсию(СписокЗадач, НоваяВерсия)
	Справочники.Релизы.ПереместитьВВерсию(СписокЗадач, НоваяВерсия);
КонецПроцедуры

&НаКлиенте
Процедура ЗадачиПопавшиеВРелизВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОткрытьВБраузере(Элемент, ВыбраннаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьВБраузере(Элемент, ВыбраннаяСтрока)
	ТекСтрока = Элемент.ДанныеСтроки(ВыбраннаяСтрока);
	Если ТекСтрока <> Неопределено Тогда
		ВзаимодействиеC_JIRA_КлиентСервер.ОткрытьЗадачуВБраузере(ТекСтрока.Номер);
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ДатаРелизаПриИзмененииЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	Если РезультатВопроса = КодВозвратаДиалога.ОК Тогда
		АктуализироватьВерсии();
		ДанныеВерсий = ПолучитьВерсииДляОбновления(ДатаРелизаДоИзменений, Объект.Ссылка);
		
		// обновляем данные тек версии
		Данные = Новый Структура("releaseDate", Формат(Объект.ДатаРелиза, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300"));
		ВзаимодействиеC_JIRA_КлиентСервер.ИзменитьДанныеВерсии(Формат(Объект.Код, "ЧГ="), Объект.Наименование, Данные, Ложь);	
		
		// обновляем данные следующих версий
		РазницаДат = Объект.ДатаРелиза - ДатаРелизаДоИзменений;
		Для Каждого Версия Из ДанныеВерсий Цикл
			Данные = Новый Структура("releaseDate", Формат(Версия.ДатаРелиза + РазницаДат, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300"));
			Если ЗначениеЗаполнено(Версия.ДатаНачала) Тогда
				Данные.Вставить("startDate", Формат(Версия.ДатаНачала + РазницаДат, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300"));
			КонецЕсли;
			ВзаимодействиеC_JIRA_КлиентСервер.ИзменитьДанныеВерсии(Формат(Версия.ID, "ЧГ="), Версия.Наименование, Данные, Ложь);		
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьВерсииДляОбновления(ДатаРелизаДоИзменений, ТекРелиз)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Релизы.ДатаРелиза КАК ДатаРелиза,
		|	Релизы.Код КАК ID,
		|	Релизы.Наименование КАК Наименование,
		|	Релизы.ДатаНачала КАК ДатаНачала
		|ИЗ
		|	Справочник.Релизы КАК Релизы
		|ГДЕ
		|	Релизы.Ссылка <> &ТекРелиз
		|	И Релизы.ДатаРелиза > &ДатаРелиза";
	
	Запрос.УстановитьПараметр("ДатаРелиза", ДатаРелизаДоИзменений);
	Запрос.УстановитьПараметр("ТекРелиз", ТекРелиз);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Ответ = Новый Массив();
	Пока Выборка.Следующий() Цикл
		Знч = Новый Структура("ДатаРелиза,ДатаНачала,ID,Наименование");
		ЗаполнитьЗначенияСвойств(Знч, Выборка);
		Ответ.Добавить(Знч);
	КонецЦикла;
	
	Возврат Ответ;
КонецФункции

	
&НаСервереБезКонтекста
Процедура АктуализироватьВерсии()
	Справочники.Релизы.ОбновитьВерсии();
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	Если Не ЗначениеЗаполнено(Объект.ДатаРелиза) Тогда
		Отказ = Истина;
		Сообщить("Дата должна быть заполнена");
		Возврат;
	КонецЕсли;  
	
	Если Объект.ДатаРелиза > ДатаРелизаДоИзменений Тогда
		ПоказатьВопрос(Новый ОписаниеОповещения("ДатаРелизаПриИзмененииЗавершение", ЭтотОбъект), "Даты всех последующих релизов будет изменена", РежимДиалогаВопрос.ОКОтмена);
	Иначе
		Данные = Новый Структура("releaseDate", Формат(Объект.ДатаРелиза, "ДФ=yyyy-MM-ddTHH:mm:ss.000+0300"));
		ВзаимодействиеC_JIRA_КлиентСервер.ИзменитьДанныеВерсии(Формат(Объект.Код, "ЧГ="), Объект.Наименование, Данные, Ложь);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ВкладкиПриСменеСтраницы(Элемент, ТекущаяСтраница)
	Если ТекущаяСтраница = Элементы.грReleaseNote Тогда
		СформироватьОписание();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура СформироватьОписание()
	Запрос = Новый Запрос(ЗадачиПопавшиеВРелиз.ТекстЗапроса);
	Запрос.Параметры.Вставить("КонечныеСтатусы", СтрРазделить("Закрыт,Сделан,Предоставлено ПР", ","));
	Запрос.Параметры.Вставить("ТекРелиз", Объект.Ссылка);
	Запрос.Параметры.Вставить("ПрименитьОтбор", Ложь);	
	Запрос.Параметры.Вставить("НачалоРелиза", Объект.ДатаНачала);	
	Запрос.Параметры.Вставить("ОкончаниеРелиза", Объект.ДатаРелиза);
	Запрос.Параметры.Вставить("ТекРелизВыпущен", Объект.РелизВыпущен);	
	
	Выборка = Запрос.Выполнить().Выбрать();
	ReleaseNote = "";
	Пока Выборка.Следующий() Цикл
		ReleaseNote = ReleaseNote + Строка(Выборка.Задача) + Символы.ПС;
		Если ЗначениеЗаполнено(Выборка.Родитель) Тогда
			Описание = СформироватьОписаниеПоЗадаче(Выборка.Родитель, Выборка.ЕстьКоммит);	
		Иначе
			Описание = СформироватьОписаниеПоЗадаче(Выборка.Задача, Выборка.ЕстьКоммит);	
		КонецЕсли;
		
		ReleaseNote = ReleaseNote + Символы.Таб + " - " + Описание + Символы.ПС + Символы.ПС;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Функция СформироватьОписаниеПоЗадаче(Задача, ЕстьКоммит)
	Ответ = "";
	КонечныеСтатусы = СтрРазделить("Закрыт,Сделан,Предоставлено ПР", ",");
	Выборка = Справочники.Задачи.ВыбратьИерархически(Задача);
	РазработкаЗакрыта = КонечныеСтатусы.Найти(Задача.Статус) <> Неопределено;   
	ТестированиеЗакрыта = КонечныеСтатусы.Найти(Задача.Статус) <> Неопределено;
	
	Пока Выборка.Следующий() Цикл
		Если Выборка.Тип.Родитель = Справочники.ТипыЗадач.Разработка Тогда
			РазработкаЗакрыта = КонечныеСтатусы.Найти(Выборка.Статус) <> Неопределено;
		КонецЕсли;
		Если Выборка.Тип.Родитель = Справочники.ТипыЗадач.Тестирование Тогда
			ТестированиеЗакрыта = КонечныеСтатусы.Найти(Выборка.Статус) <> Неопределено;
		КонецЕсли;
	КонецЦикла;
	
	Если ЕстьКоммит И (Не РазработкаЗакрыта) Тогда
		Ответ = "Задача частично выложена разработкой";
	КонецЕсли;
	Если (Не ЕстьКоммит) И РазработкаЗакрыта Тогда
		Ответ = "По задаче не было внесено правок";
	КонецЕсли;
	Если ЕстьКоммит И РазработкаЗакрыта И ТестированиеЗакрыта Тогда
		Ответ = "Задача проверяна";
	КонецЕсли;
	Если ЕстьКоммит И РазработкаЗакрыта И Не ТестированиеЗакрыта Тогда
		Ответ = "Задача сделана разработкой, но не проверяна";
	КонецЕсли;
	
	Возврат Ответ;
КонецФункции


&НаКлиенте
Процедура ОбновитьСПолучениемИзменений(Команда)
	ИдентификаторФЗ = ЗапускЗадачНаСервере();
	Элементы.ДеревоЗадачВРаботеОбновитьСПолучениемИзменений.Доступность = Не ЗначениеЗаполнено(ИдентификаторФЗ);
	ЭтаФорма.ПодключитьОбработчикОжидания("ПроверкаСтатусаРегЗадания", "1", Ложь);
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЗапускЗадачНаСервере()
	РЗ = РегламентныеЗадания.НайтиПредопределенное("ПолучениеЗадач");
	Если РЗ = Неопределено Тогда
		Сообщить("Не нашли регламентное задание");
		Возврат Неопределено;
	КонецЕсли;
	
	Если РЗ.Использование Тогда
		
		//проверика на выполнение в текущий момент
		Отбор = Новый Структура;
		Отбор.Вставить("Ключ", Строка(РЗ.УникальныйИдентификатор));
		Отбор.Вставить("Состояние", СостояниеФоновогоЗадания.Активно);		
		МассивЗаданий = ФоновыеЗадания.ПолучитьФоновыеЗадания(Отбор);
		
		Если МассивЗаданий.Количество() = 0 Тогда 
			НаименованиеФоновогоЗадания = "Запуск вручную: "+ РЗ.Метаданные.Синоним;
			ФЗ = ФоновыеЗадания.Выполнить(РЗ.Метаданные.ИмяМетода, РЗ.Параметры, Строка(РЗ.УникальныйИдентификатор), НаименованиеФоновогоЗадания);
			Возврат ФЗ.УникальныйИдентификатор;
		Иначе
			Сообщить("Задание уже запущено");
		КонецЕсли;
	КонецЕсли;
КонецФункции


&НаКлиенте
Процедура ПроверкаСтатусаРегЗадания() Экспорт 
	Если ОбщегоНазначенияСервер.ЗаданиеВыполнено(ИдентификаторФЗ) Тогда
		Элементы.ДеревоЗадачВРаботеОбновитьСПолучениемИзменений.Доступность = Истина;
		ЭтаФорма.ОтключитьОбработчикОжидания("ПроверкаСтатусаРегЗадания");
	КонецЕсли;
КонецПроцедуры
