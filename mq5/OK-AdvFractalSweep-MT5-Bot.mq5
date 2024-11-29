//+------------------------------------------------------------------+
//|                                   OK-AdvFractalSweep-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"


#include "CAdvFractalSweepBot.mqh"


input  group                    "1. ФРАКТАЛЫ (FRA)"
input  uint                     Inp_FRA_DPT                                             = 24*60;                             // DPT: Глубина поиска фракталов, баров

input  group                    "1.1. ОБЩИЕ ФИЛЬТРЫ (FIL)"
input  uint                     Inp_FIL_GN_POSN                                         = 1;                                 // GN_POSN: Max кол-во позиций в рынке, шт (0-откл)
input  uint                     Inp_FIL_GN_PGAP                                         = 5;                                 // GN_PGAP: Max ценовой гэп, пункт (0-откл)
input  string                   Inp_FIL_TM_STRT                                         = "09:00";                           // TM_STRT: Время начала открытия позиций (формат HH:MM)
input  string                   Inp_FIL_TM_FNSH                                         = "19:00";                           // TM_FNSH: Время окончания открытия позиций (формат HH:MM)
input  bool                     Inp_FIL_TM_CLEN                                         = true;                              // TM_CLEN: Закрыть позиций принудительно в HH:MM
input  string                   Inp_FIL_TM_CLTM                                         = "22:00";                           // TM_CLTM: Время принудительного закрытия позиций (формат HH:MM)

input  group                    "1.2. ФИЛЬТРЫ ВОСХ+ЛОНГ ↑+↑ (FIL)"
input  bool                     Inp_FIL_UL_ENBL                                         = true;                              // UL_ENBL: ↑+↑: Тогровля включена
input  uint                     Inp_FIL_UL_WICK                                         = 3;                                 // UL_WICK: ↑+↑: Min дистанция свипа, пункт
input  uint                     Inp_FIL_UL_FRCL                                         = 85;                                // UL_FRCL: ↑+↑: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_UL_FRPF                                         = 30;                                // UL_FRPF: ↑+↑: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "1.3. ФИЛЬТРЫ ВОСХ+ШОРТ ↑+↓ (FIL)"
input  bool                     Inp_FIL_US_ENBL                                         = true;                              // US_ENBL: ↑+↓: Тогровля включена
input  uint                     Inp_FIL_US_WICK                                         = 3;                                 // US_WICK: ↑+↓: Min дистанция свипа, пункт
input  uint                     Inp_FIL_US_FRCL                                         = 60;                                // US_FRCL: ↑+↓: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_US_FRPF                                         = 75;                                // US_FRPF: ↑+↓: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "1.4. ФИЛЬТРЫ НИЗХ+ЛОНГ ↓+↑ (FIL)"
input  bool                     Inp_FIL_DL_ENBL                                         = true;                              // DL_ENBL: ↓+↑: Тогровля включена
input  uint                     Inp_FIL_DL_WICK                                         = 3;                                 // DL_WICK: ↓+↑: Min дистанция свипа, пункт
input  uint                     Inp_FIL_DL_FRCL                                         = 60;                                // DL_FRCL: ↓+↑: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_DL_FRPF                                         = 75;                                // DL_FRPF: ↓+↑: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "1.5. ФИЛЬТРЫ НИЗХ+ШОРТ ↓+↓ (FIL)"
input  bool                     Inp_FIL_DS_ENBL                                         = true;                              // DS_ENBL: ↓+↓: Тогровля включена
input  uint                     Inp_FIL_DS_WICK                                         = 3;                                 // DS_WICK: ↓+↓: Min дистанция свипа, пункт
input  uint                     Inp_FIL_DS_FRCL                                         = 85;                                // DS_FRCL: ↓+↓: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_DS_FRPF                                         = 30;                                // DS_FRPF: ↓+↓: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "1.6. ФИЛЬТРЫ ФЛЭТ+ЛОНГ →+↑ (FIL)"
input  bool                     Inp_FIL_FL_ENBL                                         = true;                              // FL_ENBL: →+↑: Тогровля включена
input  uint                     Inp_FIL_FL_WICK                                         = 3;                                 // FL_WICK: →+↑: Min дистанция свипа, пункт
input  uint                     Inp_FIL_FL_FRCL                                         = 60;                                // FL_FRCL: →+↑: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_FL_FRPF                                         = 75;                                // FL_FRPF: →+↑: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "1.7. ФИЛЬТРЫ ФЛЭТ+ШОРТ →+↓ (FIL)"
input  bool                     Inp_FIL_FS_ENBL                                         = true;                              // FS_ENBL: →+↓: Тогровля включена
input  uint                     Inp_FIL_FS_WICK                                         = 3;                                 // FS_WICK: →+↓: Min дистанция свипа, пункт
input  uint                     Inp_FIL_FS_FRCL                                         = 60;                                // FS_FRCL: →+↓: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FIL_FS_FRPF                                         = 75;                                // FS_FRPF: →+↓: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "2. ВХОД (ENT)"
input  uint                     Inp_ENT_GN_SLPG                                         = 5;                                 // GN_SLD: Max проскальзывание, пункт (0-откл)
input  uint                     Inp_ENT_GN_SPRD                                         = 5;                                 // GN_SLD: Max спред, пункт (0-откл)

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

       
input  group                    "3. MISCELLANEOUS (MSC)"
input  ulong                    Inp_MS_MGC                                              = 20241129;                          // MSC_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                                              = "OKAFS";                           // MSC_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                                           = LogLevel(INFO);                    // MSC_LOG_LL: Log Level
sinput string                   Inp_MS_LOG_FI                                           = "";                                // MSC_LOG_FI: Log Filter IN String (use ';' as sep)
sinput string                   Inp_MS_LOG_FO                                           = "";                                // MSC_LOG_FO: Log Filter OUT String (use ';' as sep)
       bool                     Inp_MS_COM_EN                                           = false;                             // MSC_COM_EN: Comment Enable (turn off for fast testing)
       uint                     Inp_MS_COM_IS                                           = 5;                                 // MSC_COM_IS: Comment Interval, Sec
       bool                     Inp_MS_COM_CW                                           = true;                              // MSC_COM_EW: Comment Custom Window
       
       long                     Inp_PublishDate                                         = 20241129;                           // Date of publish
       int                      Inp_DurationBeforeExpireSec                             = 10*24*60*60;                        // Duration before expire, sec
       

CAdvFractalSweepBot                      bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  logger.Init(Inp_MS_EGP, Inp_MS_LOG_LL);
  logger.FilterInFromStringWithSep(Inp_MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(Inp_MS_LOG_FO, ";");
  
  if (TimeCurrent() > StringToTime((string)Inp_PublishDate) + Inp_DurationBeforeExpireSec) {
    logger.Critical("Test version is expired", true);
    return(INIT_FAILED);
  }  
  
  trade.Init(Symbol(), Inp_MS_MGC, Inp_ENT_GN_SLPG, GetPointer(logger));

  CAdvFractalSweepBotInputs inputs;
  inputs.FRA_DPT = Inp_FRA_DPT;
  
  inputs.FIL_GN_POSN = Inp_FIL_GN_POSN;
  inputs.FIL_GN_PGAP = Inp_FIL_GN_PGAP;
  
  inputs.FIL_TM_STRT.Init(Inp_FIL_TM_STRT);
  inputs.FIL_TM_FNSH.Init(Inp_FIL_TM_FNSH);
  inputs.FIL_TM_CLEN = Inp_FIL_TM_CLEN;
  inputs.FIL_TM_CLTM.Init(Inp_FIL_TM_CLTM);
  
  inputs.ENT_GN_SPRD = Inp_ENT_GN_SPRD;
  inputs.ENT_TM_HRS = Inp_ENT_TM_HRS;
  
  CSignalParam* sig_param = NULL;
  
  bot.CommentEnable      = Inp_MS_COM_EN;
  bot.CommentIntervalSec = Inp_MS_COM_IS;
  
  bot.Init(Symbol(), Period(), Inp_MS_MGC, trade, Inp_MS_COM_CW, inputs, GetPointer(logger));

  bot.AddSignalParam(+1, BUY,  Inp_FIL_UL_ENBL, Inp_FIL_UL_WICK, Inp_FIL_UL_FRCL, Inp_FIL_UL_FRPF);
  bot.AddSignalParam(+1, SELL, Inp_FIL_US_ENBL, Inp_FIL_US_WICK, Inp_FIL_US_FRCL, Inp_FIL_US_FRPF);
  
  bot.AddSignalParam(-1, BUY,  Inp_FIL_DL_ENBL, Inp_FIL_DL_WICK, Inp_FIL_DL_FRCL, Inp_FIL_DL_FRPF);
  bot.AddSignalParam(-1, SELL, Inp_FIL_DS_ENBL, Inp_FIL_DS_WICK, Inp_FIL_DS_FRCL, Inp_FIL_DS_FRPF);
  
  bot.AddSignalParam(0, BUY,   Inp_FIL_FL_ENBL, Inp_FIL_FL_WICK, Inp_FIL_FL_FRCL, Inp_FIL_FL_FRPF);
  bot.AddSignalParam(0, SELL,  Inp_FIL_FS_ENBL, Inp_FIL_FS_WICK, Inp_FIL_FS_FRCL, Inp_FIL_FS_FRPF);
  
  bot.AddEntryParam(-1, Inp_ENT_AT_LOT, Inp_ENT_AT_SLD, Inp_ENT_AT_TPD);
  bot.AddEntryParam(0,  Inp_ENT_FL_LOT, Inp_ENT_FL_SLD, Inp_ENT_FL_TPD);
  bot.AddEntryParam(+1, Inp_ENT_OT_LOT, Inp_ENT_OT_SLD, Inp_ENT_OT_TPD);
  
  bot.AddEntryParam(25, Inp_ENT_TM_LOT, Inp_ENT_TM_SLD, Inp_ENT_TM_TPD); // 25 - idx to get params of entry after 17:00
  
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(false);

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