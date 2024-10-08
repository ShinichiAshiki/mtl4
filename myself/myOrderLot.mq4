//+------------------------------------------------------------------+
//|                                                  myOrderLots.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com" 
#property version   "1.00"
#property strict
#property indicator_chart_window
//入力パラメータ
input double in_Equity = 1000.0;
//構造体
struct details{
   double equity;
   double pips;
   double nableLot;
   double margin;
};
//定数
const string c_btnStopLine       = "BtnStopLine";
const string c_btnEtryLine       = "BtnEtryLine";
const string c_objSLName         = "StopLine";
const string c_objEtryName       = "EntryLine";
const string c_objDetails[4]     = {"equity", "margin", "lossCutPips", "nableLot"};
const int    c_leverage = AccountLeverage();
const int    c_lotSize = (int)MarketInfo(Symbol(),MODE_LOTSIZE);//1lot辺りの通貨数
//グローバル変数
double g_stopValue = 0.0;
double g_entryValue = 0.0;
double g_splitEquity = 1.0;//証拠金の任意分割
double g_equity = (AccountBalance() / g_splitEquity);
details g_strDtls;

int OnInit()
{
   f_createBtns();
   f_createText();
   f_drawStpLine();
   f_drawEntryLine();
   return(INIT_SUCCEEDED);
}
  
void deinit()
{
   ObjectDelete(c_btnStopLine);
   ObjectDelete(c_btnEtryLine);
   ObjectDelete(c_objSLName);
   ObjectDelete(c_objEtryName);
   for(int i = 0; i < ArraySize(c_objDetails); i++){
      ObjectDelete(c_objDetails[i]);
   }
}  
void start(){
   f_calcPrm();
}

void OnChartEvent(
   const int     id,      // イベントID
   const long&   lparam,  // long型イベント
   const double& dparam,  // double型イベント
   const string& sparam)  // string型イベント
{
   
   if(id == CHARTEVENT_OBJECT_DRAG){
      g_stopValue = NormalizeDouble(ObjectGet(c_objSLName, OBJPROP_PRICE1), Digits);//ストップロス価格の変更
      g_entryValue = NormalizeDouble(ObjectGet(c_objEtryName, OBJPROP_PRICE1), Digits);//エントリー価格の変更
      f_calcPrm();
   }
   else if(id == CHARTEVENT_OBJECT_CLICK){
      if(sparam == c_btnStopLine){//SLラインボタン押下
         ObjectSetInteger(ChartID(), c_btnStopLine, OBJPROP_STATE, 0);// ボタンを押してない状態に戻す
         if(ObjectFind(c_objSLName) == -1){//消えてたら再描画
            f_drawStpLine();
            f_calcPrm();
         }
         else{
            ObjectDelete(c_objSLName);
            f_calcPrm();
         }
      }
      else if(sparam == c_btnEtryLine){//Entryラインボタン押下
         ObjectSetInteger(ChartID(), c_btnEtryLine, OBJPROP_STATE, 0);// ボタンを押してない状態に戻す
         if(ObjectFind(c_objEtryName) == -1){//消えてたら再描画
            f_drawEntryLine();
            f_calcPrm();
         }
         else{
            ObjectDelete(c_objEtryName);
            f_calcPrm();
         }
      }
   }
}
void f_createBtns(){
   //ボタン生成＆作成
   //Stop Line
   ObjectCreate(0,c_btnStopLine,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,c_btnStopLine,OBJPROP_XDISTANCE,310);   //ボタンX座標
   ObjectSetInteger(0,c_btnStopLine,OBJPROP_YDISTANCE,0);     //ボタンY座標
   ObjectSetInteger(0,c_btnStopLine,OBJPROP_XSIZE,60);        //ボタンサイズ幅
   ObjectSetInteger(0,c_btnStopLine,OBJPROP_YSIZE,20);        //ボタンサイズ高さ
   ObjectSetInteger(0,c_btnStopLine,OBJPROP_FONTSIZE,8);      //フォントサイズ
   ObjectSetInteger(0,c_btnStopLine,OBJPROP_COLOR,clrBlack);  //フォント色
   ObjectSetString(0,c_btnStopLine,OBJPROP_TEXT,c_objSLName); //ボタンテキスト
   // Entry Line
   ObjectCreate(0,c_btnEtryLine,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,c_btnEtryLine,OBJPROP_XDISTANCE,390);   //ボタンX座標
   ObjectSetInteger(0,c_btnEtryLine,OBJPROP_YDISTANCE,0);     //ボタンY座標
   ObjectSetInteger(0,c_btnEtryLine,OBJPROP_XSIZE,60);        //ボタンサイズ幅
   ObjectSetInteger(0,c_btnEtryLine,OBJPROP_YSIZE,20);        //ボタンサイズ高さ
   ObjectSetInteger(0,c_btnEtryLine,OBJPROP_FONTSIZE,8);      //フォントサイズ
   ObjectSetInteger(0,c_btnEtryLine,OBJPROP_COLOR,clrBlack);  //フォント色
   ObjectSetString(0,c_btnEtryLine,OBJPROP_TEXT,c_objEtryName); //ボタンテキスト
}
void f_drawStpLine(){
   datetime getTime;
   int windowNo;
   //Stop Line
   ChartXYToTimePrice(ChartID(), 0, 50, windowNo, getTime, g_stopValue);
   ObjectCreate(0, c_objSLName, OBJ_HLINE, 0, 0, g_stopValue);//ストップロスライン生成
   ObjectSetInteger(0,c_objSLName,OBJPROP_COLOR,clrMagenta);
   ObjectSetInteger(0,c_objSLName,OBJPROP_STYLE,STYLE_SOLID); // ラインのスタイル設定
   ObjectSetInteger(0,c_objSLName,OBJPROP_BACK,false);        // オブジェクトの背景表示設定
   ObjectSetInteger(0,c_objSLName,OBJPROP_SELECTABLE,true);   // オブジェクトの選択可否設定
   ObjectSetInteger(0,c_objSLName,OBJPROP_SELECTED,true);     // オブジェクトのアクティブ設定
   ObjectSetInteger(0,c_objSLName, OBJPROP_HIDDEN, true);
}
void f_drawEntryLine(){
   datetime getTime;
   int windowNo;
   ChartXYToTimePrice(ChartID(), 0, 50 + 10, windowNo, getTime, g_entryValue);
   ObjectCreate(0, c_objEtryName, OBJ_HLINE, 0, 0, g_entryValue);//ストップロスライン生成
   ObjectSetInteger(0,c_objEtryName,OBJPROP_COLOR,clrBlue);
   ObjectSetInteger(0,c_objEtryName,OBJPROP_STYLE,STYLE_SOLID); // ラインのスタイル設定
   ObjectSetInteger(0,c_objEtryName,OBJPROP_BACK,false);        // オブジェクトの背景表示設定
   ObjectSetInteger(0,c_objEtryName,OBJPROP_SELECTABLE,true);   // オブジェクトの選択可否設定
   ObjectSetInteger(0,c_objEtryName,OBJPROP_SELECTED,true);     // オブジェクトのアクティブ設定
   ObjectSetInteger(0,c_objEtryName, OBJPROP_HIDDEN, true);
}

void f_createText(){
   for(int i = 0; i < ArraySize(c_objDetails); i++){
      //c_objDetails
      ObjectCreate(c_objDetails[i], OBJ_LABEL,0, 0, 0);
      ObjectSet(c_objDetails[i], OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSet(c_objDetails[i], OBJPROP_XDISTANCE, 0);
      ObjectSet(c_objDetails[i], OBJPROP_YDISTANCE, 20 * i);
      ObjectSet(c_objDetails[i], OBJPROP_BACK, true);
      ObjectSet(c_objDetails[i], OBJPROP_SELECTABLE, false);
      ObjectSet(c_objDetails[i], OBJPROP_HIDDEN, true);
   }   
}
void f_calcPrm(){
   bool   flgDisp = true;
   string txtEquity = "";
   string txtPips = "";
   string txtNableLot = "";
   string txtMargin = "";

   // ロット計算
   flgDisp = f_calcDetails();

   // ラベル修正
   if(flgDisp){
      txtEquity   = "Equity:" + DoubleToString(g_strDtls.equity, 0) + "YEN";        //余剰証拠金
      txtPips     = DoubleToString(g_strDtls.pips, 1) + "pips";             //ピップス
      txtNableLot = DoubleToString(g_strDtls.nableLot, 2) + "Lot";                //ロット
      txtMargin   = DoubleToString(g_strDtls.margin ,0) + "YEN"; //証拠金
   }
   ObjectSetText(c_objDetails[0], txtEquity,   10, "Arial", clrPurple);
   ObjectSetText(c_objDetails[1], txtMargin,   10, "Arial", clrPurple);
   ObjectSetText(c_objDetails[2], txtPips,     10, "Arial", clrPurple);
   ObjectSetText(c_objDetails[3], txtNableLot, 10, "Arial", clrPurple);
}

bool f_calcDetails(){
   string cnvRateSymbol;
   double convVal;
   double margin;
   double lossPrice;
   double equity = (AccountBalance() / g_splitEquity);
   int calcValue = 0;
   int stopValue = int(g_stopValue * MathPow(10, Digits));
   int mode = MODE_BID;

   g_strDtls.equity = in_Equity;
   if(g_stopValue > Ask){//売エントリー時
      mode = MODE_BID;
      calcValue = int(Ask * MathPow(10, Digits));
   }
   else if(g_stopValue < Bid){//買エントリー時
      mode = MODE_ASK;
      calcValue = int(Bid * MathPow(10, Digits));
   }
   if((ObjectFind(c_objSLName) >= 0) && (ObjectFind(c_objEtryName) >= 0)){
      calcValue = int(g_entryValue * MathPow(10, Digits));
   }
   else if((ObjectFind(c_objSLName) >= 0) && (ObjectFind(c_objEtryName) < 0)){
      ;
   }
   else{
      return false;
   }

   cnvRateSymbol = StringConcatenate(StringSubstr(Symbol(), 3, 3), "JPY");//円換算レート取得
   convVal = MarketInfo(cnvRateSymbol, mode);
   if(StringSubstr(Symbol(), 3, 3) == "JPY")convVal = 1;
   //各種計算
   margin = (((Ask + Bid) / 2) * convVal * c_lotSize) / (double)c_leverage;//1Lotあたりの証拠金
   lossPrice = (MathAbs(stopValue - calcValue) * convVal * c_lotSize) / MathPow(10, Digits);//1Lotあたりの損失
   g_strDtls.nableLot = NormalizeDouble(g_strDtls.equity / (lossPrice + margin), 2);//建玉可能数
   g_strDtls.pips = NormalizeDouble(MathAbs(stopValue - calcValue) / 10.0, 1);//pips計算
   g_strDtls.margin = NormalizeDouble(margin * g_strDtls.nableLot, 0);

   return true;
}
