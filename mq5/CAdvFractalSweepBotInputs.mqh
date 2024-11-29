//+------------------------------------------------------------------+
//|                                    CAdvFractalSweepBotInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Generic\HashMap.mqh>
#include "Include\DKStdLib\Common\DKStdLib.mqh"


class CSignalParam {
public:
  bool                     ENBL;                                // UL_ENBL: ↑+ЛОНГ: Тогровля включена
  uint                     WICK;                                // UL_WICK: ↑+ЛОНГ: Min дистанция свипа, пункт
  uint                     FRCL;                                // UL_FRCL: ↑+ЛОНГ: Max дистанция от Фрактала до Закрытия, пункт
  uint                     FRPF;                                // UL_FRPF: ↑+ЛОНГ: Min дистанция от Фрактала до Прошлого, пункт
};

struct CAdvFractalSweepBotInputs {
  // USER INPUTS
  uint                     FRA_DPT;                             // FRA_DPT: Глубина поиска фракталов, баров
  
  // GLOBAL VARS
  int                      IndStrucBlockHndl;
  int                      IndFractalUHndl;
  int                      IndFractalDHndl;

  static int               CAdvFractalSweepBotInputs::GetSignalTypeID(int _trend, ENUM_DK_POS_TYPE _dir) {
    if(_trend > 0  && _dir == BUY)  return 1;
    if(_trend > 0  && _dir == SELL) return 2;
    if(_trend < 0  && _dir == BUY)  return 3;
    if(_trend < 0  && _dir == SELL) return 4;
    if(_trend == 0 && _dir == BUY)  return 5;
    if(_trend == 0 && _dir == SELL) return 6;
    return 0;    
  }
  
  static string            CAdvFractalSweepBotInputs::GetSignalTypeName(int _trend, ENUM_DK_POS_TYPE _dir) {
    if(_trend > 0  && _dir == BUY)  return "UL";
    if(_trend > 0  && _dir == SELL) return "US";
    if(_trend < 0  && _dir == BUY)  return "DB";
    if(_trend < 0  && _dir == SELL) return "DS";
    if(_trend == 0 && _dir == BUY)  return "FB";
    if(_trend == 0 && _dir == SELL) return "FS";
    return "";    
  }  

  static void              CAdvFractalSweepBotInputs::CreateParam(CSignalParam*& _param, 
                                                                  bool _enabled, uint _wick, uint _frcl, uint _frpf) {
    _param = new CSignalParam();
    _param.ENBL = _enabled;
    _param.WICK = _wick;
    _param.FRCL = _frcl;
    _param.FRPF = _frpf;
  }
  
  //CSignalParam*            CAdvFractalSweepBotInputs::GetParam(int _trend, ENUM_DK_POS_TYPE _dir) {
  //  CSignalParam* res;
  //  int sig_id = GetSignalTypeID(_trend, _dir);
  //  if(SignalParam.TryGetValue(sig_id, res))
  //    return res;
  //  return NULL;
  //}
                                                               
  
  void                     CAdvFractalSweepBotInputs(): 
                             FRA_DPT(24*60),
                             
                             IndStrucBlockHndl(-1),
                             IndFractalUHndl(-1),
                             IndFractalDHndl(-1)
                           {}                           
  
};
