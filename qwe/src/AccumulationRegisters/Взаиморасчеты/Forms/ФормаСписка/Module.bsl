
//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ 
// 
 
// Обработчик команды ВсеВзаиморасчеты
&НаКлиенте
Процедура ВсеВзаиморасчетыВыполнить()
	ТекущаяСтрока = Элементы.Список.ТекущаяСтрока;
	СтруктураПараметров = Новый Структура("ТекущаяСтрока", ТекущаяСтрока);
	ОткрытьФорму("РегистрНакопления.Взаиморасчеты.ФормаСписка", СтруктураПараметров, , Истина);
КонецПроцедуры

