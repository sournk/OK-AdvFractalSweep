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

#include <ChartObjects\ChartObjectsFibo.mqh>

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
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\History\DKHistory.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CAdvFractalSweepBotInputs.mqh"


class CAdvFractalSweepBot : public CDKBaseBot<CAdvFractalSweepBotInputs> {
public: 

protected:

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
    
  
};

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CAdvFractalSweepBot::CAdvFractalSweepBot(void) {
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

  ShowComment(_ignore_interval);     
}

