//+------------------------------------------------------------------+
//|                                               myOrderHIstory.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//グローバルオブジェクト名
const string c_objEntry= "Entry";
const string c_objLots= "Lots";
const string c_objExit= "Exit";
const string c_objProfit= "Profit";
const string c_objNowEntry= "NowEntry";
const string c_objNowLots= "NowLots";

bool g_flgEntry = false;
bool g_flgPreEntry = false;
int OnInit(){
   double DrawPtProfit, DrawPtLots;
   double resultPips;
   string objEntry, objLots, objExit, objProfit;
   string tmpSplit[];
   string strPips;
   int i;
   int numArry;
   bool Select_bool;
   
   for(i = 0; i < OrdersHistoryTotal(); i++){
      //オブジェクト名決定.(グローバルオブジェクト名 + 注文番号)
      objEntry = StringConcatenate(c_objEntry,IntegerToString(i));
      objLots = StringConcatenate(c_objLots,IntegerToString(i));
      objExit = StringConcatenate(c_objExit,IntegerToString(i));
      objProfit = StringConcatenate(c_objProfit,IntegerToString(i));
      
      Select_bool = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);//過去注文選択
      if ((Select_bool == true) && (OrderSymbol() == Symbol())) {
         //Lot数と結果を表示するY座標の計算
         DrawPtLots = ((double)(int)(OrderOpenPrice() * MathPow(10, Digits - 1) + 1.0)) / (MathPow(10, Digits - 1));
         DrawPtProfit = ((double)(int)(OrderClosePrice() * MathPow(10, Digits - 1) + 1.0)) / (MathPow(10, Digits - 1));
         //エントリー描画
         ObjectCreate(ChartID(), objEntry, OBJ_ARROW_CHECK, 0, OrderOpenTime(), OrderOpenPrice());
         ObjectSetInteger(ChartID(),objEntry,OBJPROP_COLOR,clrBlue);    //色
         ObjectSetInteger(ChartID(),objEntry,OBJPROP_WIDTH,2);          //幅設定
         ObjectSetInteger(ChartID(),objEntry,OBJPROP_BACK,true);        //背景表示
         ObjectSetInteger(ChartID(),objEntry,OBJPROP_HIDDEN,true);      //リスト表示
         ObjectSetInteger(ChartID(),objEntry,OBJPROP_SELECTABLE,false); // オブジェクトの選択可否設定
         //ロット数描画
         ObjectCreate(ChartID(), objLots, OBJ_TEXT, 0, OrderOpenTime(), DrawPtLots);
         ObjectSetInteger(ChartID(),objLots,OBJPROP_COLOR,clrBlue);    //色
         ObjectSetInteger(ChartID(),objLots,OBJPROP_FONTSIZE,8);       //フォントサイズ
         ObjectSetInteger(ChartID(),objLots,OBJPROP_BACK,true);        //背景表示
         ObjectSetInteger(ChartID(),objLots,OBJPROP_HIDDEN,true);      //リスト表示
         ObjectSetString(ChartID(),objLots,OBJPROP_TEXT, DoubleToString(OrderLots(),2));
         //決済描画
         ObjectCreate(ChartID(), objExit, OBJ_ARROW_STOP, 0, OrderCloseTime(), OrderClosePrice());
         ObjectSetInteger(ChartID(),objExit,OBJPROP_COLOR,clrRed);      //色
         ObjectSetInteger(ChartID(),objExit,OBJPROP_WIDTH,2);           //幅設定
         ObjectSetInteger(ChartID(),objExit,OBJPROP_BACK,true);         //背景表示
         ObjectSetInteger(ChartID(),objExit,OBJPROP_HIDDEN,true);       //リスト表示
         ObjectSetInteger(ChartID(),objExit,OBJPROP_SELECTABLE,false);  //オブジェクトの選択可否設定
         //値幅描画
         ObjectCreate(ChartID(), objProfit, OBJ_TEXT, 0, OrderCloseTime(), DrawPtProfit);
         resultPips = MathAbs((OrderOpenPrice() - OrderClosePrice()) * MathPow(10, Digits - 1));
         if(OrderProfit() < 0)resultPips = resultPips * (-1);
         strPips = DoubleToString(resultPips);
         numArry = StringSplit(strPips, '.', tmpSplit);
         strPips = StringConcatenate(tmpSplit[0], ".", StringSubstr(tmpSplit[1], 0, 1));
         ObjectSetInteger(ChartID(),objProfit,OBJPROP_COLOR,clrRed);    //色
         ObjectSetInteger(ChartID(),objProfit,OBJPROP_FONTSIZE,8);;     //フォントサイズ
         ObjectSetInteger(ChartID(),objProfit,OBJPROP_BACK,true);       //背景表示
         ObjectSetInteger(ChartID(),objProfit,OBJPROP_HIDDEN,true);     //リスト表示
         //ObjectSetString(ChartID(),objProfit,OBJPROP_TEXT, DoubleToString(OrderProfit(),0));//損益額
         ObjectSetString(ChartID(),objProfit,OBJPROP_TEXT, strPips);
      }
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   
   int i;
   string objEntry, objLots, objExit, objProfit;
   string objNowEntry, objNowLots;
   
   for(i = 0; i < OrdersHistoryTotal(); i++) {
      objEntry = StringConcatenate(c_objEntry,IntegerToString(i));
      objLots = StringConcatenate(c_objLots,IntegerToString(i));
      objExit = StringConcatenate(c_objExit,IntegerToString(i));
      objProfit = StringConcatenate(c_objProfit,IntegerToString(i));
      if(ObjectFind(objEntry) != -1)ObjectDelete(objEntry);
      if(ObjectFind(objLots) != -1)ObjectDelete(objLots);
      if(ObjectFind(objExit) != -1)ObjectDelete(objExit);
      if(ObjectFind(objProfit) != -1)ObjectDelete(objProfit);
   }
   for(i = 0; i < OrdersHistoryTotal(); i++) {
      objNowEntry = StringConcatenate(c_objNowEntry,IntegerToString(i));
      objNowLots = StringConcatenate(c_objNowLots,IntegerToString(i));
      if(ObjectFind(objNowEntry) != -1)ObjectDelete(objNowEntry);
      if(ObjectFind(objNowLots) != -1)ObjectDelete(objNowLots);
   }
}
void OnChartEvent(
                 const int     id,      // イベントID
                 const long&   lparam,  // long型イベント
                 const double& dparam,  // double型イベント
                 const string& sparam)  // string型イベント
{
   double DrawPtProfit, DrawPtLots;
   string objNowEntry, objNowLots;
   int i;
   bool Select_bool; 
   if(id == CHARTEVENT_CLICK){
      if(OrdersTotal() > 0){//ポジション保有時
         for(i = 0; i < OrdersTotal(); i++) {//保有中ポジションの描画
            objNowEntry = StringConcatenate(c_objNowEntry,IntegerToString(i));
            objNowLots = StringConcatenate(c_objNowLots,IntegerToString(i));
            Select_bool = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);//保有中取引選択
            if ((Select_bool == true) && (OrderSymbol() == Symbol())) {
               //Lot数と結果を表示するY座標の計算
               DrawPtLots = ((double)(int)(OrderOpenPrice() * MathPow(10, Digits - 1) + 1.0)) / (MathPow(10, Digits - 1));
               DrawPtProfit = ((double)(int)(OrderClosePrice() * MathPow(10, Digits - 1) + 1.0)) / (MathPow(10, Digits - 1));
               //エントリー描画
               if(ObjectFind(objNowEntry) != 1){
                  ObjectCreate(ChartID(), objNowEntry, OBJ_ARROW_CHECK, 0, OrderOpenTime(), OrderOpenPrice());
                  ObjectSetInteger(ChartID(),objNowEntry,OBJPROP_COLOR,clrMediumSpringGreen);//色
                  ObjectSetInteger(ChartID(),objNowEntry,OBJPROP_WIDTH,2);// 幅設定
                  ObjectSetInteger(ChartID(),objNowEntry,OBJPROP_BACK,true);//背景表示
               }   
               //ロット数描画
               if(ObjectFind(objNowLots) != 1){
                  ObjectCreate(ChartID(), objNowLots, OBJ_TEXT, 0, OrderOpenTime(), DrawPtLots);
                  ObjectSetInteger(ChartID(),objNowLots,OBJPROP_COLOR,clrMediumSpringGreen);//色
                  ObjectSetInteger(ChartID(),objNowLots,OBJPROP_FONTSIZE,8);;//フォントサイズ
                  ObjectSetString(ChartID(),objNowLots,OBJPROP_TEXT, DoubleToString(OrderLots(),2));
                  ObjectSetInteger(ChartID(),objNowLots,OBJPROP_BACK,true);//背景表示
               }   
            }
         }
         g_flgEntry = true;
      }
      else{
         g_flgEntry = false;
      }
      if((g_flgEntry == false) && (g_flgPreEntry == true)){//立下り時
         for(i = 0; i < OrdersHistoryTotal(); i++){
            objNowEntry = StringConcatenate(c_objNowEntry,IntegerToString(i));
            objNowLots = StringConcatenate(c_objNowLots,IntegerToString(i));
            if(ObjectFind(objNowEntry) != -1)ObjectDelete(objNowEntry);
            if(ObjectFind(objNowLots) != -1)ObjectDelete(objNowLots);
         }
         OnInit();
      }
      g_flgPreEntry = g_flgEntry;
   }
}

void start(){
}