﻿
#Область ПроцедурыИФункцииДляРаботыСДокументомHTML

Функция ПолучитьДокументHTMLИзТекстаHTML(ТекстHTML)
	
	ЧтениеHTML = Новый ЧтениеHTML;
	ЧтениеHTML.УстановитьСтроку(ТекстHTML);
	
	ПостроительDOM = Новый ПостроительDOM;
	ДокументHTML = ПостроительDOM.Прочитать(ЧтениеHTML);
	
	ЧтениеHTML.Закрыть();
	
	Возврат ДокументHTML;
	
КонецФункции

Функция ПолучитьТекстHTMLИзОбъектаДокументHTML(ДокументHTML)
	
	ЗаписьHTML = Новый ЗаписьHTML;
	ЗаписьHTML.УстановитьСтроку();
	
	ЗаписьDOM = Новый ЗаписьDOM;
	ЗаписьDOM.Записать(ДокументHTML, ЗаписьHTML);
	
	Возврат ЗаписьHTML.Закрыть();
	
КонецФункции

Процедура ДобавитьТекстовыйУзел(ЭлементРодитель, СтрокаТекста)
	
	ДокументВладелец = ЭлементРодитель.ДокументВладелец;
	ТекстовыйУзел = ДокументВладелец.СоздатьТекстовыйУзел(СтрокаТекста);
	ЭлементРодитель.ДобавитьДочерний(ТекстовыйУзел);
	
	// Добавим перенос строки.
	ЭлементРодитель.ДобавитьДочерний(ДокументВладелец.СоздатьЭлемент("br"));
	
КонецПроцедуры

Функция ДобавитьОбычныйТекстВТекстHTML(ТекстHTML, Текст, ВНачало = Истина) Экспорт
	
	Если ПустаяСтрока(Текст) Тогда
		Возврат ТекстHTML;
	КонецЕсли;
	
	ДокументHTML = ПолучитьДокументHTMLИзТекстаHTML(ТекстHTML);
	
	ЭлементТело = ДокументHTML.Тело;
	Если ЭлементТело = Неопределено Тогда
		ЭлементТело = ДокументHTML.СоздатьЭлемент("body");
		ДокументHTML.Тело = ЭлементТело;
	КонецЕсли;
	
	ЭлементБлок = ДокументHTML.СоздатьЭлемент("p");
	
	ПервыйДочерний = Неопределено;
	Если ВНачало Тогда
		// Если текст нужно вставить в самое начало HTML, тогда определяем первый дочерний узел.
		ПервыйДочерний = ЭлементТело.ПервыйДочерний;
	КонецЕсли;
	
	Если ПервыйДочерний = Неопределено Тогда
		// Если первый дочерний узел не определен, тогда просто добавляем дочерний.
		ЭлементТело.ДобавитьДочерний(ЭлементБлок);
	Иначе
		// Иначе вставляем текстовый узел перед первым дочерним.
		ЭлементТело.ВставитьПеред(ЭлементБлок, ПервыйДочерний);
	КонецЕсли;
	
	КоличествоСтрок = СтрЧислоСтрок(Текст);
	Для Счетчик = 1 По КоличествоСтрок Цикл
		ДобавитьТекстовыйУзел(ЭлементБлок, СтрПолучитьСтроку(Текст, Счетчик));
	КонецЦикла;
	
	Возврат ПолучитьТекстHTMLИзОбъектаДокументHTML(ДокументHTML);
	
КонецФункции

#КонецОбласти
