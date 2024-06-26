//+------------------------------------------------------------------+
//|                                                    4Sessions v2.3|
//|                                                   Andrew Kuptsov |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

const string c_sTgtOpenTime =  "09:30";
const string c_sTgtCloseTime = "16:00";
const string c_sAsiaOpn = "09:30";
const string c_sAsiaCls = "16:00";
const string c_sEuroOpn = "16:00";
const string c_sEuroCls = "21:30";
const double c_splitEquity = 5.0;//証拠金の任意分割
const double c_stopGain = 3.0;//ロスカ迄の幅(小さいほどロスカ範囲が大きくなる)
const int    c_slipage = 20;
const int    c_lotSize = (int)MarketInfo(Symbol(),MODE_LOTSIZE);//1lot辺りの通貨数
const color  c_clrEuro = Linen;
const color  c_clrAsia = LightCyan;
//global
int      g_objEuroNum = 0;
int      g_objAsiaNum = 0;
uint     g_preTickCnt = 0;
bool     g_bCrateAsia = false;
bool     g_bCrateEuro = false;
int OnInit(){
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite);//背景色
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack);//前景色
   ChartSetInteger(0, CHART_SHOW_GRID, false);          //グリッド
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);       //ローソク足表示
   ChartSetInteger(0, CHART_COLOR_CHART_UP, clrBlack);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlack);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrWhite);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBlack);
   return(0);
}

void OnTick(){
   string sTgtEntry = TimeToString(TimeCurrent(),TIME_DATE) + " " + c_sTgtCloseTime;
   string sTodayDate;
   string sCnvRateSymbol = StringSubstr(Symbol(), 3, 3) + "JPY";;
   datetime dTgtEntry = StringToTime(sTgtEntry);
   datetime nowJPTime = TimeCurrent() + 3600 * 6;
   datetime dtSessionClose,dtSessionOpen;
   double   dHigh,dLow;
   double   dAllwWidth;
   double   dStoploss;
   double   dLossPrice;
   double   dLossPips;
   double   dOrderLots;
   double   dTgtPrice;
   double   dConvVal;
   int      iFirstBar,iLastBar;
   bool     bTmp;
   
   sTodayDate = TimeToString(TimeCurrent(),TIME_DATE) + " ";//今日の日付

   if(TimeCurrent() == (StringToTime(sTodayDate + c_sTgtCloseTime) - 3600*6)
      &&(MathAbs(GetTickCount() - g_preTickCnt)) > 1000){//取引時間になった時
      //高安値の調べたい価格帯を設定
      dtSessionClose = StringToTime(sTodayDate + c_sTgtCloseTime) - 3600*6;
      dtSessionOpen  = StringToTime(sTodayDate + c_sTgtOpenTime) - 3600*6;
      //バーシフト計算、高安値計算
      iLastBar  = iBarShift(NULL,0,dtSessionClose,false);
      iFirstBar = iBarShift(NULL,0,dtSessionOpen,false);
      dHigh     = High[ iHighest( NULL,0,MODE_HIGH,iFirstBar-iLastBar+1,iLastBar ) ];
      dLow      = Low [  iLowest( NULL,0,MODE_LOW, iFirstBar-iLastBar+1,iLastBar ) ];
      dAllwWidth = (dHigh - dLow) / 4;
      //エントリー処理
      dLossPips = (dHigh - dLow) * MathPow(10, Digits - 1) / c_stopGain;
      dLossPrice = dLossPips * 100.0;//1Lot辺りの損失額
      if(Close[1] >= dHigh - dAllwWidth){
         //建玉可能数計算
         //dConvVal = MarketInfo(sCnvRateSymbol,MODE_BID);
         //dLossPrice = ( (dHigh - dLow) / c_stopGain) * dConvVal * c_lotSize;//1Lot辺りの損失額
         dOrderLots = (AccountEquity() / c_splitEquity) / dLossPrice;//建玉数
         //エントリー
         dStoploss = Ask + ( (dHigh - dLow) / 1);
         dTgtPrice = Bid - ( (dHigh - dLow) / 1);;
         bTmp = OrderSend(Symbol(), OP_SELL, dOrderLots, Bid, c_slipage, dStoploss, dTgtPrice, "Cmnt", 2525333);
      }
      else if(Close[1] <= dLow + dAllwWidth){
         //建玉可能数計算
         //dConvVal = MarketInfo(sCnvRateSymbol,MODE_ASK);
         //dLossPrice = ( (dHigh - dLow) / c_stopGain) * dConvVal * c_lotSize;//1Lot辺りの損失額
         dOrderLots = (AccountEquity() / c_splitEquity) / dLossPrice;//建玉数
         //エントリー
         dStoploss = Bid - ((dHigh - dLow) / 1);
         dTgtPrice = Ask + ((dHigh - dLow) / 1);;
         bTmp = OrderSend(Symbol(), OP_BUY, dOrderLots, Ask, c_slipage, dStoploss, dTgtPrice, "Cmnt", 2525333);
      }
      g_preTickCnt = GetTickCount();
   }
   f_drawSessions(sTodayDate);
   
}

void f_drawSessions(string sTodayDate){
   
   string sSessionName;
   datetime dtOpn,dtCls;
   double   dHigh,dLow;
   int      iFirstBar,iLastBar;
   //アジア時間色塗り
   dtOpn = (StringToTime(sTodayDate + c_sAsiaOpn) - 3600*6);
   dtCls = (StringToTime(sTodayDate + c_sAsiaCls) - 3600*6);
   if((dtOpn <= TimeCurrent())&&(TimeCurrent() <= dtCls)){
      sSessionName = "Asia" + IntegerToString(g_objAsiaNum);
      if((ObjectFind(sSessionName) == -1)&&(g_bCrateAsia == false)){
         ObjectCreate(sSessionName,OBJ_RECTANGLE,0,0,0,0,0);
         g_bCrateAsia = True;
      }
      iLastBar  = iBarShift(NULL,0,TimeCurrent(),false);
      iFirstBar = iBarShift(NULL,0,dtOpn,false);
      dHigh     = High[ iHighest( NULL,0,MODE_HIGH,iFirstBar-iLastBar+1,iLastBar ) ];
      dLow      = Low [  iLowest( NULL,0,MODE_LOW, iFirstBar-iLastBar+1,iLastBar ) ];
      ObjectSet(sSessionName,OBJPROP_TIME1,dtOpn);
      ObjectSet(sSessionName,OBJPROP_TIME2,TimeCurrent());
      ObjectSet(sSessionName,OBJPROP_COLOR,c_clrAsia);
      ObjectSet(sSessionName,OBJPROP_WIDTH,1);
      ObjectSet(sSessionName,OBJPROP_STYLE,0);
      ObjectSet(sSessionName,OBJPROP_PRICE1,dHigh);
      ObjectSet(sSessionName,OBJPROP_PRICE2,dLow);
   }
   else if(dtCls <= TimeCurrent()){
      g_bCrateAsia = false;
      g_objAsiaNum += 1;
   }
   //欧州時間色塗り
   dtOpn = (StringToTime(sTodayDate + c_sEuroOpn) - 3600*6);
   dtCls = (StringToTime(sTodayDate + c_sEuroCls) - 3600*6);
   if((dtOpn <= TimeCurrent())&&(TimeCurrent() <= dtCls)){
      sSessionName = "Euro" + IntegerToString(g_objEuroNum);
      if((ObjectFind(sSessionName) == -1)&&(g_bCrateEuro == false)){
         ObjectCreate(sSessionName,OBJ_RECTANGLE,0,0,0,0,0);
         g_bCrateEuro = True;
      }
      iLastBar  = iBarShift(NULL,0,TimeCurrent(),false);
      iFirstBar = iBarShift(NULL,0,dtOpn,false);
      dHigh     = High[ iHighest( NULL,0,MODE_HIGH,iFirstBar-iLastBar+1,iLastBar ) ];
      dLow      = Low [  iLowest( NULL,0,MODE_LOW, iFirstBar-iLastBar+1,iLastBar ) ];
      ObjectSet(sSessionName,OBJPROP_TIME1,dtOpn);
      ObjectSet(sSessionName,OBJPROP_TIME2,TimeCurrent());
      ObjectSet(sSessionName,OBJPROP_COLOR,c_clrEuro);
      ObjectSet(sSessionName,OBJPROP_WIDTH,1);
      ObjectSet(sSessionName,OBJPROP_STYLE,0);
      ObjectSet(sSessionName,OBJPROP_PRICE1,dHigh);
      ObjectSet(sSessionName,OBJPROP_PRICE2,dLow);
   }
   else if(dtCls <= TimeCurrent()){
      g_bCrateEuro = false;
      g_objEuroNum += 1;
   }
}