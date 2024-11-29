//+------------------------------------------------------------------+
//|                                    CAdvFractalSweepBotInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

struct CAdvFractalSweepBotInputs {
  // USER INPUTS
  bool                     UI_TRD_ENB_TrendDepth_Enabled;                   // UI_TRD_ENB: Показать грубину тренда  

  color                    UI_COL_FLT_Color_Flat;                           // UI_COL_FLT: Цвет флета
  color                    UI_COL_UP_Color_Up;                              // UI_COL_UP: Цвет бычего тренда
  color                    UI_COL_DWN_Color_Down;                           // UI_COL_DWN: Цвет медвежьего тренда  
  
  string                   ALR_TF_PUP_TF_AlarmList;                         // ALR_TF_PUP: Таймфремы с оповещенями в терминал (';' раздлеитель)
  string                   ALR_TF_MOB_TF_MobileList;                        // ALR_TF_MOB: Таймфремы с оповещенями на телефон (';' раздлеитель)

  
  // GLOBAL VARS
  int                      IndStrucBlockHndl;
  int                      IndFractalUHndl;
  int                      IndFractalDHndl;
};
