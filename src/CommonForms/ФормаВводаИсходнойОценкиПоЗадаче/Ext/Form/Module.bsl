﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЕстьСвязь = Истина;
	Если ЗначениеЗаполнено(Параметры.Задача) Тогда
		Задача = Справочники.Задачи.НайтиПоКоду(Параметры.Задача);
	КонецЕсли;
	
	Релиз = Справочники.Релизы.ПолучитьРелизНаДату(ТекущаяДатаСеанса());
	Если Релиз.РелизВыпущен Или Релиз.РелизСобран Тогда
		Релиз = Справочники.Релизы.ПолучитьАктуальныйРелиз();
	КонецЕсли;

	ДатаЗавершения = Параметры.ДатаЗавершения;
	Если Не ЗначениеЗаполнено(ДатаЗавершения) И ЗначениеЗаполнено(Релиз) Тогда  
		//РабДень = Константы.РабочийДень.Получить();
		//РабДень = ?(РабДень = 0, 8, РабДень);
		//КолКалендарныхСекунд = (Параметры.Приоритет.СрокРешения / РабДень * 24 * 60 * 60);
		ДатаЗавершения = Релиз.ДатаРелиза;// ТекущаяДатаСеанса() + КолКалендарныхСекунд;
	КонецЕсли;
	
	ОбновитьДаты(ДатаЗавершения);
			
	Параметры.Свойство("ОбновитьТолькоОценку", ОбновитьТолькоОценку);
	УстановитьЗначенияПоУмолчанию();
	ОбновитьДоступностьЭлементов();
КонецПроцедуры

&НаСервере
Процедура ОбновитьДаты(ДатаЗавершения)
	ДатаЗавершенияОбщая = ДатаЗавершения;
	Если ДатаЗавершенияОбщая >= ТекущаяДата() Тогда
		Разница = (ДатаЗавершенияОбщая - ТекущаяДата()); 
		ДатаЗавершенияРазработка = ТекущаяДата() + Разница * ОбщегоНазначенияКлиентСервер.КоэффициентРазработки();
		ДатаЗавершенияТестирование = ДатаЗавершенияОбщая;
	Иначе
		ДатаЗавершенияРазработка = Дата(1,1,1);
		ДатаЗавершенияТестирование = Дата(1,1,1);
	КонецЕсли;
КонецПроцедуры


&НаСервере
Процедура ОбновитьДоступностьЭлементов()
	Элементы.ДатаЗавершенияОбщая.ТолькоПросмотр = ОбновитьТолькоОценку;
	Элементы.ДатаЗавершенияРазработка.ТолькоПросмотр = ОбновитьТолькоОценку;
	Элементы.ДатаЗавершенияТестирование.ТолькоПросмотр = ОбновитьТолькоОценку;
	Элементы.Бюджет.ТолькоПросмотр = ОбновитьТолькоОценку;
	Элементы.БюджетРазработка.ТолькоПросмотр = ОбновитьТолькоОценку;
	Элементы.БюджетТестирования.ТолькоПросмотр = ОбновитьТолькоОценку;
	Элементы.ИсполнительТестирование.ТолькоПросмотр = ОбновитьТолькоОценку;
	Элементы.ИсполнительРазработка.ТолькоПросмотр = ОбновитьТолькоОценку;
	
	Если Параметры.ДатуЗавершенияУстановилАвтор Тогда
		Элементы.ДатаЗавершенияОбщая.ЦветРамки = Новый Цвет(255, 0, 0);
		Элементы.ДатаЗавершенияРазработка.ЦветРамки = Новый Цвет(255, 0, 0);
		Элементы.ДатаЗавершенияТестирование.ЦветРамки = Новый Цвет(255, 0, 0);
		Элементы.ДатаЗавершенияОбщая.Доступность = Ложь;
		Элементы.ДатаЗавершенияРазработка.Доступность = Ложь;
		Элементы.ДатаЗавершенияТестирование.Доступность = Ложь;
		Элементы.Декорация1.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьЗначенияПоУмолчанию()
	Если ЗначениеЗаполнено(Параметры.БюджетПУ) Тогда
		БюджетОсновной = Параметры.БюджетПУ;
		БюджетРазработка = Параметры.БюджетПУ;
		БюджетТестирования = Параметры.БюджетПУ;
	Иначе
		БюджетОсновной = Справочники.Пользователи.Разработка.БюджетПУПоУмолчанию;
		БюджетРазработка = Справочники.Пользователи.Разработка.БюджетПУПоУмолчанию;
		БюджетТестирования = Справочники.Пользователи.Тестирование.БюджетПУПоУмолчанию;
	КонецЕсли;
	
	ИсполнительРазработка = Справочники.Пользователи.Разработка.ЛидГруппы;
	
	Если ЗначениеЗаполнено(Задача) И Задача.Автор.Родитель = Справочники.Пользователи.Тестирование Тогда
		ИсполнительТестирование = Задача.Автор;
	Иначе
		ИсполнительТестирование = Справочники.Пользователи.Тестирование.ЛидГруппы;		
	КонецЕсли;
КонецПроцедуры


&НаКлиенте                                                      
Процедура ПриОткрытии(Отказ)
	ОбновитьЭлементы();                                                       
КонецПроцедуры

&НаКлиенте   
Функция ЕстьДопНастройки()
	Если Параметры.Статус <> "Новый" Тогда
		Возврат Ложь;	
	КонецЕсли;
	
	ДанныеПерехода = ВзаимодействиеC_JIRA_КлиентСервер.ПолучитьДанныеПерехода(Параметры.Задача, "Принят");
	
	ДанныеПоля = ДанныеПерехода["fields"][БФТ_ОбщиеМетодыАРМаСборокНаКлиентеНаСервере.КастомныеПоляJIRA("Бюджет")];
	Возврат ДанныеПоля <> Неопределено;
КонецФункции

&НаКлиенте
Процедура ОК(Команда)
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;	
	КонецЕсли;
	
	ПроверитьПревышениеОбъема(Релиз, ОценкаОбщая);
	
	Оценки = Новый Структура("Общая,Разработка,Тестирование", ОценкаОбщая, ОценкаРазработка, ОценкаТестирования);
	ДатыЗавершения = Новый Структура("ДатаЗавершенияОбщая,ДатаЗавершенияРазработка,ДатаЗавершенияТестирование", ДатаЗавершенияОбщая, ДатаЗавершенияРазработка, ДатаЗавершенияТестирование);
	Данные = Новый Структура("Оценки, Версия", Оценки, Релиз);
	
	Если Не ОбновитьТолькоОценку Тогда
		Данные.Вставить("ДатыЗавершения", ДатыЗавершения);
		
		Бюджеты = Новый Структура("Общий,Разработка,Тестирование", БюджетОсновной, БюджетРазработка, БюджетТестирования);
		Данные.Вставить("Бюджеты", Бюджеты);
		
		Исполнители = Новый Структура("Разработка,Тестирование", ИсполнительРазработка, ИсполнительТестирование);
		Данные.Вставить("Исполнители", Исполнители);
		
		Данные.Вставить("ДопНастройки", Новый Структура("НеСоздаватьАналитику, НеСоздаватьДокументирование", НеСоздаватьАналитику, НеСоздаватьДокументирование));
	КонецЕсли;
	
	ОповеститьОВыборе(Данные);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПроверитьПревышениеОбъема(Релиз, ОценкаОбщая)
	Справочники.Релизы.ПроверитьПревышениеОбъема(Релиз, ОценкаОбщая);
КонецПроцедуры


&НаКлиенте
Процедура Отмена(Команда)
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ОценкаПриИзменении(Элемент)
	Если ЕстьСвязь Тогда
		ОценкаРазработка = ОценкаОбщая * ОбщегоНазначенияКлиентСервер.КоэффициентРазработки();
		ОценкаТестирования = ОценкаОбщая * ОбщегоНазначенияКлиентСервер.КоэффициентТестирования();
		ОбновитьЭлементы();
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура Связь(Команда)
	ЕстьСвязь = Не ЕстьСвязь;
	ОбновитьЭлементы();
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЭлементы()
	Элементы.СвязьОценка.Заголовок = ?(ЕстьСвязь, "Убрать связь", "Установить связь");
	Элементы.грДопНастройки.Доступность = ЕстьДопНастройки();
	
	НеСоздаватьАналитику = Элементы.грДопНастройки.Доступность;
	НеСоздаватьДокументирование = Элементы.грДопНастройки.Доступность;

	ЕмкостьРелиза = ПолучитьЕмкостьРелиза(Релиз, ОценкаОбщая);
	Элементы.ИнфоПоЗагрузке.Заголовок = СтрШаблон("В релизе не закрытых задач на ""%1"" ч. Остаток часов ""%2""", ЕмкостьРелиза.Оценка, ЕмкостьРелиза.ОстатокЧасов);
	Если ЕмкостьРелиза.Оценка > ЕмкостьРелиза.ОстатокЧасов Тогда
		Элементы.ИнфоПоЗагрузке.ЦветТекста = Новый Цвет(255, 0, 0);
	Иначе
		Элементы.ИнфоПоЗагрузке.ЦветТекста = Новый Цвет(0, 0, 255);
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьЕмкостьРелиза(Релиз, ОценкаОбщая)
	Возврат Справочники.Релизы.ЕмкостьРелиза(Релиз, ОценкаОбщая);
КонецФункции


&НаКлиенте
Процедура ОценкаРазработкаПриИзменении(Элемент)
	Если ЕстьСвязь Тогда
		ОценкаОбщая = ОценкаРазработка / ОбщегоНазначенияКлиентСервер.КоэффициентРазработки();
		ОценкаТестирования = ОценкаОбщая * ОбщегоНазначенияКлиентСервер.КоэффициентТестирования();
		ОбновитьЭлементы();
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ОценкаТестированияПриИзменении(Элемент)
	Если ЕстьСвязь Тогда
		ОценкаОбщая = ОценкаТестирования / ОбщегоНазначенияКлиентСервер.КоэффициентТестирования();
		ОценкаРазработка = ОценкаОбщая * ОбщегоНазначенияКлиентСервер.КоэффициентРазработки();
		ОбновитьЭлементы();
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ДатаЗавершенияОбщаяПриИзменении(Элемент)
	Если ДатаЗавершенияОбщая < ТекущаяДата() Тогда
		ДатаЗавершенияОбщая = Дата(1,1,1);	
		Возврат;
	КонецЕсли;
	
	Если ЕстьСвязь Тогда
		ДатаЗавершенияТестирование = ДатаЗавершенияОбщая;
		Разница = (ДатаЗавершенияОбщая - ТекущаяДата()); 
		ДатаЗавершенияРазработка = ТекущаяДата() + Разница * ОбщегоНазначенияКлиентСервер.КоэффициентРазработки();
	КонецЕсли;
КонецПроцедуры

  
&НаКлиенте
Процедура ДатаЗавершенияРазработкаПриИзменении(Элемент)
	Если ДатаЗавершенияРазработка < ТекущаяДата() Тогда
		ДатаЗавершенияРазработка = Дата(1,1,1);	
		Возврат;
	КонецЕсли;
	
	Если ЕстьСвязь Тогда
		Разница = (ДатаЗавершенияРазработка - ТекущаяДата()); 
		ДатаЗавершенияОбщая = ТекущаяДата() + Разница / ОбщегоНазначенияКлиентСервер.КоэффициентРазработки();
		ДатаЗавершенияТестирование = ДатаЗавершенияОбщая; 
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ДатаЗавершенияТестированиеПриИзменении(Элемент)
	Если ДатаЗавершенияТестирование < ТекущаяДата() Тогда
		ДатаЗавершенияТестирование = Дата(1,1,1);	
		Возврат;
	КонецЕсли;
	
	Если ЕстьСвязь Тогда
		ДатаЗавершенияОбщая = ДатаЗавершенияТестирование;
		Разница = (ДатаЗавершенияОбщая - ТекущаяДата()); 
		ДатаЗавершенияРазработка = ТекущаяДата() + Разница * ОбщегоНазначенияКлиентСервер.КоэффициентРазработки();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьТолькоСтоимостьПриИзменении(Элемент)
	ОбновитьДоступностьЭлементов();
КонецПроцедуры

&НаКлиенте
Процедура БюджетПриИзменении(Элемент)
	БюджетРазработка = БюджетОсновной;
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьБюджеты(Команда)
	Если Не ЗначениеЗаполнено(Параметры.Задача) Тогда
		Сообщить("Обновить бюджеты невозможно, в контекст формы не передан номер задачи.");
		Возврат;
	КонецЕсли;
	
	ДанныеПерехода = ВзаимодействиеC_JIRA_КлиентСервер.ПолучитьДанныеПерехода(Параметры.Задача, "Принят");
	
	ДанныеПоля = ДанныеПерехода["fields"][БФТ_ОбщиеМетодыАРМаСборокНаКлиентеНаСервере.КастомныеПоляJIRA("Бюджет")];
	Если ДанныеПоля = Неопределено Тогда
		Сообщить("Не удалось обновить бюджеты. Не получили данные бюджета");
		Возврат;
	КонецЕсли;
	
	ОбновитьБюджетыНаСервере(ДанныеПоля["allowedValues"]);
	Сообщить("Бюджеты обновлены");
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОбновитьБюджетыНаСервере(ДанныеБюджетов)
	Для Каждого Данные Из ДанныеБюджетов Цикл
		Справочники.БюджетыПУ.НайтиСоздатьБюджет(Данные);
	КонецЦикла;
КонецПроцедуры


&НаКлиенте
Процедура РелизПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Релиз) Тогда  
		ОбновитьДаты(ОбщегоНазначенияСервер.ЗначениеРеквизитаОбъекта(Релиз, "ДатаРелиза"));
		ОбновитьЭлементы();
	КонецЕсли;
КонецПроцедуры

