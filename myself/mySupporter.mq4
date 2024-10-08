//+------------------------------------------------------------------+
//|                                                   mySupporter.mq4|
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                              https://www.mql4.com|
//+------------------------------------------------------------------+
// Draw the following inf.
// # Draw Bid Line
// # Draw Spread Label to bottom right
// # Draw Currency Pair + Time Frame to upper right 
// # Draw order history "o" + click
// # Delete all not hidden objects "d" + click
#property version   "1.00"
#property strict
#property indicator_chart_window
#define BTN_D    (68)
#define BTN_O    (79)
#define BTN_DMMY (9999)

// input
input int in_TradeHistoryCount = 100; // draw count
//const
const string c_objNameBidLine = "BidLine";
const string c_objNameSprdLabel = "SpreadLabel";
const string c_objNamePirProd = "PairPeriod";
const string c_aryStrPeriods[9] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"};
const int c_defPeriods[9] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
const string c_objEntry= "Entry";
const string c_objLots= "Lots";
const string c_objExit= "Exit";
const string c_objTradeLine= "TradeLine";
const string c_objProfit= "Profit";
// global
long g_btnSwtch = BTN_DMMY;

int init(){
   f_drawPirProd();
   return(INIT_SUCCEEDED );
}

void deinit()
{
   ObjectDelete(c_objNameBidLine);
   ObjectDelete(c_objNameSprdLabel);
   ObjectDelete(c_objNamePirProd);
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--){
      ObjectDelete(StringConcatenate(c_objEntry,IntegerToString(i)));
      ObjectDelete(StringConcatenate(c_objLots,IntegerToString(i)));
      ObjectDelete(StringConcatenate(c_objExit,IntegerToString(i)));
      ObjectDelete(StringConcatenate(c_objTradeLine,IntegerToString(i)));
      ObjectDelete(StringConcatenate(c_objProfit,IntegerToString(i)));
   }
}

void start()
{
   double spread = MarketInfo(Symbol(), MODE_SPREAD); 
   string _sp = "",_m = "",_s = "";

   //// edit Bid Line
   if(ObjectFind(c_objNameBidLine) == -1)f_drawBidLine();
   ObjectSet(c_objNameBidLine,OBJPROP_PRICE1,Bid);

   //// Time to bar expiry
   int m = (int)Time[0] + Period() * 60 - (int)CurTime();
   int s = m % 60;
   m = (m - s) / 60;
   if(spread < 10) _sp = "..";
   else if(spread < 100) _sp = ".";
   if (m < 10) _m = "0";
   if (s < 10) _s = "0";

   if(ObjectFind(c_objNameSprdLabel) == -1)f_drawSprdBar();
   ObjectSetText(c_objNameSprdLabel,
      "Spread: " + DoubleToStr(spread, 0) + _sp + " " +
      // "Next Bar: " + _m + DoubleToStr(m, 0) + ":" + _s + DoubleToStr(s, 0) + " " +
      "JTime: " + TimeToString(TimeCurrent() + (6 * 60 * 60), TIME_SECONDS)
      , 10, "Courier", DimGray);
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   if(id == CHARTEVENT_KEYDOWN){
      if(lparam == BTN_D)g_btnSwtch = BTN_D;
      else if(lparam == BTN_O)g_btnSwtch = BTN_O;
      else g_btnSwtch = BTN_DMMY;
   }
   else if(id == CHARTEVENT_CLICK){
      if(g_btnSwtch == BTN_O){ // Draw order history "o" + click
         g_btnSwtch = BTN_DMMY;
         f_drawTradeHistory(in_TradeHistoryCount);
      }else if(g_btnSwtch == BTN_D){ // Delete all objects "d" + click
         g_btnSwtch = BTN_DMMY;
         int totalObjects = ObjectsTotal(ChartID());
         for(int i = totalObjects - 1; i >= 0; i--) {
            string objectName = ObjectName(ChartID(), i);
            if(!ObjectGetInteger(ChartID(), objectName, OBJPROP_HIDDEN)) {
               ObjectDelete(ChartID(), objectName); // Remove non-hidden objects
            }
         }
      }
   }
}

void f_drawBidLine(){
   ObjectCreate(c_objNameBidLine,OBJ_HLINE,0,0,Bid); 
   ObjectSet(c_objNameBidLine,OBJPROP_SELECTABLE,false);
   ObjectSet(c_objNameBidLine,OBJPROP_COLOR,Black);
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
void f_drawTradeHistory(int drawCount){
   int tradesDisplayed = 0;
   // Loop through the history to find past trades
   for(int i = OrdersHistoryTotal() - 1; i >= 0 && tradesDisplayed < drawCount; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
         if (Symbol() != OrderSymbol()) continue;
         double entryPrice = OrderOpenPrice();
         double exitPrice = OrderClosePrice();
         datetime entryTime = OrderOpenTime();
         datetime exitTime = OrderCloseTime();
         color entryColor, exitColor;

         // Determine colors based on order type
         if(OrderType() == OP_BUY){
            entryColor = clrRed;
            exitColor = clrBlue;
         }
         else if(OrderType() == OP_SELL){
            entryColor = clrBlue;
            exitColor = clrRed;
         }else{
            continue;
         }

         // Draw entry arrow
         string objEntry = StringConcatenate(c_objEntry,IntegerToString(i));
         ObjectCreate(objEntry, OBJ_ARROW, 0, entryTime, entryPrice);
         ObjectSetInteger(0, objEntry, OBJPROP_COLOR, entryColor);
         ObjectSetInteger(0, objEntry, OBJPROP_WIDTH, 2);
         // Draw entry lot
         double DrawPtLots = ((double)(int)(OrderOpenPrice() * MathPow(10, Digits - 1) + 1.0)) / (MathPow(10, Digits - 1));
         string objLots = StringConcatenate(c_objLots,IntegerToString(i));
         ObjectCreate(objLots, OBJ_TEXT, 0, entryTime, DrawPtLots);
         ObjectSetInteger(0, objLots, OBJPROP_COLOR, entryColor);
         ObjectSetInteger(0, objLots,OBJPROP_FONTSIZE,8);
         ObjectSetInteger(0, objLots, OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, objLots,OBJPROP_BACK,true);
         ObjectSetString(0, objLots,OBJPROP_TEXT, DoubleToString(OrderLots(), 2));
         // Draw exit arrow
         string objExit = StringConcatenate(c_objExit,IntegerToString(i));
         ObjectCreate(objExit, OBJ_ARROW, 0, exitTime, exitPrice);
         ObjectSetInteger(0, objExit, OBJPROP_COLOR, exitColor);
         ObjectSetInteger(0, objExit, OBJPROP_WIDTH, 2);
         // Draw dot trendline from entry to exit
         string objTrendline = StringConcatenate(c_objTradeLine,IntegerToString(i));
         ObjectCreate(objTrendline, OBJ_TREND, 0, entryTime, entryPrice, exitTime, exitPrice);
         ObjectSetInteger(0, objTrendline, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, objTrendline, OBJPROP_COLOR, exitColor);
         ObjectSetInteger(0, objTrendline, OBJPROP_RAY_LEFT, false);
         ObjectSetInteger(0, objTrendline, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, objTrendline, OBJPROP_WIDTH, 1);
         // Draw pips
         string objProfit = StringConcatenate(c_objProfit,IntegerToString(i));
         double resultPips = MathAbs((OrderOpenPrice() - OrderClosePrice()) * MathPow(10, Digits - 1));
         double DrawPtProfit = ((double)(int)(OrderClosePrice() * MathPow(10, Digits - 1) + 1.0)) / (MathPow(10, Digits - 1));
         ObjectCreate(objProfit, OBJ_TEXT, 0, OrderCloseTime(), DrawPtProfit);
         if(OrderProfit() < 0)resultPips = resultPips * (-1);
         ObjectSetInteger(0, objProfit,OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0, objProfit,OBJPROP_FONTSIZE,8);
         ObjectSetInteger(0, objProfit,OBJPROP_BACK,true);
         ObjectSetString(0, objProfit,OBJPROP_TEXT, DoubleToString(resultPips, 2));

         tradesDisplayed++;
      }
   }
}