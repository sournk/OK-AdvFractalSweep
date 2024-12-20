//+------------------------------------------------------------------+
//|                                   OK-AdvFractalSweep-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"


#include "CAdvFractalSweepBot.mqh"


input  group                    "1. СЕТАП (SET)"
input  uint                     Inp_SET_FDP                                             = 24*60;                             // FDP: Глубина поиска фракталов, баров
input  ENUM_AFS_FRACTAL_TYPE    Inp_SET_FRT                                             = AFS_FRACTAL_TYPE_WILLIAMS;         // FRT: Тип фрактала
input  uint                     Inp_SET_FPD_BC                                          = 3;                                 // FPD_BC: PADD: Количество баров вокруг пика фрактала, шт
input  bool                     Inp_SET_FPD_PS                                          = true;                              // FPD_PS: PADD: Пики баров фрактала упрорядочены
input  bool                     Inp_SET_FPD_BS                                          = false;                             // FPD_BS: PADD: Основания баров фрактала упрорядочены
input  uint                     Inp_SET_FCS_NP                                          = 2;                                 // FCS_NP: CUSTOM35: Number of periods
input  uint                     Inp_SET_FCS_35                                          = 5;                                 // FCS_35: CUSTOM35: Choose between 3 or 5 bar fractals
input  ENUM_TIMEFRAMES          Inp_SET_TTF                                             = PERIOD_CURRENT;                    // TTF: TF определения тренда

input  group                    "2. ВХОД (ENT)"
input  uint                     Inp_ENT_GN_SLPG                                         = 5;                                 // GN_SLPG: Max проскальзывание, пункт (0-откл)
input  double                   Inp_ENT_GN_MGPR                                         = 50.0;                              // GN_MGPR: Max доля маржи от баланса после входа, % (0-откл)

input  group                    "2.1. ВХОД ПО ТРЕНДУ ↑↑/↓↓ (ENT)"
input  double                   Inp_ENT_OT_LOT                                          = 5.0;                               // OT_LOT: ↑↑/↓↓: Лот
input  uint                     Inp_ENT_OT_SLD                                          = 100;                               // OT_SLD: ↑↑/↓↓: Стоплосс, пункт
input  uint                     Inp_ENT_OT_TPD                                          = 250;                               // OT_TPD: ↑↑/↓↓: Тейкпрофит, пункт

input  group                    "2.2. ВХОД ПРОТИВ ТРЕНДА ↑↓/↓↑ (ENT)"
input  double                   Inp_ENT_AT_LOT                                          = 5.0;                               // AT_LOT: ↑↓/↓↑: Лот
input  uint                     Inp_ENT_AT_SLD                                          = 100;                               // AT_SLD: ↑↓/↓↑: Стоплосс, пункт
input  uint                     Inp_ENT_AT_TPD                                          = 150;                               // AT_TPD: ↑↑/↓↓: Тейкпрофит, пункт

input  group                    "2.3. ВХОД ВО ФЛЭТЕ → (ENT)"
input  double                   Inp_ENT_FL_LOT                                          = 5.0;                               // FL_LOT: →: Лот
input  uint                     Inp_ENT_FL_SLD                                          = 100;                               // FL_SLD: →: Стоплосс, пункт
input  uint                     Inp_ENT_FL_TPD                                          = 150;                               // FL_TPD: →: Тейкпрофит, пункт

input  group                    "2.4. ВХОД ПОСЛЕ ВРЕМЕНИ T (ENT)"
input  uint                     Inp_ENT_TM_HRS                                          = 17;                                // TM_HRS: T: Час начала (>24-откл)
input  double                   Inp_ENT_TM_LOT                                          = 5.0;                               // TM_LOT: T: Лот
input  uint                     Inp_ENT_TM_SLD                                          = 100;                               // TM_SLD: T: Стоплосс, пункт
input  uint                     Inp_ENT_TM_TPD                                          = 150;                               // TM_TPD: T: Тейкпрофит, пункт

input  group                    "3. ФИЛЬТРЫ (FIL)"
input  uint                     Inp_FIL_GN_SPRD                                         = 5;                                 // GN_SLD: Max спред, пункт (0-откл)
input  uint                     Inp_FIL_GN_PGAP                                         = 25;                                // GN_PGAP: Max ценовой гэп, пункт (0-откл)
input  uint                     Inp_FIL_GN_POPN                                         = 1;                                 // GN_POPN: Max кол-во позиций в рынке, шт (0-откл)
input  uint                     Inp_FIL_GN_PPDN                                         = 5;                                 // GN_PPDN: Max кол-во позиций в день, шт (0-откл)
input  uint                     Inp_FIL_GN_PSLN                                         = 2;                                 // GN_PSLN: Max кол-во SL позиций в день, шт (0-откл)
input  string                   Inp_FIL_TM_STRT                                         = "09:00";                           // TM_STRT: Время начала открытия позиций (формат HH:MM)
input  string                   Inp_FIL_TM_FNSH                                         = "19:00";                           // TM_FNSH: Время окончания открытия позиций (формат HH:MM)
input  bool                     Inp_FIL_TM_CLEN                                         = true;                              // TM_CLEN: Закрыть позиции принудительно в HH:MM
input  string                   Inp_FIL_TM_CLTM                                         = "22:00";                           // TM_CLTM: Время принудительного закрытия позиций (формат HH:MM)
input  bool                     Inp_FIL_NS_ENBL                                         = true;                              // NS_ENBL: Включить фильтр новостей (не работает в тестере)
input  uint                     Inp_FIL_NS_FRMN                                         = 5;                                 // NS_FRMN: Фильтровать до выхода новости, мин
input  uint                     Inp_FIL_NS_TOMN                                         = 5;                                 // NS_TOMN: Фильтровать после выхода новости, мин
input  ENUM_CALENDAR_EVENT_IMPORTANCE Inp_FIL_NS_IMPT                                   = CALENDAR_IMPORTANCE_HIGH;          // NS_IMPT: Начиная с какой важности фильтровать новости

input  group                    "3.1. ФИЛЬТРЫ ВОСХ+ЛОНГ ↑+↑ (FIL)"
input  bool                     Inp_FIL_UL_ENBL                                         = true;                              // UL_ENBL: ↑+↑: Тогровля включена
input  uint                     Inp_FIL_UL_WICK                                         = 3;                                 // UL_WICK: ↑+↑: Min дистанция свипа, пункт
input  uint                     Inp_FIL_UL_FRCN                                         = 5;                                 // UL_FRCN: ↑+↑: Min дистанция от Фрактала до C или O, пункт
input  uint                     Inp_FIL_UL_FRCX                                         = 85;                                // UL_FRCX: ↑+↑: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_UL_FRPF                                         = 30;                                // UL_FRPF: ↑+↑: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "3.2. ФИЛЬТРЫ ВОСХ+ШОРТ ↑+↓ (FIL)"
input  bool                     Inp_FIL_US_ENBL                                         = true;                              // US_ENBL: ↑+↓: Тогровля включена
input  uint                     Inp_FIL_US_WICK                                         = 3;                                 // US_WICK: ↑+↓: Min дистанция свипа, пункт
input  uint                     Inp_FIL_US_FRCN                                         = 5;                                 // US_FRCN: ↑+↓: Min дистанция от Фрактала до C или O, пункт
input  uint                     Inp_FIL_US_FRCX                                         = 60;                                // US_FRCX: ↑+↓: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_US_FRPF                                         = 75;                                // US_FRPF: ↑+↓: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "3.3. ФИЛЬТРЫ НИЗХ+ЛОНГ ↓+↑ (FIL)"
input  bool                     Inp_FIL_DL_ENBL                                         = true;                              // DL_ENBL: ↓+↑: Тогровля включена
input  uint                     Inp_FIL_DL_WICK                                         = 3;                                 // DL_WICK: ↓+↑: Min дистанция свипа, пункт
input  uint                     Inp_FIL_DL_FRCN                                         = 5;                                 // DL_FRCN: ↓+↑: Min дистанция от Фрактала до C или O, пункт
input  uint                     Inp_FIL_DL_FRCX                                         = 60;                                // DL_FRCX: ↓+↑: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_DL_FRPF                                         = 75;                                // DL_FRPF: ↓+↑: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "3.4. ФИЛЬТРЫ НИЗХ+ШОРТ ↓+↓ (FIL)"
input  bool                     Inp_FIL_DS_ENBL                                         = true;                              // DS_ENBL: ↓+↓: Тогровля включена
input  uint                     Inp_FIL_DS_WICK                                         = 3;                                 // DS_WICK: ↓+↓: Min дистанция свипа, пункт
input  uint                     Inp_FIL_DS_FRCN                                         = 5;                                 // DS_FRCN: ↓+↓: Min дистанция от Фрактала до C или O, пункт
input  uint                     Inp_FIL_DS_FRCX                                         = 85;                                // DS_FRCX: ↓+↓: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_DS_FRPF                                         = 30;                                // DS_FRPF: ↓+↓: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "3.5. ФИЛЬТРЫ ФЛЭТ+ЛОНГ →+↑ (FIL)"
input  bool                     Inp_FIL_FL_ENBL                                         = true;                              // FL_ENBL: →+↑: Тогровля включена
input  uint                     Inp_FIL_FL_WICK                                         = 3;                                 // FL_WICK: →+↑: Min дистанция свипа, пункт
input  uint                     Inp_FIL_FL_FRCN                                         = 5;                                 // FL_FRCN: →+↑: Min дистанция от Фрактала до C или O, пункт
input  uint                     Inp_FIL_FL_FRCX                                         = 60;                                // FL_FRCX: →+↑: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_FL_FRPF                                         = 75;                                // FL_FRPF: →+↑: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "3.6. ФИЛЬТРЫ ФЛЭТ+ШОРТ →+↓ (FIL)"
input  bool                     Inp_FIL_FS_ENBL                                         = true;                              // FS_ENBL: →+↓: Тогровля включена
input  uint                     Inp_FIL_FS_WICK                                         = 3;                                 // FS_WICK: →+↓: Min дистанция свипа, пункт
input  uint                     Inp_FIL_FS_FRCN                                         = 5;                                 // FS_FRCN: →+↓: Min дистанция от Фрактала до C или O, пункт
input  uint                     Inp_FIL_FS_FRCX                                         = 60;                                // FS_FRCX: →+↓: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_FS_FRPF                                         = 75;                                // FS_FRPF: →+↓: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "4. ГРАФИКА (UI)"
input  color                    Inp_UI_COL_FL                                           = clrLightGray;                      // UI_COL_FL: Цвет флэта
input  color                    Inp_UI_COL_UP                                           = clrLightGreen;                     // UI_COL_UP: Цвет бычьего тренда
input  color                    Inp_UI_COL_DN                                           = clrPink;                           // UI_COL_DN: Цвет медвежьего тренда
input  bool                     Inp_UI_IFR_EN                                           = true;                              // UI_IFR_EN: Добавить индикаторы 'PADD-Fractal' при запуске
input  bool                     Inp_UI_ISB_EN                                           = false;                             // UI_ISB_EN: Добавить индикаторы 'Struture Blocks' при запуске

input  group                    "5. MISCELLANEOUS (MSC)"
input  ulong                    Inp_MS_MGC                                              = 20241129;                          // MSC_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                                              = "OKAFS";                           // MSC_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                                           = LogLevel(INFO);                    // MSC_LOG_LL: Log Level
sinput string                   Inp_MS_LOG_FI                                           = "";                                // MSC_LOG_FI: Log Filter IN String (use ';' as sep)
sinput string                   Inp_MS_LOG_FO                                           = "";                                // MSC_LOG_FO: Log Filter OUT String (use ';' as sep)
       bool                     Inp_MS_COM_EN                                           = false;                             // MSC_COM_EN: Comment Enable (turn off for fast testing)
       uint                     Inp_MS_COM_IS                                           = 5;                                 // MSC_COM_IS: Comment Interval, Sec
       bool                     Inp_MS_COM_CW                                           = true;                              // MSC_COM_EW: Comment Custom Window
       
       long                     Inp_PublishDate                                         = 20241130;                          // Date of publish
       int                      Inp_DurationBeforeExpireSec                             = 10*24*60*60;                       // Duration before expire, sec
       

CAdvFractalSweepBot             bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  logger.Init(Inp_MS_EGP, Inp_MS_LOG_LL);
  logger.FilterInFromStringWithSep(Inp_MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(Inp_MS_LOG_FO, ";");
  
  //if (TimeCurrent() > StringToTime((string)Inp_PublishDate) + Inp_DurationBeforeExpireSec) {
  //  logger.Critical("Test version is expired", true);
  //  return(INIT_FAILED);
  //}  
  
  trade.Init(Symbol(), Inp_MS_MGC, Inp_ENT_GN_SLPG, GetPointer(logger));

  CAdvFractalSweepBotInputs inputs;
  inputs.SET_FDP = Inp_SET_FDP;
  inputs.SET_FRT = Inp_SET_FRT;
  inputs.SET_FPD_BC = Inp_SET_FPD_BC;
  inputs.SET_FPD_BS = Inp_SET_FPD_BS;
  inputs.SET_FPD_PS = Inp_SET_FPD_PS;
  inputs.SET_FCS_NP = Inp_SET_FCS_NP;
  inputs.SET_FCS_35 = Inp_SET_FCS_35;
  inputs.SET_TTF = Inp_SET_TTF;
  
  inputs.FIL_GN_POPN = Inp_FIL_GN_POPN;
  inputs.FIL_GN_PPDN = Inp_FIL_GN_PPDN;
  inputs.FIL_GN_PSLN = Inp_FIL_GN_PSLN;
  inputs.FIL_GN_PGAP = Inp_FIL_GN_PGAP;
  inputs.FIL_GN_SPRD = Inp_FIL_GN_SPRD;
  
  inputs.FIL_NS_ENBL = Inp_FIL_NS_ENBL;
  inputs.FIL_NS_FRMN = Inp_FIL_NS_FRMN;
  inputs.FIL_NS_TOMN = Inp_FIL_NS_TOMN;
  inputs.FIL_NS_IMPT = Inp_FIL_NS_IMPT;
  
  inputs.FIL_TM_STRT.Init(Inp_FIL_TM_STRT);
  inputs.FIL_TM_FNSH.Init(Inp_FIL_TM_FNSH);
  inputs.FIL_TM_CLEN = Inp_FIL_TM_CLEN;
  inputs.FIL_TM_CLTM.Init(Inp_FIL_TM_CLTM);
  
  inputs.ENT_TM_HRS = Inp_ENT_TM_HRS;
  inputs.ENT_GN_MGPR = Inp_ENT_GN_MGPR;
  
  inputs.UI_COL_DN = Inp_UI_COL_DN;
  inputs.UI_COL_FL = Inp_UI_COL_FL;
  inputs.UI_COL_UP = Inp_UI_COL_UP;
  inputs.UI_IFR_EN = Inp_UI_IFR_EN;
  inputs.UI_ISB_EN = Inp_UI_ISB_EN;
  
  CSignalParam* sig_param = NULL;
  
  bot.CommentEnable      = Inp_MS_COM_EN;
  bot.CommentIntervalSec = Inp_MS_COM_IS;
  
  bot.Init(Symbol(), Period(), Inp_MS_MGC, trade, Inp_MS_COM_CW, inputs, GetPointer(logger));

  bot.AddSignalParam(+1, BUY,  Inp_FIL_UL_ENBL, Inp_FIL_UL_WICK, Inp_FIL_UL_FRCN, Inp_FIL_UL_FRCX, Inp_FIL_UL_FRPF);
  bot.AddSignalParam(+1, SELL, Inp_FIL_US_ENBL, Inp_FIL_US_WICK, Inp_FIL_US_FRCN, Inp_FIL_US_FRCX, Inp_FIL_US_FRPF);
  
  bot.AddSignalParam(-1, BUY,  Inp_FIL_DL_ENBL, Inp_FIL_DL_WICK, Inp_FIL_DL_FRCN, Inp_FIL_DL_FRCX, Inp_FIL_DL_FRPF);
  bot.AddSignalParam(-1, SELL, Inp_FIL_DS_ENBL, Inp_FIL_DS_WICK, Inp_FIL_DS_FRCN, Inp_FIL_DS_FRCX, Inp_FIL_DS_FRPF);
  
  bot.AddSignalParam(0, BUY,   Inp_FIL_FL_ENBL, Inp_FIL_FL_WICK, Inp_FIL_FL_FRCN, Inp_FIL_FL_FRCX, Inp_FIL_FL_FRPF);
  bot.AddSignalParam(0, SELL,  Inp_FIL_FS_ENBL, Inp_FIL_FS_WICK, Inp_FIL_FS_FRCN, Inp_FIL_FS_FRCX, Inp_FIL_FS_FRPF);
  
  bot.AddEntryParam(-1, Inp_ENT_AT_LOT, Inp_ENT_AT_SLD, Inp_ENT_AT_TPD);
  bot.AddEntryParam(0,  Inp_ENT_FL_LOT, Inp_ENT_FL_SLD, Inp_ENT_FL_TPD);
  bot.AddEntryParam(+1, Inp_ENT_OT_LOT, Inp_ENT_OT_SLD, Inp_ENT_OT_TPD);
  
  bot.AddEntryParam(25, Inp_ENT_TM_LOT, Inp_ENT_TM_SLD, Inp_ENT_TM_TPD); // 25 - idx to get params of entry after 17:00
  
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(true);

  if (!bot.Check()) 
    return(INIT_PARAMETERS_INCORRECT);

  //EventSetTimer(Inp_MS_COM_IS);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
  EventKillTimer();
  bot.OnDeinit(reason);
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()  {
  bot.OnTimer();
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  bot.OnTrade();
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
  bot.OnTradeTransaction(trans, request, result);
}

double OnTester() {
  return bot.OnTester();
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
  bot.OnChartEvent(id, lparam, dparam, sparam);                                    
}