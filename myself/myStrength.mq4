//+------------------------------------------------------------------+
//|                                                   myStrength.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

const string c_objBtn[5] = {
                              "JPY",
         							"AUD",
         							"USD",
         							"GBP",
         							"EUR"
         							};
const string c_arryJPYPair[20] = {
                                 "USDJPY","GBPJPY","EURJPY","AUDJPY",
                                 "GBPAUD","EURAUD","AUDUSD","AUDJPY",
                                 "USDJPY","GBPUSD","AUDUSD","EURUSD",
                                 "GBPJPY","GBPUSD","GBPAUD","EURGBP",
                                 "EURJPY","EURUSD","EURAUD","EURGBP"
                                 };


int OnInit(){
   
   int i;
   //ボタン生成＆作成
   for(i = 0; i < ArraySize(c_objBtn); i++){
      ObjectCreate(0,c_objBtn[i],OBJ_BUTTON,0,100,100);//ボタン生成
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_XDISTANCE,300 + (i * 55));//ボタンX座標
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_YDISTANCE,3);//ボタンY座標
      ObjectSetString(0,c_objBtn[i],OBJPROP_TEXT,c_objBtn[i]);//ボタンテキスト
      ObjectSetInteger(0,c_objBtn[i],OBJPROP_FONTSIZE,10);//フォントサイズ
   }   
   return(INIT_SUCCEEDED);

  }
void deinit(){
   int i;
   //ボタン削除
   for(i = 0; i < ArraySize(c_objBtn); i++){
      if(ObjectFind(c_objBtn[i]) != -1)ObjectDelete(c_objBtn[i]);
   }   
}
void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam) {
   int i;
   int pairCnt = 0;
   long cID;
   //イベント処理
   if(id == CHARTEVENT_OBJECT_CLICK){
      for(i = 0; i < ArraySize(c_objBtn); i++){
         if(sparam == c_objBtn[i]){ 
            pairCnt = i * 4;
            for(cID = ChartFirst(); cID >= 0; cID = ChartNext(cID)){
               ChartSetSymbolPeriod(cID,c_arryJPYPair[pairCnt],Period());
               pairCnt++;
            }
         }
         ObjectSetInteger(ChartID(),c_objBtn[i],OBJPROP_STATE,0);
      }
   }
}

void start(){
}