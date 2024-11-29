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

#include <ChartObjects\ChartObjectsLines.mqh>

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

#include "CAdvFractalSweepBotInputs.mqh"


class CAdvFractalSweepBot : public CDKBaseBot<CAdvFractalSweepBotInputs> {
public: 

protected:
  CArrayObj                  FracUList;
  CArrayObj                  FracDList;
  
  int                        Trend;
  
  CHashMap<int, CSignalParam*> SignalParam; 
  CHashMap<int, CEntryParam*>  EntryParam; 
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
  int                        CAdvFractalSweepBot::AddSignalParam(int _trend, ENUM_DK_POS_TYPE _dir, bool _enabled, uint _wick, uint _frcl, uint _frp);
  int                        CAdvFractalSweepBot::AddEntryParam(int _trend, double _lot, uint _sl, uint _tp);
  
  int                        CAdvFractalSweepBot::AddFractalToList(ENUM_SERIESMODE _mode, double& _buf[], CArrayObj& _list);
  int                        CAdvFractalSweepBot::FindFractalLevels();
  
  void                       CAdvFractalSweepBot::DrawLevel(CDKBarTag* _tag, const ENUM_DK_POS_TYPE _dir);
  void                       CAdvFractalSweepBot::Draw();
  
  bool                       CAdvFractalSweepBot::CheckSignal(CDKBarTag* _tag_curr, CDKBarTag* _tag_prev, const ENUM_DK_POS_TYPE _dir, MqlRates& _bar);
  bool                       CAdvFractalSweepBot::OpenPosOnSignal();
  
  int                        CAdvFractalSweepBot::UpdateTrend();
  
  ulong                      CAdvFractalSweepBot::OpenPos(CDKBarTag* _tag_curr, const ENUM_DK_POS_TYPE _dir);
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
  Inputs.IndStrucBlockHndl = iCustom(Sym.Name(), TF, "Market\\Structure Blocks");
  
  Inputs.IndFractalUHndl = iCustom(Sym.Name(), TF, "PADD-Fractal-Ind", 
                                   "",     // input  group              "1. ОСНОВНЫЕ (B)"
                                   0,      // input  ENUM_FRACTAL_TYPE  InpFractalType                    = FRACTAL_TYPE_UP;                  // B.FT: Тип фрактала
                                   234,    // sinput uint               InpArrowCode                      = 234;                              // B.ACD: Код символа стрелки
                                   clrRed, //sinput color              InpArrowColor                     = clrRed;                           // B.ACL: Цвет стрелки
                                   
                                   "",     //input  group              "2. ФИЛЬТРЫ (F)"
                                   3,      //input  uint               InpLeftBarCount                   = 3;                                // F.LBC: Свечей слева, шт
                                   true,   //input  bool               InpLeftHighSorted                 = true;                             // F.LHS: HIGH свечей слева упорядочены
                                   false,  //input  bool               InpLeftLowSorted                  = true;                             // F.LLS: LOW свечей слева упорядочены
                                   3,      // input  uint               InpRightBarCount                  = 3;                                // F.RBC: Свечей справа, шт
                                   true,   //input  bool               InpRightHighSorted                = true;                             // F.RHS: HIGH свечей справа упорядочены
                                     false); //input  bool               InpRightLowSorted                 = true;                             // F.RLS: LOW свечей справа упорядочены
  Inputs.IndFractalDHndl = iCustom(Sym.Name(), TF, "PADD-Fractal-Ind", 
                                   "",     // input  group              "1. ОСНОВНЫЕ (B)"
                                   1,      // input  ENUM_FRACTAL_TYPE  InpFractalType                    = FRACTAL_TYPE_UP;                  // B.FT: Тип фрактала
                                   233,    // sinput uint               InpArrowCode                      = 234;                              // B.ACD: Код символа стрелки
                                   clrGreen, //sinput color              InpArrowColor                     = clrRed;                           // B.ACL: Цвет стрелки
                                   
                                   "",     //input  group              "2. ФИЛЬТРЫ (F)"
                                   3,      //input  uint               InpLeftBarCount                   = 3;                                // F.LBC: Свечей слева, шт
                                   false,   //input  bool               InpLeftHighSorted                 = true;                             // F.LHS: HIGH свечей слева упорядочены
                                   true,  //input  bool               InpLeftLowSorted                  = true;                             // F.LLS: LOW свечей слева упорядочены
                                   3,      // input  uint               InpRightBarCount                  = 3;                                // F.RBC: Свечей справа, шт
                                   false,   //input  bool               InpRightHighSorted                = true;                             // F.RHS: HIGH свечей справа упорядочены
                                   true); //input  bool               InpRightLowSorted                 = true;                             // F.RLS: LOW свечей справа упорядочены
  
  
  ChartIndicatorAdd(0, 0, Inputs.IndFractalUHndl);
  ChartIndicatorAdd(0, 0, Inputs.IndFractalDHndl);
  
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
  if(Inputs.IndFractalUHndl < 0 || Inputs.IndFractalDHndl < 0) {
    Logger.Critical("Ошибка инициализации индикатора 'PADD-Fractal-Ind'", true);
    res = false;
  }    
  
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
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnBar(void) {
  UpdateTrend();

  OpenPosOnSignal();

  FindFractalLevels();
  Draw();
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
  
  AddCommentLine(StringFormat("Trend: %d", Trend));
  
  CARRAYOBJ_ITER(FracUList, CDKBarTag, 
    AddCommentLine(StringFormat("UP %s %f", TimeToString(el.GetTime()), el.GetValue()));
  )
  
  CARRAYOBJ_ITER(FracDList, CDKBarTag, 
    AddCommentLine(StringFormat("DOWN %s %f", TimeToString(el.GetTime()), el.GetValue()));
  )

  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Add all fractal from _buf to _list          
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::AddFractalToList(ENUM_SERIESMODE _mode, double& _buf[], CArrayObj& _list) {
  int cnt = 0;
  for(int i=0;i<ArraySize(_buf);i++){
    if(_buf[i] <= 0) continue;
    
    // Filter out broken levels
    double price = 0.0;
    if(_mode == MODE_HIGH) {
      price = iHigh(Sym.Name(), TF, iHighest(Sym.Name(), TF, _mode, i, 0));
      if(price >= _buf[i]) continue;
    }
    else if(_mode == MODE_LOW) {
      price = iLow(Sym.Name(), TF, iLowest(Sym.Name(), TF, _mode, i, 0));
      if(price <= _buf[i]) continue;
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
  if(CopyBuffer(Inputs.IndFractalUHndl, 0, 0, Inputs.FRA_DPT, buf_u) == Inputs.FRA_DPT) {
    AddFractalToList(MODE_HIGH, buf_u, FracUList);
  }
  
  FracDList.Clear();
  double buf_d[]; ArraySetAsSeries(buf_d, true);
  if(CopyBuffer(Inputs.IndFractalDHndl, 0, 0, Inputs.FRA_DPT, buf_d) == Inputs.FRA_DPT) {
    AddFractalToList(MODE_LOW, buf_d, FracDList);
  }
  
  return 0;  
}

//+------------------------------------------------------------------+
//| Draw level
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::DrawLevel(CDKBarTag* _tag, const ENUM_DK_POS_TYPE _dir) {
  CChartObjectTrend  line;
  string name = StringFormat("%s-LVL-%s-%s", 
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
void CAdvFractalSweepBot::Draw() {
  ObjectsDeleteAll(0, Logger.Name);
  CARRAYOBJ_ITER(FracUList, CDKBarTag, DrawLevel(el, SELL););
  CARRAYOBJ_ITER(FracDList, CDKBarTag, DrawLevel(el, BUY););  
}

//+------------------------------------------------------------------+
//| Check Signal
//+------------------------------------------------------------------+
bool CAdvFractalSweepBot::CheckSignal(CDKBarTag* _tag_curr, CDKBarTag* _tag_prev, const ENUM_DK_POS_TYPE _dir, MqlRates& _bar) {
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
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Дистанция '%s_WICK' от фрактала до H/L меньше минимальной: FR_CURR=%s", sig_type_name, _tag_curr.__repr__(true))));  
    return false;
  }
   
  // 05. FRCL: ↑+ЛОНГ: Max дистанция от Фрактала до Закрытия, пункт
  if(MathAbs(_tag_curr.GetValue()-_bar.close) > Sym.PointsToPrice(sig_param.FRCL)) { 
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Дистанция '%s_FRCL' от фрактала до закрытия больше максимальной: FR_CURR=%s", sig_type_name, _tag_curr.__repr__(true))));  
    return false;
  }
  
  // 06. FRPF: ↑+ЛОНГ: Min дистанция от Фрактала до Прошлого, пункт
  if(MathAbs(_tag_curr.GetValue()-_tag_prev.GetValue()) < Sym.PointsToPrice(sig_param.FRPF)) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Дистанция '%s_FRPF' от фрактала до предыдущего больше максимальной: FR_CURR=%s; FR_PREV=%s", 
                                    sig_type_name, _tag_curr.__repr__(true), _tag_prev.__repr__(true))));  
    return false;
  }  

  // 07. TM_STRT: Время начала открытия позиций (формат HH:MM)
  // 07. TM_FNSH: Время окончания открытия позиций (формат HH:MM)
  datetime dt = TimeCurrent(); 
  if(dt < Inputs.FIL_TM_STRT.Time() || dt > Inputs.FIL_TM_FNSH.Time()) {
    Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Запрещенное время торговли: FR_CURR=%s", 
                                  sig_type_name, _tag_curr.__repr__(true))));  
    return false;
  }  
  
  // 08. GN_SLD: Max спред, пункт
  int spread = Sym.Spread();
  if(Inputs.ENT_GN_SPRD > 0 && spread > (int)Inputs.ENT_GN_SPRD) {
    Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышен спред: FR_CURR=%s; FR_PREV=%s; SPREAD=%d>%d", 
                                  sig_type_name, _tag_curr.__repr__(true),
                                  spread, Inputs.ENT_GN_SPRD)));  
    return false;
  }
  
  // 10. GN_PGAP: Max ценовой гэп, пункт (0-откл)
  if(Inputs.FIL_GN_PGAP > 0) {
    double open[];
    if(CopyOpen(Sym.Name(), TF, 0, 1, open) < 0)
      return false;
      
    if(MathAbs(_bar.close-open[0]) > Sym.PointsToPrice(Inputs.FIL_GN_PGAP)) {
      Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышен ценовой гэп: FR_CURR=%s; FR_PREV=%s; GAP=%s > %s", 
                                  sig_type_name, _tag_curr.__repr__(true),
                                  Sym.PriceFormat(MathAbs(_bar.close-open[0])), Sym.PriceFormat(Sym.PointsToPrice(Inputs.FIL_GN_PGAP)))));  
      return false;
    }
  }  
  
  // 11. GN_POSN: Max кол-во позиций в рынке, шт (0-откл)
  if(Inputs.FIL_GN_POSN > 0 && Poses.Total() >= (int)Inputs.FIL_GN_POSN) {
    Logger.Debug(LSF(StringFormat("Сигнал отфильтрован: Превышено максимальное количество позиций в рынке: FR_CURR=%s; FR_PREV=%s", 
                                  sig_type_name, _tag_curr.__repr__(true))));  
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
  
  CDKBarTag* tag_curr;
  CDKBarTag* tag_prev;    

  bool res = false;
  for(int i=0;i<FracDList.Total()-1;i++) {
    tag_curr = FracDList.At(i);
    tag_prev = FracDList.At(i+1);
    if(CheckSignal(tag_curr, tag_prev, BUY, rates[0])) {
      OpenPos(tag_curr, BUY);
      res = true;
    }
  }
  
  for(int i=0;i<FracUList.Total()-1;i++) {
    tag_curr = FracUList.At(i);
    tag_prev = FracUList.At(i+1);
    if(CheckSignal(tag_curr, tag_prev, SELL, rates[0])) {
      OpenPos(tag_curr, SELL);
      res = true;    
    }
  }

  return true;
}

//+------------------------------------------------------------------+
//| Add param set for _trend and _dir
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::AddSignalParam(int _trend, ENUM_DK_POS_TYPE _dir, bool _enabled, uint _wick, uint _frcl, uint _frp) {
  CSignalParam* sig_param;
  CAdvFractalSweepBotInputs::CreateParam(sig_param, Inp_FIL_UL_ENBL, Inp_FIL_UL_WICK, Inp_FIL_UL_FRCL, Inp_FIL_UL_FRPF);
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
     CopyBuffer(Inputs.IndStrucBlockHndl, 5, 0, 1, depth) >= 1) 
    Trend = (depth[0] > 0) ? (int)trend[0] : 0;
    
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

  string sig_type_name = CAdvFractalSweepBotInputs::GetSignalTypeName(Trend, _dir);
  ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)_dir;
  double ep  = Sym.GetPriceToOpen(pt);
  double sl  = Sym.AddToPrice(pt, ep, -1*Sym.PointsToPrice(ent_param.SL));
  double tp  = Sym.AddToPrice(pt, ep, Sym.PointsToPrice(ent_param.TP));
  double lot = ent_param.Lot;
  string comment = StringFormat("%s:%s", Logger.Name, TimeToString(_tag_curr.GetTime()));
  
  ulong res = 0;
  if(_dir == BUY)
    res = Trade.Buy(lot, Sym.Name(), ep, sl, tp, comment);
  if(_dir == SELL)
    res = Trade.Sell(lot, Sym.Name(), ep, sl, tp, comment);
  
  Logger.Assert(res > 0,
                LSF(StringFormat("Позиция открыта: RET_CODE=%d; SIG_TYPE=%s; FR=%s", 
                                 Trade.ResultRetcode(),
                                 sig_type_name, _tag_curr.__repr__(false))),
                WARN, ERROR);
  
  return res;
}