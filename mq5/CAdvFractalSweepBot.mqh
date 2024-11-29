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
  int                        CAdvFractalSweepBot::AddFractalToList(ENUM_SERIESMODE _mode, double& _buf[], CArrayObj& _list);
  int                        CAdvFractalSweepBot::FindFractalLevels();
  
  void                       CAdvFractalSweepBot::DrawLevel(CDKBarTag* _tag, const ENUM_DK_POS_TYPE _dir);
  void                       CAdvFractalSweepBot::Draw();
  
  bool                       CAdvFractalSweepBot::CheckSignal(CDKBarTag* _tag, const ENUM_DK_POS_TYPE _dir, MqlRates& _bar);
  bool                       CAdvFractalSweepBot::FindSignals();
  
  int                        CAdvFractalSweepBot::AddParam(int _trend, ENUM_DK_POS_TYPE _dir, bool _enabled, uint _wick, uint _frcl, uint _frp);
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
  CSignalParam* vals[];
  SignalParam.CopyTo(keys, vals);
  for(int i=0;i<ArraySize(vals);i++)
    delete vals[i];
  SignalParam.Clear();  

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
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::OnBar(void) {
  FindSignals();

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
bool CAdvFractalSweepBot::CheckSignal(CDKBarTag* _tag, const ENUM_DK_POS_TYPE _dir, MqlRates& _bar) {
  CSignalParam* val;
  SignalParam.TryGetValue(CAdvFractalSweepBotInputs::GetSignalTypeID(-1, SELL), val);                                         
  Print(val.ENBL);

  // 01. Trading Enabled for Signal
  //int sig_type_id = CAdvFractalSweepBotInputs::GetSignalTypeID(Trend, _dir);
  int sig_type_id = CAdvFractalSweepBotInputs::GetSignalTypeID(-1, SELL);
  string sig_type_name = CAdvFractalSweepBotInputs::GetSignalTypeName(Trend, _dir);
  //CSignalParam* sig_param = Inputs.GetParam(Trend, _dir);
  
  CSignalParam* sig_param;
  SignalParam.TryGetValue(sig_type_id, sig_param);                                         

  if(!sig_param.ENBL) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Signal Filtered: Trading Disabled by '%s_ENBL': FR=%s", sig_type_name, _tag.__repr__(true))));
    return false;
  }
    
  // 02. Fractal is swept only by wick and not by body
  if((_dir == BUY  && !(_tag.GetValue() >= _bar.low && _tag.GetValue() < _bar.close)) ||
     (_dir == SELL && !(_tag.GetValue() >= _bar.close && _tag.GetValue() < _bar.high))) {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("Signal Filtered: Fractal is swept by body '%s_WCSW: ", sig_type_name, _tag.__repr__(true))));  
    return false;
  }
  
  Logger.Info(LSF(_tag.__repr__(true)));
  return true;
}

//+------------------------------------------------------------------+
//| Find signal for any Fractal
//+------------------------------------------------------------------+
bool CAdvFractalSweepBot::FindSignals() {
  MqlRates rates[];
  if(CopyRates(Sym.Name(), TF, 1, 1, rates) < 0)
    return false;
    
  bool res = false;
  CARRAYOBJ_ITER(FracDList, CDKBarTag, 
    res = CheckSignal(el, BUY,  rates[0]) || res;
  )
  
  CARRAYOBJ_ITER(FracUList, CDKBarTag, 
    res = CheckSignal(el, SELL, rates[0]) || res;
  )
  
  return true;
}

//+------------------------------------------------------------------+
//| Add param set for _trend and _dir
//+------------------------------------------------------------------+
int CAdvFractalSweepBot::AddParam(int _trend, ENUM_DK_POS_TYPE _dir, bool _enabled, uint _wick, uint _frcl, uint _frp) {
  CSignalParam* sig_param;
  CAdvFractalSweepBotInputs::CreateParam(sig_param, Inp_FRA_UL_ENBL, Inp_FRA_UL_WICK, Inp_FRA_UL_FRCL, Inp_FRA_UL_FRPF);
  SignalParam.TrySetValue(CAdvFractalSweepBotInputs::GetSignalTypeID(_trend, _dir), sig_param);
  
  return SignalParam.Count();
}
