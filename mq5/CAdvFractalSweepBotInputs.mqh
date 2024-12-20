//+------------------------------------------------------------------+
//|                                    CAdvFractalSweepBotInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Generic\HashMap.mqh>
#include "Include\DKStdLib\Common\DKStdLib.mqh"

enum ENUM_AFS_FRACTAL_TYPE {
  AFS_FRACTAL_TYPE_PADD       = 0, // PADD Sorted
  AFS_FRACTAL_TYPE_WILLIAMS   = 1, // Williams
  AFS_FRACTAL_TYPE_CUSTOM35   = 2, // Custom MT5 3/5 bars
};

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
  uint                     FRCN;                                // FRCN: ↑+ЛОНГ: Min дистанция от Фрактала до Закрытия, пункт
  uint                     FRCX;                                // FRCX: ↑+ЛОНГ: Max дистанция от Фрактала до Закрытия, пункт
  uint                     FRPF;                                // _FRPF: ↑+ЛОНГ: Min дистанция от Фрактала до Прошлого, пункт
};

struct CAdvFractalSweepBotInputs {
  // USER INPUTS
  uint                     SET_FDP;                             // SET_FDP: Глубина поиска фракталов, баров
  ENUM_AFS_FRACTAL_TYPE    SET_FRT;                             // FRT: Тип фрактала  
  uint                     SET_FPD_BC;                             // FBC: Количество баров вокруг пика фрактала, шт
  bool                     SET_FPD_PS;                             // FPS: Пики баров фрактала упрорядочены
  bool                     SET_FPD_BS;                             // FBS: Основания баров фрактала упрорядочены  
  uint                     SET_FCS_NP;                          // FCS_NP: CUSTOM35: Number of periods
  uint                     SET_FCS_35;                          // FCS_FB: CUSTOM35: Choose between 3 or 5 bar fractals  
  ENUM_TIMEFRAMES          SET_TTF;                             // TTF: TF определения тренда
  
    
  uint                     FIL_GN_POPN;                         // GN_POSN: Max кол-во позиций в рынке, шт
  uint                     FIL_GN_PPDN;                         // GN_PPDN: Max кол-во позиций в день, шт (0-откл)
  uint                     FIL_GN_PSLN;                         // GN_PSLN: Max кол-во SL позиций в день, шт (0-откл)  
  uint                     FIL_GN_PGAP;                         // GN_PGAP: Max ценовой гэп, пункт
  uint                     FIL_GN_SPRD;                         // GN_SLD: Max спред, пункт
  
  bool                     FIL_NS_ENBL;                         // NS_ENBL: Включить фильтр новостей (не работает в тестере)
  uint                     FIL_NS_FRMN;                         // NS_FRMN: Фильтровать до выхода новости, мин
  uint                     FIL_NS_TOMN;                         // NS_TOMN: Фильтровать после выхода новости, мин
  ENUM_CALENDAR_EVENT_IMPORTANCE FIL_NS_IMPT;                   // NS_IMPT: Начиная с какой важности фильтровать новости  
  
  TimeHHMM                 FIL_TM_STRT;                         // TM_STRT: Время начала открытия позиций (формат HH:MM)
  TimeHHMM                 FIL_TM_FNSH;                         // TM_FNSH: Время окончания открытия позиций (формат HH:MM)
  bool                     FIL_TM_CLEN;                         // TM_CLEN: Закрыть позиций принудительно в HH:MM  
  TimeHHMM                 FIL_TM_CLTM;                         // TM_CLTM: Время принудительного закрытия позиций (формат HH:MM, ""-откл)
  
  uint                     ENT_TM_HRS;                          // TM_HRS: T: Час начала (>24-откл)
  double                   ENT_GN_MGPR;                         // GN_MGPR: Max доля маржи от баланса на аккаунте после входа, %  
   
  color                    UI_COL_FL;                           // UI_COL_FL: Цвет флэта
  color                    UI_COL_UP;                           // UI_COL_UP: Цвет бычьего тренда
  color                    UI_COL_DN;                           // UI_COL_DN: Цвет медвежьего тренда
  bool                     UI_IFR_EN;                           // UI_IFR_EN: Добавить индикаторы 'PADD-Fractal' при запуске
  bool                     UI_ISB_EN;                           // UI_ISB_EN: Добавить индикаторы 'Struture Blocks' при запуске
  
  
  
  // GLOBAL VARS
  int                      IndStrucBlockHndl;
  int                      IndFractalUHndl;
  int                      IndFractalDHndl;
  int                      IndFractalWilliams;
  int                      IndFractalCustom35;

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
                                                                  bool _enabled, uint _wick, uint _frcn, uint _frcx, uint _frpf) {
    _param = new CSignalParam();
    _param.ENBL = _enabled;
    _param.WICK = _wick;
    _param.FRCN = _frcn;
    _param.FRCX = _frcx;
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
                             SET_FDP(24*60),
                             SET_FRT(AFS_FRACTAL_TYPE_CUSTOM35),
                             SET_FPD_BC(3),
                             SET_FPD_PS(true),
                             SET_FPD_BS(false),
                             SET_FCS_NP(2),
                             SET_FCS_35(5),                             
                             SET_TTF(PERIOD_CURRENT),
                             
                             FIL_GN_POPN(1),
                             FIL_GN_PPDN(5),
                             FIL_GN_PSLN(2),
                             FIL_GN_PGAP(5),                             
                             FIL_GN_SPRD(10),
                             
                             FIL_NS_ENBL(true),
                             FIL_NS_FRMN(5),
                             FIL_NS_TOMN(5),
                             FIL_NS_IMPT(CALENDAR_IMPORTANCE_HIGH),
                             
                             FIL_TM_CLEN(true),
                             
                             ENT_TM_HRS(17),
                             ENT_GN_MGPR(50.0),
                             
                             UI_COL_FL(clrLightGray),
                             UI_COL_UP(clrLightGreen),
                             UI_COL_DN(clrPink),
                             UI_IFR_EN(false),
                             UI_ISB_EN(false),
                             
                             IndStrucBlockHndl(-1),
                             IndFractalUHndl(-1),
                             IndFractalDHndl(-1),
                             IndFractalWilliams(-1),
                             IndFractalCustom35(-1)
                           {}                           
  
};
