//+------------------------------------------------------------------+
//|                                                myMatchPeriod.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

const string c_objBtn= "BtnPeriod";

int OnInit(){
   
   f_createBtns();
   return(INIT_SUCCEEDED);
}
void deinit(){
   ObjectDelete(c_objBtn);
}
void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam){
   long i;
   if(id == CHARTEVENT_OBJECT_CLICK){
      if( sparam == c_objBtn){
         ObjectSetInteger(ChartID(), c_objBtn, OBJPROP_STATE, 0);
         for(i = ChartFirst(); i >= 0; i = ChartNext(i)){
            if(ChartPeriod(i) != Period()){
               ChartSetSymbolPeriod(i, ChartSymbol(i), Period());
            }
         }
      }
   }
}
void f_createBtns(){
   //ボタン生成＆作成
   ObjectCreate(0,c_objBtn,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,c_objBtn,OBJPROP_XDISTANCE,10);    //ボタンX座標
   ObjectSetInteger(0,c_objBtn,OBJPROP_YDISTANCE,30);    //ボタンY座標
   ObjectSetInteger(0,c_objBtn,OBJPROP_XSIZE,40);        // ボタンサイズ幅
   ObjectSetInteger(0,c_objBtn,OBJPROP_YSIZE,15);        // ボタンサイズ高さ
   ObjectSetInteger(0,c_objBtn,OBJPROP_FONTSIZE,8);      //フォントサイズ
   ObjectSetInteger(0,c_objBtn,OBJPROP_COLOR,clrBlack);  //フォント色
   ObjectSetString(0,c_objBtn,OBJPROP_TEXT,"Period"); //ボタンテキスト
}
void start(){
}