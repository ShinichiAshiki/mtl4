//+------------------------------------------------------------------+
//|                                                  myMatchPair.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

const string c_objBtn[9] = {"GBPUSD", "GBPAUD", "GBPJPY", "EURUSD", "EURAUD", "EURJPY", "USDJPY", "AUDUSD", "AUDJPY"};
const string c_BtnTxt[9] = {"GU", "GA", "GJ", "EU", "EA", "EJ", "UJ", "AU", "AJ"};

int OnInit(){

   f_createBtns();

   return(INIT_SUCCEEDED);
  }
void deinit()
{
   int i;
   //ボタン削除
   for(i = 0; i < ArraySize(c_objBtn); i++){
      ObjectDelete(c_objBtn[i]);
   }
}
void f_createBtns(){
   int i;
   //ボタン生成＆作成
   for(i = 0; i < ArraySize(c_objBtn); i++){
      ObjectCreate(0,c_objBtn[i],OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_XDISTANCE,10);           //ボタンX座標
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_YDISTANCE,20 + (i * 25));//ボタンY座標
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_XSIZE,40);               // ボタンサイズ幅
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_YSIZE,15);               // ボタンサイズ高さ
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_FONTSIZE,8);             //フォントサイズ
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_COLOR,clrBlack);         //フォント色
      ObjectSetString(0,c_objBtn[i],OBJPROP_TEXT,c_BtnTxt[i]);        //ボタンテキスト
   }
}
void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam){
   int i;
   long j;
   
   if(id == CHARTEVENT_OBJECT_CLICK){
      for(i = 0; i < ArraySize(c_objBtn); i++){
         if(sparam == c_objBtn[i]){
            ObjectSetInteger(ChartID(), c_objBtn[i], OBJPROP_STATE, 0);
            for(j = ChartFirst(); j >= 0; j = ChartNext(j)){
               if(ChartSymbol(j) != c_objBtn[i]){
                  ChartSetSymbolPeriod(j, c_objBtn[i], ChartPeriod(j));
               }
            }
            break;
         }
      }
   }   
}
void start(){
}