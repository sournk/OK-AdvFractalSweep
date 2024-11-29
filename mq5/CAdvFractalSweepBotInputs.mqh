//+------------------------------------------------------------------+
//|                                    CAdvFractalSweepBotInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Generic\HashMap.mqh>
#include "Include\DKStdLib\Common\DKStdLib.mqh"

struct TimeHHMM {
  int                      Hour;
  int                      Min;
  
  void Init(const string _str) {
    MqlDateTime dt_mql;
    datetime dt = StringToTime(_str);
    TimeToStruct(dt, dt_mql);
    Hour = dt_mql.hour;
    Min  = dt_mql.min;
  }
  
  datetime Time() {
    MqlDateTime dt_mql;
    TimeCurrent(dt_mql);
    dt_mql.hour = Hour;
    dt_mql.min  = Min;
    dt_mql.sec  = 0;
    return StructToTime(dt_mql);
  }
};

class CEntryParam {
public:
  double                   Lot;                                 
  uint                     SL;                                
  uint                     TP;                               
};

class CSignalParam {
public:
  bool                     ENBL;                                // ENBL: ↑+ЛОНГ: Тогровля включена
  uint                     WICK;                                // WICK: ↑+ЛОНГ: Min дистанция свипа, пункт
  uint                     FRCL;                                // FRCL: ↑+ЛОНГ: Max дистанция от Фрактала до Закрытия, пункт
  uint                     FRPF;                                // _FRPF: ↑+ЛОНГ: Min дистанция от Фрактала до Прошлого, пункт
};

struct CAdvFractalSweepBotInputs {
  // USER INPUTS
  uint                     FRA_DPT;                             // FRA_DPT: Глубина поиска фракталов, баров
  
  uint                     FIL_GN_POSN;                         // GN_POSN: Max кол-во позиций в рынке, шт
  uint                     FIL_GN_PGAP;                         // GN_PGAP: Max ценовой гэп, пункт
  
  TimeHHMM                 FIL_TM_STRT;                         // TM_STRT: Время начала открытия позиций (формат HH:MM)
  TimeHHMM                 FIL_TM_FNSH;                         // TM_FNSH: Время окончания открытия позиций (формат HH:MM)
  bool                     FIL_TM_CLEN;                         // TM_CLEN: Закрыть позиций принудительно в HH:MM  
  TimeHHMM                 FIL_TM_CLTM;                         // TM_CLTM: Время принудительного закрытия позиций (формат HH:MM, ""-откл)
  
  
  uint                     ENT_GN_SPRD;                         // GN_SLD: Max спред, пункт
  uint                     ENT_TM_HRS;                          // TM_HRS: T: Час начала (>24-откл)
  
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
                             
                             FIL_GN_POSN(1),
                             FIL_GN_PGAP(5),
                             
                             FIL_TM_CLEN(true),
                             
                             ENT_GN_SPRD(10),
                             ENT_TM_HRS(17),
                             
                             IndStrucBlockHndl(-1),
                             IndFractalUHndl(-1),
                             IndFractalDHndl(-1)
                           {}                           
  
};
