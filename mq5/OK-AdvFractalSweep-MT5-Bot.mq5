//+------------------------------------------------------------------+
//|                                   OK-AdvFractalSweep-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"


#include "CAdvFractalSweepBot.mqh"


input  group                    "1. FRACTALS (FRA)"
input  uint                     Inp_FRA_DPT                                             = 24*60;                             // DPT: Глубина поиска фракталов, баров

input  bool                     Inp_FRA_UL_ENBL                                         = true;                              // UL_ENBL: ↑+ЛОНГ: Тогровля включена
input  uint                     Inp_FRA_UL_WICK                                         = 3;                                 // UL_WICK: ↑+ЛОНГ: Min дистанция свипа, пункт
input  uint                     Inp_FRA_UL_FRCL                                         = 85;                                // UL_FRCL: ↑+ЛОНГ: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FRA_UL_FRPF                                         = 30;                                // UL_FRPF: ↑+ЛОНГ: Min дистанция от Фрактала до Прошлого, пункт

input  bool                     Inp_FRA_US_ENBL                                         = true;                              // US_ENBL: ↑+ЛОНГ: Тогровля включена
input  uint                     Inp_FRA_US_WICK                                         = 3;                                 // US_WICK: ↑+ШОРТ: Min дистанция свипа, пункт
input  uint                     Inp_FRA_US_FRCL                                         = 60;                                // US_FRCL: ↑+ШОРТ: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FRA_US_FRPF                                         = 75;                                // US_FRPF: ↑+ШОРТ: Min дистанция от Фрактала до Прошлого, пункт

input  bool                     Inp_FRA_DL_ENBL                                         = true;                              // DL_ENBL: ↑+ЛОНГ: Тогровля включена
input  uint                     Inp_FRA_DL_WICK                                         = 3;                                 // DL_WICK: ↓+ЛОНГ: Min дистанция свипа, пункт
input  uint                     Inp_FRA_DL_FRCL                                         = 60;                                // DL_FRCL: ↓+ЛОНГ: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FRA_DL_FRPF                                         = 75;                                // DL_FRPF: ↓+ЛОНГ: Min дистанция от Фрактала до Прошлого, пункт

input  bool                     Inp_FRA_DS_ENBL                                         = true;                              // DS_ENBL: ↑+ЛОНГ: Тогровля включена
input  uint                     Inp_FRA_DS_WICK                                         = 3;                                 // DS_WICK: ↓+ШОРТ: Min дистанция свипа, пункт
input  uint                     Inp_FRA_DS_FRCL                                         = 85;                                // DS_FRCL: ↓+ШОРТ: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FRA_DS_FRPF                                         = 30;                                // DS_FRPF: ↓+ШОРТ: Min дистанция от Фрактала до Прошлого, пункт

input  bool                     Inp_FRA_FL_ENBL                                         = true;                              // FL_ENBL: ↑+ЛОНГ: Тогровля включена
input  uint                     Inp_FRA_FL_WICK                                         = 3;                                 // FL_WICK: →+ЛОНГ: Min дистанция свипа, пункт
input  uint                     Inp_FRA_FL_FRCL                                         = 60;                                // FL_FRCL: →+ЛОНГ: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FRA_FL_FRPF                                         = 75;                                // FL_FRPF: →+ЛОНГ: Min дистанция от Фрактала до Прошлого, пункт

input  bool                     Inp_FRA_FS_ENBL                                         = true;                              // FS_ENBL: ↑+ЛОНГ: Тогровля включена
input  uint                     Inp_FRA_FS_WICK                                         = 3;                                 // FS_WICK: →+ШОРТ: Min дистанция свипа, пункт
input  uint                     Inp_FRA_FS_FRCL                                         = 60;                                // FS_FRCL: →+ШОРТ: Max дистанция от Фрактала до Закрытия, пункт
input  uint                     Inp_FRA_FS_FRPF                                         = 75;                                // FS_FRPF: →+ШОРТ: Min дистанция от Фрактала до Прошлого, пункт

input  group                    "2. ОПОВЕЩЕНИЯ (ALR)"
       
input  group                    "3. MISCELLANEOUS (MSC)"
input  ulong                    Inp_MS_MGC                                              = 20241129;                          // MSC_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                                              = "OKAFS";                           // MSC_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                                           = LogLevel(INFO);                    // MSC_LOG_LL: Log Level
       string                   Inp_MS_LOG_FI                                           = "";                                // MSC_LOG_FI: Log Filter IN String (use ';' as sep)
       string                   Inp_MS_LOG_FO                                           = "";                                // MSC_LOG_FO: Log Filter OUT String (use ';' as sep)
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
  
  trade.Init(Symbol(), Inp_MS_MGC, 0, GetPointer(logger));

  CAdvFractalSweepBotInputs inputs;
  inputs.FRA_DPT = Inp_FRA_DPT;
  
  CSignalParam* sig_param = NULL;
  
  bot.CommentEnable      = Inp_MS_COM_EN;
  bot.CommentIntervalSec = Inp_MS_COM_IS;
  
  bot.Init(Symbol(), Period(), Inp_MS_MGC, trade, Inp_MS_COM_CW, inputs, GetPointer(logger));

  bot.AddParam(+1, BUY,  Inp_FRA_UL_ENBL, Inp_FRA_UL_WICK, Inp_FRA_UL_FRCL, Inp_FRA_UL_FRPF);
  bot.AddParam(+1, SELL, Inp_FRA_US_ENBL, Inp_FRA_US_WICK, Inp_FRA_US_FRCL, Inp_FRA_US_FRPF);
  
  bot.AddParam(-1, BUY,  Inp_FRA_DL_ENBL, Inp_FRA_DL_WICK, Inp_FRA_DL_FRCL, Inp_FRA_DL_FRPF);
  bot.AddParam(-1, SELL, Inp_FRA_DS_ENBL, Inp_FRA_DS_WICK, Inp_FRA_DS_FRCL, Inp_FRA_DS_FRPF);
  
  bot.AddParam(0, BUY,   Inp_FRA_FL_ENBL, Inp_FRA_FL_WICK, Inp_FRA_FL_FRCL, Inp_FRA_FL_FRPF);
  bot.AddParam(0, SELL,  Inp_FRA_FS_ENBL, Inp_FRA_FS_WICK, Inp_FRA_FS_FRCL, Inp_FRA_FS_FRPF);
  
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