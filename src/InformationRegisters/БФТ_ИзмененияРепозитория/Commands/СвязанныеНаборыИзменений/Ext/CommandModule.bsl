﻿/////////////// Защита модуля ///////////////
// @protect                                //
/////////////////////////////////////////////


#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
  Перем НомерРевизии;
  
  Если ПараметрыВыполненияКоманды.Источник = Неопределено Тогда
    Возврат;  
  КонецЕсли;
  
  Если ОбщегоНазначенияКлиентСервер.НаличиеСвойстваУОбъекта(ПараметрыВыполненияКоманды.Источник, "Запись") 
       И ПараметрыВыполненияКоманды.Источник.Запись.Свойство("НомерРевизии", НомерРевизии) Тогда
       ПараметрыФормы = Новый Структура("НомерРевизии", НомерРевизии);
       
    ОткрытьФорму("Справочник.БФТ_НаборыИзменений.ФормаСписка", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка);
  КонецЕсли;
КонецПроцедуры

#КонецОбласти