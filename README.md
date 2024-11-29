# OK-AdvFractalSweep
Торговый советник для MetaTrader 5, который получает данные от внешнего REST-сервера для построения индикатора

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me)
* https://docs.google.com/document/d/1uVf44NRM1c1Zju0DkWYgsO-Vwy2DcKiAImO5_usa7tA/edit?tab=t.0
* Version: 1.00

!!! warning ПРЕДУПРЕЖДЕНИЕ
    1. Торговая стратегия определена клиентом, и автор не несет за нее ответственности.
    2. Бот не гарантирует прибыль.
    3. Бот не гарантирует 100% защиты депозита.
    4. Использование бота на свой страх и риск.

## Что нового

```
```

## Установка

1. **Обновите терминал MetaTrader 5 до последней версии:** `Help->Check For Updates->Latest Release Version`. 
    - Если советник или индикатор не запускается, то проверьте сообщения на вкладке `Journal`. Возможно вы не обновили терминал до нужной версии.
    - Иногда для тестирования советников рекомендуется обновить терминал до самой последней бета-версии: `Help->Check For Updates->Latest Beta Version`. На прошлых версиях советник может не запускаться, потому что скомпилирован на последней версии терминала. В этом случае вы увидите сообщения на вкладке `Journal` об этом.
2. **Скопируйте файл бота `*.ex5` в каталог данных** терминала `MQL5\Experts\`. Открыть каталог данных терминала `File->Open Data Folder`.
3. **Установите бесплатный индикатор `Structure Blocks`** из маркета MetaTrader 5. Введите в строку поиска "Structure Blocks" и в открывшемся окне нажмите установить. Установка из маркета возможна только после логина в телеграмме в ваш аккаунт MetaQuotes.
8. **Откройте график нужной пары**.
9. **Переместите советника из окна `Навигатор` на график**.
10. **Установите в настройках бота галочку `Allow Auto Trading`**.
11. **Включите режим автоторговли** в терминале, нажав кнопку `Algo Trading` на главной панели инструментов.

## Требования


## Настройки



#### 1. ИНТЕРФЕЙС (UI)
- [x] `UI_TRD_ENB`: Показать грубину тренда
- [x] `UI_COL_FLT`: Цвет флэта
- [x] `UI_COL_UP`: Цвет бычьего тренда
- [x] `UI_COL_DWN`: Цвет медвежьего тренда

#### 2. ОПОВЕЩЕНИЯ (ALR)
- [x] `ALR_TF_PUP`: ТФ с оповещениями в терминал (';' разд.)
- [x] `ALR_TF_MOB`: ТФ с оповещениями на телефон (';' разд.)
       
#### 3. MISCELLANEOUS (MSC)
- [x] `MSC_MGC`: Expert Adviser ID - Magic
- [x] `MSC_EGP`: Expert Adviser Global Prefix
- [x] `MSC_LOG_LL`: Log Level