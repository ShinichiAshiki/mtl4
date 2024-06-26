#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#define BTN_D    (68)
#define BTN_DMMY (9999)
extern color  Clock_Color = DimGray;
extern color BidLineColor = Black;
const string c_objNameBidLine = "BidLine";
const string c_objNameSprdLabel = "SpreadLabel";
const string c_objNamePirProd = "PairPeriod";
const string c_aryStrPeriods[9] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"};
const int c_defPeriods[9] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
long g_btnSwtch = BTN_DMMY;
int init()
{
   //ObjectsDeleteAll();
   f_drawBidLine();
   f_drawSprdBar();
   f_drawPirProd();
   return(0);
}
int deinit()
{
   ObjectDelete(c_objNameBidLine);
   ObjectDelete(c_objNameSprdLabel);
   ObjectDelete(c_objNamePirProd);
   return(0);
}
void start()
{
   double spread = MarketInfo(Symbol(), MODE_SPREAD); 
   string _sp = "",_m = "",_s = "";
   int m,s;
   ////edit Bid Line
   if(ObjectFind(c_objNameBidLine) == -1)f_drawBidLine();
   ObjectSet(c_objNameBidLine,OBJPROP_PRICE1,Bid);
   ////Time to bar expiry
   m = (int)Time[0] + Period() * 60 - (int)CurTime();
   s = m % 60;
   m = (m - s) / 60;
   if(spread < 10) _sp = "..";
   else if(spread < 100) _sp = ".";
   if (m < 10) _m = "0";
   if (s < 10) _s = "0";
   if(ObjectFind(c_objNameSprdLabel) == -1)f_drawSprdBar();
   ObjectSetText(c_objNameSprdLabel, "Spread: " + DoubleToStr(spread, 0) + _sp + " Next Bar in " + _m + DoubleToStr(m, 0) + ":" + _s + DoubleToStr(s, 0), 10, "Courier", Clock_Color);
}
void OnChartEvent(
   const int     id,      // イベントID
   const long&   lparam,  // long型イベント
   const double& dparam,  // double型イベント
   const string& sparam)  // string型イベント
{
   int iObj, i, objTtl;
   long cID;
   
   if(id == CHARTEVENT_KEYDOWN){
      if(lparam == BTN_D)g_btnSwtch = BTN_D;
      else g_btnSwtch = BTN_DMMY;
   }
   else if(id == CHARTEVENT_CLICK){
      if(g_btnSwtch == BTN_D){//D+クリックでオブジェクト全消去
         g_btnSwtch = BTN_DMMY;
         for(cID = ChartFirst(); cID >= 0; cID = ChartNext(cID)){
            iObj = 0;
            i = 0;
            objTtl = ObjectsTotal(cID);
            while(i <= objTtl){
               if((bool)ObjectGetInteger(cID, ObjectName(cID, iObj), OBJPROP_HIDDEN)){//一覧非表示
                  iObj++;
               }
               else{
                  ObjectDelete(cID, ObjectName(cID,iObj));
               }
               i++;
            }
         }
      }
   }
}
void f_drawBidLine(){
   ObjectCreate(c_objNameBidLine,OBJ_HLINE,0,0,Bid); 
   ObjectSet(c_objNameBidLine,OBJPROP_SELECTABLE,false);
   ObjectSet(c_objNameBidLine,OBJPROP_COLOR,BidLineColor);
   ObjectSet(c_objNameBidLine,OBJPROP_HIDDEN,true);
}
void f_drawSprdBar(){
   ObjectCreate(c_objNameSprdLabel, OBJ_LABEL,0, 0, 0);
   ObjectSet(c_objNameSprdLabel, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSet(c_objNameSprdLabel, OBJPROP_XDISTANCE, 10);
   ObjectSet(c_objNameSprdLabel, OBJPROP_YDISTANCE, 2);
   ObjectSet(c_objNameSprdLabel, OBJPROP_BACK,true);
   ObjectSet(c_objNameSprdLabel, OBJPROP_SELECTABLE, false);
   ObjectSet(c_objNameSprdLabel,OBJPROP_HIDDEN,true);
}
void f_drawPirProd(){
   
   int index = ArrayBsearch(c_defPeriods, (int)Period(), WHOLE_ARRAY, 0, MODE_ASCEND);
   ObjectCreate(c_objNamePirProd, OBJ_LABEL,0, 0, 0);
   ObjectSet(c_objNamePirProd, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSet(c_objNamePirProd, OBJPROP_XDISTANCE, 5);
   ObjectSet(c_objNamePirProd, OBJPROP_YDISTANCE, 5);
   ObjectSet(c_objNamePirProd, OBJPROP_BACK,true);
   ObjectSet(c_objNamePirProd, OBJPROP_SELECTABLE, true);
   ObjectSet(c_objNamePirProd,OBJPROP_HIDDEN,true);
   ObjectSetText(c_objNamePirProd, Symbol() + " " + c_aryStrPeriods[index], 10, "Arial", clrBlue);
}