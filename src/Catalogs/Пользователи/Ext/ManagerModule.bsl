﻿Функция НайтиСоздатьПользователя(ДанныеПользователя) Экспорт 
	Перем Аватар;
	
	Если ДанныеПользователя = Неопределено Тогда
		Возврат Справочники.Пользователи.ПустаяСсылка();	
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.Пользователи");
		ЭлементБлокировки.УстановитьЗначение("Наименование", ДанныеПользователя["name"]);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();
		
		ПользовательСсылка =  Справочники.Пользователи.НайтиПоНаименованию(ДанныеПользователя["name"]);		
		ДанныеАватар = ДанныеПользователя["avatarUrls"];
		Если ДанныеАватар <> Неопределено Тогда
			СсылкаАватар = ДанныеПользователя["avatarUrls"]["48x48"];
			Аватар = ВзаимодействиеC_JIRA_Сервер.ВыполнитьGETЗапрос(СсылкаАватар, Истина);
		КонецЕсли;
		
		Пользователь = ?(ЗначениеЗаполнено(ПользовательСсылка), ПользовательСсылка.ПолучитьОбъект(), Справочники.Пользователи.СоздатьЭлемент());
		Пользователь.Email = ДанныеПользователя["emailAddress"];
		Пользователь.Наименование = ДанныеПользователя["name"];
		Пользователь.ФИО = ДанныеПользователя["displayName"];
		Пользователь.Аватар = Новый ХранилищеЗначения(Аватар);
		Пользователь.Записать();
		
		ЗафиксироватьТранзакцию();
		
		Возврат Пользователь.Ссылка;
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
КонецФункции

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	СтандартнаяОбработка = Данные.ФИО = Null ИЛИ Не Данные.Свойство("ФИО", Представление);  // для группы реквизит ФИО не доступен
КонецПроцедуры

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Поля.Добавить("ФИО");
	Поля.Добавить("Наименование");
КонецПроцедуры
