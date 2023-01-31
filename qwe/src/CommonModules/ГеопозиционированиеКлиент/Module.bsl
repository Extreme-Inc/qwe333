// Функция возвращает имя провайдера геопозиционирования в зависимости от настроек

Функция ПолучитьИмяПровайдера() Экспорт
	
#Если МобильныйКлиент Тогда 
	Данные = ГеопозиционированиеСервер.ПолучитьИмяПровайдера();
	Провайдер = Неопределено;
	Если Данные.Выбор = ПредопределенноеЗначение("Перечисление.ИспользоватьПровайдерГеопозиционирования.СамыйЭкономичныйПровайдер") Тогда
		Провайдер = СредстваГеопозиционирования.ПолучитьСамогоЭнергоЭкономичногоПровайдера(Истина);
	ИначеЕсли Данные.Выбор = ПредопределенноеЗначение("Перечисление.ИспользоватьПровайдерГеопозиционирования.СамыйТочныйПровайдер") Тогда
		Провайдер = СредстваГеопозиционирования.ПолучитьСамогоТочногоПровайдера(Истина);
	Иначе
		Если НЕ ЗначениеЗаполнено(Данные.Имя) Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = НСтр("ru = 'Не выбран провайдер геопозиционирования!'", "ru");
			Сообщение.Сообщить();
            Возврат "";
		КонецЕсли;
		Провайдер = СредстваГеопозиционирования.ПолучитьПровайдера(Данные.Имя, Истина);
		Если Провайдер = Неопределено Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = НСтр("ru = 'Недоступен провайдер геопозиционирования! Попробуйте изменить установки.", "ru");
			Сообщение.Сообщить();
            Возврат "";
		КонецЕсли;
	КонецЕсли;
	Если Провайдер <> Неопределено Тогда
		Возврат Провайдер.Имя;
	КонецЕсли;
#КонецЕсли
	Возврат "";

КонецФункции

// Процедура обновляет утановленнные геозоны

Процедура ОбновитьГеозоны() Экспорт
	
	Покупатели =  ГеопозиционированиеСервер.ПолучитьПокупателей();
	
#Если МобильныйКлиент Тогда
	СредстваГеопозиционирования.ОтключитьОтслеживаниеВсехГеозон();
	Если Покупатели.Количество() > 0 Тогда
		НовыеГеозоны = Новый Массив();
		Для каждого Покупатель из Покупатели цикл
			Геозона = Новый Геозона(Покупатель.Ссылка, Покупатель.Наименование, Новый ГеографическиеКоординаты(Покупатель.Широта, Покупатель.Долгота), 300);
			НовыеГеозоны.Добавить(Геозона);
		КонецЦикла;
		Если СредстваГеопозиционирования.ПроверитьВозможностьВключенияОтслеживанияГеозон(НовыеГеозоны.Количество())  Тогда
			СредстваГеопозиционирования.ВключитьОтслеживаниеГеозон(НовыеГеозоны);
		Иначе
			Для каждого Геозона из НовыеГеозоны цикл
				Если СредстваГеопозиционирования.ПроверитьВозможностьВключенияОтслеживанияГеозон(1)  Тогда
					СредстваГеопозиционирования.ВключитьОтслеживаниеГеозон(Геозона);
				Иначе
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
#КонецЕсли
	 
КонецПроцедуры

// Функция выполняет попытку обновления текущего местоположения
//
// Возвращаемое значение:
//  Истина - попытка удачная

Функция ОбновитьМестоположение(ИмяПровайдера) Экспорт
    
#Если МобильныйКлиент Тогда 
	ИмяПровайдера = ПолучитьИмяПровайдера();
	Если НЕ ЗначениеЗаполнено(ИмяПровайдера) Тогда
	    Возврат Ложь;
	КонецЕсли;
	Если НЕ СредстваГеопозиционирования.ОбновитьМестоположение(ИмяПровайдера, 60) Тогда // Если провайдер доступен, то 60 секунд достаточно для определения местоположения
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Не удалось получить данные от провайдера геопозиционирования! Попробуйте изменить установки.", "ru");
		Сообщение.Сообщить();
        Возврат Ложь;
	КонецЕсли;
	Возврат Истина;
#КонецЕсли

	Возврат Ложь;
    
КонецФункции

#Если МобильныйКлиент Тогда 
	
Процедура ОбработкаУведомлений(Геозона, Положение, Параметры) Экспорт
	Если ОсновнойСерверДоступен() = Истина Тогда
		Если Положение = ПоложениеОтносительноГеозоны.Внутри Тогда
			ОбработатьУведомление(Геозона);
		КонецЕсли;
	КонецЕсли
КонецПроцедуры

Асинх Процедура ОбработатьУведомление(Геозона)
	Сообщение = Геозона.Представление + НСтр("ru = ': Вы приближаетесь к местоположению покупателя. Показать список его активных заказов?'", "ru");
	РезультатВопроса = Ждать ВопросАсинх(Сообщение,РежимДиалогаВопрос.ДаНет, Геозона);
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
	    ПараметрыФормы = Новый Структура("ДанныеГеозоны", Геозона.Данные);
	    ОткрытьФорму("Документ.Заказ.ФормаСписка", ПараметрыФормы,,Истина);
	КонецЕсли;
КонецПроцедуры

#КонецЕсли
