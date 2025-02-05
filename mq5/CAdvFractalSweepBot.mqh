//+------------------------------------------------------------------+
//|                                          CAdvFractalSweepBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

//#include <Generic\HashMap.mqh>
#include <Arrays\ArrayString.mqh>
//#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
#include <Trade\DealInfo.mqh>
//#include <Charts\Chart.mqh>
//#include <Math\Stat\Math.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

//#include "Include\DKStdLib\Common\DKStdLib.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLBE.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"


#include "Include\DKStdLib\Common\CDKString.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Common\CDKBarTag.mqh"
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\History\DKHistory.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "Include\fxsaber\Calendar\Calendar.mqh"
#include "Include\fxsaber\Calendar\DST.mqh"

#include "CAdvFractalSweepBotInputs.mqh"


class CAdvFractalSweepBot : public CDKBaseBot<CAdvFractalSweepBotInputs> {
public: 

protected:
  CArrayObj                  FracUList;
  CArrayObj                  FracDList;
  
  int                        Trend;
  
  CHashMap<int, CSignalParam*> SignalParam; 
  CHashMap<int, CEntryParam*>  EntryParam; 
  
  CALENDAR                   Calendar;
  datetime                   CalendarNextUpdateDT;
public:
  // Constructor & init
  void                       CAdvFractalSweepBot::CAdvFractalSweepBot(void);
  void                       CAdvFractalSweepBot::~CAdvFractalSweepBot(void);
  void                       CAdvFractalSweepBot::InitChild();
  bool                       CAdvFractalSweepBot::Check(void);

  // Event Handlers
  void                       CAdvFractalSweepBot::OnDeinit(const int reason);
  void                       CAdvFractalSweepBot::OnTick(void);
  void                       CAdvFractalSweepBot::OnTrade(void);
  void                       CAdvFractalSweepBot::OnTimer(void);
  double                     CAdvFractalSweepBot::OnTester(void);
  void                       CAdvFractalSweepBot::OnBar(void);
  
  void                       CAdvFractalSweepBot::OnOrderPlaced(ulong _order);
  void                       CAdvFractalSweepBot::OnOrderModified(ulong _order);
  void                       CAdvFractalSweepBot::OnOrderDeleted(ulong _order);
  void                       CAdvFractalSweepBot::OnOrderExpired(ulong _order);
  void                       CAdvFractalSweepBot::OnOrderTriggered(ulong _order);

  void                       CAdvFractalSweepBot::OnPositionOpened(ulong _position, ulong _deal);
  void                       CAdvFractalSweepBot::OnPositionStopLoss(ulong _position, ulong _deal);
  void                       CAdvFractalSweepBot::OnPositionTakeProfit(ulong _position, ulong _deal);
  void                       CAdvFractalSweepBot::OnPositionClosed(ulong _position, ulong _deal);
  void                       CAdvFractalSweepBot::OnPositionCloseBy(ulong _position, ulong _deal);
  void                       CAdvFractalSweepBot::OnPositionModified(ulong _position);  

  void                       CAdvFractalSweepBot::UpdateComment(const bool _ignore_interval = false);
  
  
  
  // Bot's logic
  int                        CAdvFractalSweepBot::AddSignalParam(int _trend, ENUM_DK_POS_TYPE _dir, bool _enabled, uint _wick, uint _frcn, uint _frcx, uint _frp);
  int                        CAdvFractalSweepBot::AddEntryParam(int _trend, double _lot, uint _sl, uint _tp);
  
  int                        CAdvFractalSweepBot::AddFractalToList(ENUM_SERIESMODE _mode, double& _buf[], CArrayObj& _list);
  int                        CAdvFractalSweepBot::FindFractalLevels();
  
  void                       CAdvFractalSweepBot::DrawLevel(CDKBarTag* _tag, const ENUM_DK_POS_TYPE _dir);
  void                       CAdvFractalSweepBot::DrawAllFractalLevels();
  void                       CAdvFractalSweepBot::DrawPos(CDKBarTag* _tag, ENUM_DK_POS_TYPE _dir, ulong _ticket, double _ep, double _sl, double _tp);
  
  bool                       CAdvFractalSweepBot::CheckGlobalSignal(MqlRates& _bar);
  bool                       CAdvFractalSweepBot::CheckSignalForFractal(CDKBarTag* _tag_curr, CDKBarTag* _tag_prev, const ENUM_DK_POS_TYPE _dir, MqlRates& _bar);
  bool                       CAdvFractalSweepBot::OpenPosOnSignal();
  
  int                        CAdvFractalSweepBot::UpdateTrend();
  
  ulong                      CAdvFractalSweepBot::OpenPos(CDKBarTag* _tag_curr, const ENUM_DK_POS_TYPE _dir);
  
  bool                       CAdvFractalSweepBot::LoadNews();
  
  int                        CAdvFractalSweepBot::CountClosedPositionsTodayByMagic(int& _sl_closed_count);
  
  string                     CAdvFractalSweepBot::GetGlobalVarNameToCheckEARunningOtherSym();
};

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::CAdvFractalSweepBot(void) {
  Trend = 0;
}

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::~CAdvFractalSweepBot(void){
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::InitChild() {
  // No news filter in tester, because of MQLCal is not availiable in tester
  if(MQLInfoInteger(MQL_TESTER))
    Inputs.FIL_NS_ENBL = false;
    
  Inputs.IndStrucBlockHndl = iCustom(Sym.Name(), Inputs.SET_TTF, "Market\\Structure Blocks");
  if(Inputs.UI_ISB_EN)
    ChartIndicatorAdd(0, 0, Inputs.IndStrucBlockHndl);  
  
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_PADD) {
    Inputs.IndFractalUHndl = iCustom(Sym.Name(), TF, "PADD-Fractal-Ind", 
                                     "",     // input  group              "1. ОСНОВНЫЕ (B)"
                                     0,      // input  ENUM_FRACTAL_TYPE  InpFractalType                    = FRACTAL_TYPE_UP;                  // B.FT: Тип фрактала
                                     234,    // sinput uint               InpArrowCode                      = 234;                              // B.ACD: Код символа стрелки
                                     clrRed, //sinput color              InpArrowColor                     = clrRed;                           // B.ACL: Цвет стрелки
                                     
                                     "",     //input  group              "2. ФИЛЬТРЫ (F)"
                                     Inputs.SET_FPD_BC,      //input  uint               InpLeftBarCount                   = 3;                                // F.LBC: Свечей слева, шт
                                     Inputs.SET_FPD_PS,   //input  bool               InpLeftHighSorted                 = true;                             // F.LHS: HIGH свечей слева упорядочены
                                     Inputs.SET_FPD_BS,  //input  bool               InpLeftLowSorted                  = true;                             // F.LLS: LOW свечей слева упорядочены
                                     Inputs.SET_FPD_BC,      // input  uint               InpRightBarCount                  = 3;                                // F.RBC: Свечей справа, шт
                                     Inputs.SET_FPD_PS,   //input  bool               InpRightHighSorted                = true;                             // F.RHS: HIGH свечей справа упорядочены
                                     Inputs.SET_FPD_BS); //input  bool               InpRightLowSorted                 = true;                             // F.RLS: LOW свечей справа упорядочены
    Inputs.IndFractalDHndl = iCustom(Sym.Name(), TF, "PADD-Fractal-Ind", 
                                     "",     // input  group              "1. ОСНОВНЫЕ (B)"
                                     1,      // input  ENUM_FRACTAL_TYPE  InpFractalType                    = FRACTAL_TYPE_UP;                  // B.FT: Тип фрактала
                                     233,    // sinput uint               InpArrowCode                      = 234;                              // B.ACD: Код символа стрелки
                                     clrGreen, //sinput color              InpArrowColor                     = clrRed;                           // B.ACL: Цвет стрелки
                                     
                                     "",     //input  group              "2. ФИЛЬТРЫ (F)"
                                     Inputs.SET_FPD_BC,      //input  uint               InpLeftBarCount                   = 3;                                // F.LBC: Свечей слева, шт
                                     Inputs.SET_FPD_BS,   //input  bool               InpLeftHighSorted                 = true;                             // F.LHS: HIGH свечей слева упорядочены
                                     Inputs.SET_FPD_PS,  //input  bool               InpLeftLowSorted                  = true;                             // F.LLS: LOW свечей слева упорядочены
                                     Inputs.SET_FPD_BC,      // input  uint               InpRightBarCount                  = 3;                                // F.RBC: Свечей справа, шт
                                     Inputs.SET_FPD_BS,   //input  bool               InpRightHighSorted                = true;                             // F.RHS: HIGH свечей справа упорядочены
                                     Inputs.SET_FPD_PS); //input  bool               InpRightLowSorted                 = true;                             // F.RLS: LOW свечей справа упорядочены    
    if(Inputs.UI_IFR_EN) {
      ChartIndicatorAdd(0, 0, Inputs.IndFractalUHndl);
      ChartIndicatorAdd(0, 0, Inputs.IndFractalDHndl);
    }
  }
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_WILLIAMS) {
    Inputs.IndFractalWilliams = iFractals(Sym.Name(), TF);      
    if(Inputs.UI_IFR_EN) 
      ChartIndicatorAdd(0, 0, Inputs.IndFractalWilliams);
  }
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_CUSTOM35) {
    Inputs.IndFractalCustom35 = iCustom(Sym.Name(), Inputs.SET_TTF, "MT5 Fractal Indicator", 
                                        Inputs.SET_FCS_NP,
                                        Inputs.SET_FCS_35);
    if(Inputs.UI_IFR_EN)                                        
      ChartIndicatorAdd(0, 0, Inputs.IndFractalCustom35);      
  }


  NewBarDetector.OptimizedCheckEnabled = false;
  NewBarDetector.ResetAllLastBarTime();
  
//  // Window pos
//  string var_name = StringFormat("%s_WND_LEFT", Logger.Name);
//  int left = (GlobalVariableCheck(var_name)) ? (int)GlobalVariableGet(var_name) : 80;
//  
//  var_name = StringFormat("%s_WND_TOP", Logger.Name);
//  int top = (GlobalVariableCheck(var_name)) ? (int)GlobalVariableGet(var_name) : 80;
//    
//  CommentWnd.Move(left, top);
  
  LoadNews();
  OnBar();
  
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CAdvFractalSweepBot::Check(void) {
  if(!CDKBaseBot<CAdvFractalSweepBotInputs>::Check())
    return false;

  bool res = true;

  // I01. IndStrucBlockHndl
  if(Inputs.IndStrucBlockHndl < 0) {
    Logger.Critical("Ошибка инициализации индикатора 'Structure Block'", true);
    res = false;
  }  
  
  // I02. IndFractalUHndl || IndFractalDHndl
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_PADD && (Inputs.IndFractalUHndl < 0 || Inputs.IndFractalDHndl < 0)) {
    Logger.Critical("Ошибка инициализации индикатора 'PADD-Fractal-Ind'", true);
    res = false;
  }    

  // I03. IndFractalWilliams
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_WILLIAMS && Inputs.IndFractalWilliams < 0) {
    Logger.Critical("Ошибка инициализации индикатора 'iFractal'", true);
    res = false;
  }      
  
  // I04. IndFractalCustom35
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_CUSTOM35 && Inputs.IndFractalCustom35 < 0) {
    Logger.Critical("Ошибка инициализации индикатора 'MT5 Fractal Indicator'", true);
    res = false;
  }     
  
  // Check EA running on other chart
  if(GlobalVariableCheck(GetGlobalVarNameToCheckEARunningOtherSym())) 
    if(MessageBox(StringFormat("Возможно советник уже запущен на %s на другом графике. Все равно запустить?", Sym.Name()), 
       "Предупреждение", MB_YESNO | MB_ICONWARNING) != IDYES) {
      Logger.Critical(StringFormat("Cоветник уже запущен на %s на другом графике", Sym.Name()), true);
      res = false;     
    }

  if(res) 
    GlobalVariableSet(GetGlobalVarNameToCheckEARunningOtherSym(), TimeCurrent());
  
  return res;
}


//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnDeinit(const int reason) {
  FracUList.Clear();
  FracDList.Clear();
  
  int keys[];
  CSignalParam* vals_sig[];
  SignalParam.CopyTo(keys, vals_sig);
  for(int i=0;i<ArraySize(vals_sig);i++)
    delete vals_sig[i];
  SignalParam.Clear();  
  
  CEntryParam* vals_ent[];
  EntryParam.CopyTo(keys, vals_ent);
  for(int i=0;i<ArraySize(vals_ent);i++)
    delete vals_ent[i];
  EntryParam.Clear();  

  IndicatorRelease(Inputs.IndStrucBlockHndl);
  IndicatorRelease(Inputs.IndFractalUHndl);
  IndicatorRelease(Inputs.IndFractalDHndl);
  
  ObjectsDeleteAll(0, Logger.Name);
  
  GlobalVariableDel(GetGlobalVarNameToCheckEARunningOtherSym());
  
  //GlobalVariableSet(StringFormat("%s_WND_LEFT", Logger.Name), CommentWnd.Left());
  //GlobalVariableSet(StringFormat("%s_WND_TOP", Logger.Name), CommentWnd.Top());
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnTick(void) {
  CDKBaseBot<CAdvFractalSweepBotInputs>::OnTick(); // Check new bar and show comment
  
  // TM_CLEN: Закрыть позиций принудительно в HH:MM
  datetime dt = TimeCurrent();
  datetime dt_cl = Inputs.FIL_TM_CLTM.Time();
  if(Inputs.FIL_TM_CLEN && Poses.Total() > 0 && dt >= dt_cl) 
    for(int i=0;i<Poses.Total();i++) {
      bool res = Trade.PositionClose(Poses.At(i));
      Logger.Assert(res,
                    LSF(StringFormat("Принудительное закрытие позиции: RET_CODE=%d; TICKET=%I64u",
                                     Trade.ResultRetcode(), Poses.At(i))),
                    WARN, ERROR);
    }
    
  // Reload News
  if(Inputs.FIL_NS_ENBL && TimeCurrent() > CalendarNextUpdateDT)
    LoadNews();
    
  // Close pos on news
  if(Inputs.FIL_NS_ENBL && Poses.Total() > 0)
    for(int i=0;i<Calendar.GetAmount();i++) 
      if(dt >= (Calendar[i].time-Inputs.FIL_NS_FRMN*60) && dt <= (Calendar[i].time+Inputs.FIL_NS_TOMN*60)) {
        CDKPositionInfo pos;
        for(int j=0;j<Poses.Total();j++){
          ulong ticket = Poses.At(j);
          if(!pos.SelectByTicket(ticket)) continue;
          
          bool res = Trade.PositionClose(ticket);
          Logger.Assert(res,
                        LSF(StringFormat("Закрытие позиции в новости: RET_CODE=%d; TICKET=%I64u; NEWS_CODE=%s; NEWS_TIME=%s; INT_MIN=[-%d; +%d]",
                                         Trade.ResultRetcode(), ticket,
                                         Calendar[i].Code[], Calendar[i].time, Inputs.FIL_NS_FRMN, Inputs.FIL_NS_TOMN)),
                        WARN, ERROR);
        }      
      }  
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnBar(void) {
  UpdateTrend();

  OpenPosOnSignal();

  FindFractalLevels();
  DrawAllFractalLevels();
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnTrade(void) {
  CDKBaseBot<CAdvFractalSweepBotInputs>::OnTrade(); 
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnTimer(void) {
  CDKBaseBot<CAdvFractalSweepBotInputs>::OnTimer();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CAdvFractalSweepBot::OnTester(void) {
  return 0;
}

void CAdvFractalSweepBot::OnOrderPlaced(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAdvFractalSweepBot::OnOrderModified(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAdvFractalSweepBot::OnOrderDeleted(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAdvFractalSweepBot::OnOrderExpired(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAdvFractalSweepBot::OnOrderTriggered(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAdvFractalSweepBot::OnPositionTakeProfit(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAdvFractalSweepBot::OnPositionClosed(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAdvFractalSweepBot::OnPositionCloseBy(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAdvFractalSweepBot::OnPositionModified(ulong _position){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}  
  
//+------------------------------------------------------------------+
//| OnPositionOpened
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnPositionOpened(ulong _position, ulong _deal) {
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

//+------------------------------------------------------------------+
//| OnStopLoss Handler
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnPositionStopLoss(ulong _position, ulong _deal) {

}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();
  
  color clr = Inputs.UI_COL_FL;
  string text = "ФЛЭТ";
  if(Trend > 0) {
    clr = Inputs.UI_COL_UP;
    text = "ВОСХОДЯЩИЙ";
  }
  if(Trend < 0) {
    clr = Inputs.UI_COL_DN;
    text = "НИЗХОДЯЩИЙ";
  }
  
  AddCommentLine(StringFormat("Тренд на %s: %s", TimeframeToString(Inputs.SET_TTF), text), 0, clr);
  
  if(Inputs.FIL_NS_ENBL && Calendar.GetAmount() > 0) 
    for(int i=0;i<Calendar.GetAmount();i++)
      if(TimeCurrent() < (Calendar[i].time + Inputs.FIL_NS_TOMN*60)){
        AddCommentLine("Следующая новость:", 0, clrAliceBlue);
        AddCommentLine("  " + Calendar[i].Name[]);
        AddCommentLine("  " + TimeToString(Calendar[i].time));
        break;
      }
  
  AddCommentLine("");     
  AddCommentLine(StringFormat("Фракталы ВЕРХ (%d):", FracUList.Total()), 0, Inputs.UI_COL_DN);
  CARRAYOBJ_ITER(FracUList, CDKBarTag, 
    AddCommentLine(StringFormat("  %s %s", TimeToString(el.GetTime()), Sym.PriceFormat(el.GetValue())));
  )
  
  AddCommentLine(StringFormat("Фракталы НИЗ (%d):", FracDList.Total()), 0, Inputs.UI_COL_UP);
  CARRAYOBJ_ITER(FracDList, CDKBarTag, 
    AddCommentLine(StringFormat("  %s %s", TimeToString(el.GetTime()), Sym.PriceFormat(el.GetValue())));
  )

  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Add all fractal from _buf to _list          
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::AddFractalToList(ENUM_SERIESMODE _mode, double& _buf[], CArrayObj& _list) {
  int cnt = 0;
  for(int i=0;i<ArraySize(_buf);i++){
    if(_buf[i] <= 0 || _buf[i] >= EMPTY_VALUE) continue;
    
    // Filter out broken levels
    double price = 0.0;
    if(_mode == MODE_HIGH) {
      price = iHigh(Sym.Name(), TF, iHighest(Sym.Name(), TF, _mode, i, 0));
      if(price > _buf[i]) continue;
    }
    else if(_mode == MODE_LOW) {
      price = iLow(Sym.Name(), TF, iLowest(Sym.Name(), TF, _mode, i, 0));
      if(price < _buf[i]) continue;
    }     
    
    CDKBarTag* tag = new CDKBarTag(Sym.Name(), TF, i, _buf[i]);
    _list.Add(tag);
    cnt++;
  }
  
  return cnt;
}

//+------------------------------------------------------------------+
//| Find Fractals
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::FindFractalLevels() {
  FracUList.Clear();
  double buf_u[]; ArraySetAsSeries(buf_u, true);
  int ind_fr_up_hndl = Inputs.IndFractalCustom35;
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_PADD)     ind_fr_up_hndl = Inputs.IndFractalUHndl;
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_WILLIAMS) ind_fr_up_hndl = Inputs.IndFractalWilliams;
  int ind_fr_up_buf_n = (Inputs.SET_FRT == AFS_FRACTAL_TYPE_CUSTOM35) ? 1 : 0;
  if(CopyBuffer(ind_fr_up_hndl, ind_fr_up_buf_n, 0, Inputs.SET_FDP, buf_u) == Inputs.SET_FDP) 
    AddFractalToList(MODE_HIGH, buf_u, FracUList);
  
  FracDList.Clear();
  double buf_d[]; ArraySetAsSeries(buf_d, true);
  int ind_fr_dn_hndl = Inputs.IndFractalCustom35;
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_PADD)     ind_fr_dn_hndl = Inputs.IndFractalUHndl;
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_WILLIAMS) ind_fr_dn_hndl = Inputs.IndFractalWilliams;
  int ind_fr_dn_buf_n = 0;
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_WILLIAMS) 
    ind_fr_dn_buf_n = 1;
  if(CopyBuffer(ind_fr_dn_hndl, ind_fr_dn_buf_n, 0, Inputs.SET_FDP, buf_d) == Inputs.SET_FDP) 
    AddFractalToList(MODE_LOW, buf_d, FracDList);  
  
  return 0;  
}

//+------------------------------------------------------------------+
//| Draw level
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::DrawLevel(CDKBarTag* _tag, const ENUM_DK_POS_TYPE _dir) {
  CChartObjectTrend  line;
  string name = StringFormat("%s_LVL_%s_%s", 
                             Logger.Name,
                             PosTypeDKToString(_dir, true),
                             TimeToString(_tag.GetTime()));
  line.Create(0, name, 0, _tag.GetTime(), _tag.GetValue(), _tag.GetTime()+365*24*60*60, _tag.GetValue());
  line.Style(STYLE_DASHDOT);
  line.Color((_dir == BUY) ? clrGreen : clrRed);
  line.Detach();
}

//+------------------------------------------------------------------+
//| Draw all levels
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::DrawAllFractalLevels() {
  ObjectsDeleteAll(0, StringFormat("%s_LVL", Logger.Name));
  CARRAYOBJ_ITER(FracUList, CDKBarTag, DrawLevel(el, SELL););
  CARRAYOBJ_ITER(FracDList, CDKBarTag, DrawLevel(el, BUY););  
}

//+------------------------------------------------------------------+
//| Draw pos
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::DrawPos(CDKBarTag* _tag, ENUM_DK_POS_TYPE _dir, ulong _ticket, double _ep, double _sl, double _tp) {
  // Draw Fractal Line
  CChartObjectTrend line;
  string name_line = StringFormat("%s_POS_LVL_%s_%s", 
                             Logger.Name,
                             PosTypeDKToString(_dir, true),
                             TimeToString(_tag.GetTime()));
  line.Create(0, name_line, 0, _tag.GetTime(), _tag.GetValue(), TimeCurrent(), _tag.GetValue());
  line.Style(STYLE_DOT);
  line.Color((_dir == BUY) ? clrGreen : clrRed);
  line.Detach();
  
  // Draw SL
  string name_sl = StringFormat("%s_POS_SL_%I64u", Logger.Name, _ticket);
  CChartObjectText label_sl;
  label_sl.Create(0, name_sl, 0, TimeCurrent(), _sl);
  label_sl.Description("——");
  label_sl.Anchor(ANCHOR_CENTER);
  label_sl.Color(clrRed);
  label_sl.Detach();  
  
  // Draw TP
  string name_tp = StringFormat("%s_POS_TP_%I64u", Logger.Name, _ticket);
  CChartObjectText label_tp;
  label_tp.Create(0, name_tp, 0, TimeCurrent(), _tp);
  label_tp.Description("——");
  label_tp.Anchor(ANCHOR_CENTER);
  label_tp.Color(clrGreen);
  label_tp.Detach();  

}

//+------------------------------------------------------------------+
//| Check global signal
//+------------------------------------------------------------------+
bool CAdvFractalSweepBot::CheckGlobalSignal(MqlRates& _bar) {
  // 01. TM_STRT: Время начала открытия позиций (формат HH:MM)
  // 01. TM_FNSH: Время окончания открытия позиций (формат HH:MM)
  datetime dt = TimeCurrent(); 
  datetime dt_from = Inputs.FIL_TM_STRT.Time();
  datetime dt_to   = Inputs.FIL_TM_FNSH.Time();
  if(dt < dt_from || dt > dt_to) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Время торговли вне разрешенного интервала: ALLOWED_TIME=[%s; %s]", 
                                    TimeToString(dt_from), TimeToString(dt_to))));  
    return false;
  }  
  
  // 02. GN_SLD: Max спред, пункт
  int spread = Sym.Spread();
  if(Inputs.FIL_GN_SPRD > 0 && spread > (int)Inputs.FIL_GN_SPRD) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышен спред: SPREAD=%d > %d", 
                                    spread, Inputs.FIL_GN_SPRD)));  
    return false;
  }
  
  // 03. GN_PGAP: Max ценовой гэп, пункт (0-откл)
  if(Inputs.FIL_GN_PGAP > 0) {
    double open[];
    if(CopyOpen(Sym.Name(), TF, 0, 1, open) < 0)
      return false;
      
    double gap = MathAbs(_bar.close-open[0]);
    if(gap > Sym.PointsToPrice(Inputs.FIL_GN_PGAP)) {
      if(DEBUG >= Logger.Level)
        Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышен ценовой гэп: GAP=%s > %s", 
                                      Sym.PriceFormat(gap), Sym.PriceFormat(Sym.PointsToPrice(Inputs.FIL_GN_PGAP)))));  
      return false;
    }
  }  
  
  // 04. NS_ENBL: Включить фильтр новостей (не работает в тестере)
  if(Inputs.FIL_NS_ENBL) 
    for(int i=0;i<Calendar.GetAmount();i++) 
      if(dt >= (Calendar[i].time-Inputs.FIL_NS_FRMN*60) && dt <= (Calendar[i].time+Inputs.FIL_NS_TOMN*60)){
        if(DEBUG >= Logger.Level)
          Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Выход новости: NEWS_CODE=%s; NEWS_TIME=%s; INT_MIN=[-%d; +%d]", 
                                        Calendar[i].Code[], Calendar[i].time, Inputs.FIL_NS_FRMN, Inputs.FIL_NS_TOMN)));  
        return false;
      }
      
  // 05. GN_POSN: Max кол-во позиций в рынке, шт (0-откл)
  if(Inputs.FIL_GN_POPN > 0 && Poses.Total() >= (int)Inputs.FIL_GN_POPN) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышено максимальное количество позиций в рынке: POS_CNT=%d", 
                                    Poses.Total())));  
    return false;
  }        
      
  // 06. GN_PPDN: Max кол-во позиций в день, шт (0-откл)
  // 06. GN_PSLN: Max кол-во SL позиций в день, шт (0-откл)
  if(Inputs.FIL_GN_PPDN > 0 || Inputs.FIL_GN_PSLN > 0) {
    int sl_cnt = 0;
    int pos_cnt = CountClosedPositionsTodayByMagic(sl_cnt);
    if(Inputs.FIL_GN_PPDN > 0 && pos_cnt >= (int)Inputs.FIL_GN_PPDN) {
      if(DEBUG >= Logger.Level)
        Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышено максимальное количество закрытых позиций в день: TODAY_POS_CLOSED=%d",
                                      pos_cnt)));
      return false;
    }
    
    if(Inputs.FIL_GN_PSLN > 0 && sl_cnt >= (int)Inputs.FIL_GN_PSLN) {
      if(DEBUG >= Logger.Level)
        Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышено максимальное количество SL позиций в день: TODAY_SL_CLOSED=%d",
                                      sl_cnt)));
      return false;
    }
  }
  
  return true;
}

//+------------------------------------------------------------------+
//| Check Signal
//+------------------------------------------------------------------+
bool CAdvFractalSweepBot::CheckSignalForFractal(CDKBarTag* _tag_curr, CDKBarTag* _tag_prev, const ENUM_DK_POS_TYPE _dir, MqlRates& _bar) {
  int sig_type_id = CAdvFractalSweepBotInputs::GetSignalTypeID(Trend, _dir);
  string sig_type_name = CAdvFractalSweepBotInputs::GetSignalTypeName(Trend, _dir);
  
  CSignalParam* sig_param;
  if(!SignalParam.TryGetValue(sig_type_id, sig_param))
    return false;

  // 01. Trading Enabled for Signal
  if(!sig_param.ENBL) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Торговля отключена для '%s_ENBL': FR_CURR=%s", sig_type_name, _tag_curr.__repr__(true))));
    return false;
  }
  
  // 02. Price hits Fractal 
  if((_dir == BUY  && _bar.low  > _tag_curr.GetValue()) ||
     (_dir == SELL && _bar.high < _tag_curr.GetValue())) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Уровень фрактала не пробит: SIG_TYPE=%s; FR_CURR=%s", sig_type_name, _tag_curr.__repr__(true))));  
    return false;    
  }
  
  // 02.1. Check Williams Fractal has disapeared 
  if(Inputs.SET_FRT == AFS_FRACTAL_TYPE_WILLIAMS) {
    int fractal_buf_num = (_dir == BUY) ? 1 : 0;
    double buf[];
    if(CopyBuffer(Inputs.IndFractalWilliams, fractal_buf_num, _tag_curr.GetIndex(true), 1, buf) < 0) {
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: CopyBuffer(iFractal) < 0: SIG_TYPE=%s; FR_CURR=%s", sig_type_name, _tag_curr.__repr__(true))));
      return false;
    }
    
    if(buf[0] <= 0 || buf[0] >= DBL_MAX){
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Фрактал Вильямса исчез: SIG_TYPE=%s; FR_CURR=%s", sig_type_name, _tag_curr.__repr__(true))));
      return false;
    }
  }  
  
  // 03. Fractal is swept only by wick and not by body
  if((_dir == BUY  && !(_tag_curr.GetValue() >= _bar.low && _tag_curr.GetValue() < _bar.close)) ||
     (_dir == SELL && !(_tag_curr.GetValue() >= _bar.close && _tag_curr.GetValue() < _bar.high))) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Уровень фрактала пробит телом '%s_WCSW': FR_CURR=%s", sig_type_name, _tag_curr.__repr__(true))));  
    return false;
  }
  
  // 04. WICK: ↑+ЛОНГ: Min дистанция свипа, пункт
  if((_dir == BUY  && MathAbs(_tag_curr.GetValue()-_bar.low)  < Sym.PointsToPrice(sig_param.WICK)) ||
     (_dir == SELL && MathAbs(_tag_curr.GetValue()-_bar.high) < Sym.PointsToPrice(sig_param.WICK))) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Дистанция '%s_WICK' от фрактала до H/L меньше минимальной: FR_CURR=%s", 
                                    sig_type_name, _tag_curr.__repr__(true))));  
    return false;
  }

  // 05.1 FRCN: ↑+ЛОНГ: Min дистанция от Фрактала до O или C, пункт
  double dist_to_check = MathMin(MathAbs(_tag_curr.GetValue()-_bar.close), MathAbs(_tag_curr.GetValue()-_bar.open));
  if(dist_to_check < Sym.PointsToPrice(sig_param.FRCN)) { 
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Дистанция от фрактала до O или C меньше минимальной: FR_CURR=%s; %s_FRCN=%f < %f", 
                                    _tag_curr.__repr__(true), sig_type_name,
                                    dist_to_check, Sym.PointsToPrice(sig_param.FRCN))));  
    return false;
  }
   
  // 05.2 FRCX: ↑+ЛОНГ: Max дистанция от Фрактала до Закрытия, пункт
  if(MathAbs(_tag_curr.GetValue()-_bar.close) > Sym.PointsToPrice(sig_param.FRCX)) { 
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Дистанция '%s_FRCX' от фрактала до закрытия больше максимальной: FR_CURR=%s", 
                                    sig_type_name, _tag_curr.__repr__(true))));  
    return false;
  }
  
  // 06. FRPF: ↑+ЛОНГ: Min дистанция от Фрактала до Прошлого, пункт
  if(MathAbs(_tag_curr.GetValue()-_tag_prev.GetValue()) < Sym.PointsToPrice(sig_param.FRPF)) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Дистанция '%s_FRPF' от фрактала до предыдущего больше максимальной: FR_CURR=%s; FR_PREV=%s", 
                                    sig_type_name, _tag_curr.__repr__(true), _tag_prev.__repr__(true))));  
    return false;
  }  
  
  // 05. GN_POSN: Max кол-во позиций в рынке, шт (0-откл)
  if(Inputs.FIL_GN_POPN > 0 && Poses.Total() >= (int)Inputs.FIL_GN_POPN) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышено максимальное количество позиций в рынке: SIG_TYPE=%s; FR_CURR=%s; POS_CNT=%d", 
                                    sig_type_name, _tag_curr.__repr__(true), Poses.Total())));  
    return false;
  }    

  Logger.Info(LSF(StringFormat("Сигнал получен: SIG_TYPE=%s; FR_CURR=%s", sig_type_name, _tag_curr.__repr__(true))));
  return true;
}

//+------------------------------------------------------------------+
//| Find signal for any Fractal and open Pos
//+------------------------------------------------------------------+
bool CAdvFractalSweepBot::OpenPosOnSignal() {
  MqlRates rates[];
  if(CopyRates(Sym.Name(), TF, 1, 1, rates) < 0)
    return false;
    
  MqlRates rate_prev_bar = rates[0];
  
  CDKBarTag* tag_curr;
  CDKBarTag* tag_prev;    

  // Check global sig for all fractals
  if(!CheckGlobalSignal(rate_prev_bar))
    return false;

  // Check global sig for every fractal
  bool res = false;
  for(int i=0;i<FracDList.Total()-1;i++) {
    tag_curr = FracDList.At(i);
    tag_prev = FracDList.At(i+1);
    if(CheckSignalForFractal(tag_curr, tag_prev, BUY, rate_prev_bar)) 
      res = OpenPos(tag_curr, BUY) > 0 || res;
  }
  
  for(int i=0;i<FracUList.Total()-1;i++) {
    tag_curr = FracUList.At(i);
    tag_prev = FracUList.At(i+1);
    if(CheckSignalForFractal(tag_curr, tag_prev, SELL, rate_prev_bar)) 
      res = OpenPos(tag_curr, SELL) > 0 || res;
  }

  return true;
}

//+------------------------------------------------------------------+
//| Add param set for _trend and _dir
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::AddSignalParam(int _trend, ENUM_DK_POS_TYPE _dir, bool _enabled, uint _wick, uint _frcn, uint _frcx, uint _frp) {
  CSignalParam* sig_param;
  CAdvFractalSweepBotInputs::CreateParam(sig_param, _enabled, _wick, _frcn, _frcx, _frp);
  SignalParam.TrySetValue(CAdvFractalSweepBotInputs::GetSignalTypeID(_trend, _dir), sig_param);
  
  return SignalParam.Count();
}

//+------------------------------------------------------------------+
//| Add param set for _trend 
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::AddEntryParam(int _trend, double _lot, uint _sl, uint _tp) {
  CEntryParam* ent_param = new CEntryParam();
  ent_param.Lot = _lot;
  ent_param.SL  = _sl;
  ent_param.TP  = _tp;
  
  EntryParam.TrySetValue(_trend, ent_param);
  
  return EntryParam.Count();
}

//+------------------------------------------------------------------+
//| Update trend using SB
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::UpdateTrend() {
  double trend[];
  double depth[];
  if(CopyBuffer(Inputs.IndStrucBlockHndl, 4, 0, 1, trend) >= 1 && 
     CopyBuffer(Inputs.IndStrucBlockHndl, 5, 0, 1, depth) >= 1) {

    Trend = 0;
    if(depth[0] > 1) 
      Trend = (trend[0] == 0) ? +1 : -1;
  }
    
  return Trend;
}

//+------------------------------------------------------------------+
//| Open Pos
//+------------------------------------------------------------------+
ulong CAdvFractalSweepBot::OpenPos(CDKBarTag* _tag_curr, const ENUM_DK_POS_TYPE _dir) {
  int ent_type = (Trend * ((_dir == BUY) ? +1 : -1) > 0) ? +1 : -1;
  if(Trend == 0) ent_type = 0;
  
  CEntryParam* ent_param;
  
  MqlDateTime dt_mql;
  TimeCurrent(dt_mql);
  // Entry param after 17:00
  if(Inputs.ENT_TM_HRS < 25 && dt_mql.hour >= (int)Inputs.ENT_TM_HRS) {
    if(!EntryParam.TryGetValue(25, ent_param))
      return false;
  }
  // Entry param on or against trend
  else if(!EntryParam.TryGetValue(ent_type, ent_param))
    return false;

  CAccountInfo acc;
  string sig_type_name = CAdvFractalSweepBotInputs::GetSignalTypeName(Trend, _dir);
  ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)_dir;
  double ep  = Sym.GetPriceToOpen(pt);
  double sl  = Sym.AddToPrice(pt, ep, -1*Sym.PointsToPrice(ent_param.SL));
  double tp  = Sym.AddToPrice(pt, ep, Sym.PointsToPrice(ent_param.TP));
  double lot = ent_param.Lot;
  
  // Adjust lot to max free margin %
  if(Inputs.ENT_GN_MGPR > 0) {
    double balance = acc.Balance();
    double margin_free = acc.FreeMargin();
    double margin_allowed = balance*Inputs.ENT_GN_MGPR/100;
    
    // #todo Заменить подбор лота под маржу циклом на формулу
    double fmc = acc.FreeMarginCheck(Sym.Name(), (_dir == BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, lot, ep);
    while(fmc < margin_allowed && lot > 0.0) {
      lot -= Sym.LotsStep();    
      fmc = acc.FreeMarginCheck(Sym.Name(), (_dir == BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, lot, ep);
    }
      
    if(lot < ent_param.Lot)
      Logger.Info(LSF(StringFormat("Адаптирован лот под максимум %0.1f%% маржи: LOT=%f -> %f: MARGIN_AFTER=%0.2f", 
                                   Inputs.ENT_GN_MGPR, ent_param.Lot, lot, fmc)));  
  }
  
  string comment = StringFormat("%s:%s", Logger.Name, TimeToString(_tag_curr.GetTime()));
  
  ulong res = 0;
  if(_dir == BUY){
    double mlc = acc.MaxLotCheck(Sym.Name(), ORDER_TYPE_BUY, ep, 50);
    res = Trade.Buy(lot, Sym.Name(), ep, sl, tp, comment);
  }
  if(_dir == SELL) {
    double mlc = acc.MaxLotCheck(Sym.Name(), ORDER_TYPE_SELL, ep, 50);
    res = Trade.Sell(lot, Sym.Name(), ep, sl, tp, comment);
  }
  
  if(res > 0) {
    DrawPos(_tag_curr, _dir, res, ep, sl, tp);
    LoadMarket();
  }
  
  Logger.Assert(res > 0,
                LSF(StringFormat("Позиция открыта: RET_CODE=%d; SIG_TYPE=%s; FR=%s", 
                                 Trade.ResultRetcode(),
                                 sig_type_name, _tag_curr.__repr__(false))),
                WARN, ERROR);
  
  return res;
}

//+------------------------------------------------------------------+
//| Count today pos closed and SL
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::CountClosedPositionsTodayByMagic(int& _sl_closed_count) {
  int total_closed_count = 0; // Счётчик всех закрытых позиций
  _sl_closed_count = 0;       // Счётчик закрытых по SL
  
  datetime today_start = iTime(Sym.Name(), PERIOD_D1, 0); // Начало текущего дня
  HistorySelect(today_start, TimeCurrent()); // Загружаем историю сделок за сегодня
  
  // Перебираем все закрытые сделки
  for (int i = HistoryDealsTotal() - 1; i >= 0; i--) {
    ulong deal_ticket = HistoryDealGetTicket(i);
    if (deal_ticket == 0) continue;
  
    // Проверяем атрибуты сделки
    if (HistoryDealGetInteger(deal_ticket, DEAL_MAGIC) == Magic &&
        HistoryDealGetString(deal_ticket, DEAL_SYMBOL) == Sym.Name() &&
        HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT) {
       total_closed_count++; // Считаем все закрытые позиции
  
       // Проверяем, закрылась ли позиция по SL
       double close_price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
       double sl_price = HistoryDealGetDouble(deal_ticket, DEAL_SL);
       long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
       // Логика проверки закрытия по SL
       if ((deal_type == DEAL_TYPE_BUY && close_price >= sl_price) || 
          (deal_type == DEAL_TYPE_SELL && close_price <= sl_price)) 
        _sl_closed_count++;
    }
  }
  
  return total_closed_count;
}

//+------------------------------------------------------------------+
//| Load News
//+------------------------------------------------------------------+
bool CAdvFractalSweepBot::LoadNews() { 
  if(!Inputs.FIL_NS_ENBL) return false;
  
  // 01. Calendar init
  ulong tick_start = GetTickCount64();
  datetime dt_from = TimeCurrent();
  datetime dt_to = TimeCurrent() + 30*24*60*60;
  Calendar.Set(NULL, Inputs.FIL_NS_IMPT, dt_from, dt_to); 
  if(DEBUG >= Logger.Level)
    Logger.Debug(LSF(StringFormat("Загружены новости: EVENT_CNT=%d; TIME=%dms", 
                                  Calendar.GetAmount(),
                                  GetTickCount64()-tick_start)));
  
 
  Calendar.FilterBySymbol(Sym.Name());
  //if(Inputs.CAL_FLT_IMP_Filter_Importance != CALENDAR_IMPORTANCE_NONE)
  //  Calendar.FilterByImportance(Inputs.CAL_FLT_IMP_Filter_Importance);
  
  // DTS Events  
  Calendar.AutoDSTDK();

  CalendarNextUpdateDT = TimeEnd(TimeCurrent(), DATETIME_PART_DAY);
  
  Logger.Info(LSF(StringFormat("Отфильтрованы новости символа: EVENT_CNT=%d; TIME=%dms", 
                                Calendar.GetAmount(),
                                GetTickCount64()-tick_start)));
  
  return Calendar.GetAmount() > 0;
}

//+------------------------------------------------------------------+
//|  Return unique global var name to check EA running other Sym
//+------------------------------------------------------------------+
string CAdvFractalSweepBot::GetGlobalVarNameToCheckEARunningOtherSym() {
  return "EA_AFS_RUNNING_" + Sym.Name();
}