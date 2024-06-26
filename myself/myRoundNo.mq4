//+------------------------------------------------------------------+
//|                                                    myRoundNo.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

input color clrLine = DarkOrange;
const int g_tgtDigits = 2;
const int g_numLines = 3;
const string c_objRoundLine = "RoundLine";
int OnInit(){
   return(INIT_SUCCEEDED);
}   
void OnDeinit(const int reason){
   
   string objName = "";
   int i;
   
   for(i = (g_numLines * (-1)); i <= g_numLines; i++){
      objName = StringConcatenate(c_objRoundLine, (string)i);
      if(ObjectFind(objName) != -1)ObjectDelete(objName);
   }
}

int start(){
   
   double point = 0.0;
   string objName = "";
   int i;
   
   if(Period() <= 1){//1分足以下表示
      for(i = (g_numLines * (-1)); i <= g_numLines; i++){
         point = ((double)(int)(Bid * MathPow(10, Digits - g_tgtDigits) + (double)i)) / ( MathPow(10, Digits - g_tgtDigits));
         objName = StringConcatenate(c_objRoundLine, (string)i);
         if(ObjectFind(objName) == -1){
            ObjectCreate(ChartID(), objName, OBJ_HLINE, 0, 0, 0.0);
            ObjectSet(objName, OBJPROP_WIDTH, 1);
            ObjectSet(objName, OBJPROP_COLOR, clrLine);
            ObjectSet(objName, OBJPROP_SELECTABLE, false);// オブジェクトの選択可否設定
            ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT); //点線
            ObjectSet(objName,OBJPROP_HIDDEN,true);
         }
         ObjectSet(objName,OBJPROP_PRICE1,point);
      }
   }   
   return(0);
}