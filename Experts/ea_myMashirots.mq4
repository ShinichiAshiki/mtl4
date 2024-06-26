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
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
//define
#define DIALOG_CLM    (2) //ダイアログ内の列数
#define DIALOG_ROW    (7) //ダイアログ内の行数
#define INDENT_X      (10)//dialogX座標
#define INDENT_Y      (20)//dialogY座標
#define DIALOG_WIDTH  (INDENT_X + 180)
#define DIALOG_HEIGHT (INDENT_Y + 240)
#define WIDTH         ((DIALOG_WIDTH - INDENT_X - 10) / DIALOG_CLM)
#define HEIGHT        ((DIALOG_HEIGHT - INDENT_Y - 30) / DIALOG_ROW)//1行あたりの高さ
#define OP_DUMMY      ((int)999999)
#define DBL_DUMMY_NUM (999.999)
//定数
input double c_splitEquity = 3.0;//証拠金の任意分割
const string c_objSLName       = "stopLine";
const string c_BtnStopLine     = "btnStopLine";
const string c_BtnOrderAll     = "btnOrderAll";
const string c_BtnOrderHalf    = "btnOrderHalf";
const string c_BtnOrderQuarter = "btnOrderQuarter";
const string c_BtnAllClose     = "btnAllClose";
const string c_BtnReset        = "btnReset";
const int    c_leverage = AccountLeverage();
const int    c_lotSize = (int)MarketInfo(Symbol(),MODE_LOTSIZE);//1lot辺りの通貨数
const int    c_slipage = 20;//許容スリップ幅
//グローバル変数
double g_stopValue = 0.0;
double g_nableLots = DBL_DUMMY_NUM;
double g_entryRate = DBL_DUMMY_NUM;
double g_equity = (AccountEquity() / c_splitEquity);
int    g_orderType = OP_DUMMY;

CAppDialog dialog;
CButton    btnStopLine;
CButton    btnOrdrAll;
CButton    btnOrdrHalf;
CButton    btnOrdrQuarter;
CButton    btnAllClose;
CButton    btnReset;
CLabel     lblEquity;
CLabel     lblLots;
CLabel     lblMargin;
CLabel     lblPips;
int OnInit()
{
   datetime getTime;
   int windowNo;
   color clrEntry = clrDeepPink;
   color clrStopLine = clrViolet;
   color clrReset = clrPowderBlue;
   
   ChartXYToTimePrice(ChartID(), 0, 50, windowNo, getTime, g_stopValue);
   //ダイアログ表示
   dialog.Create(0, "OrderForm", 0, INDENT_X, INDENT_Y, DIALOG_WIDTH, DIALOG_HEIGHT);
   dialog.Run();
   //Label equity
   lblEquity.Create(0, "equity", 0, WIDTH * 0, HEIGHT * 0, WIDTH * 1, HEIGHT * 1);
   lblEquity.Text("-");
   dialog.Add(lblEquity);
   //Label margin
   lblMargin.Create(0, "margin", 0, WIDTH * 0, HEIGHT * 1, WIDTH * 2, HEIGHT * 1);
   lblMargin.Text("-");
   dialog.Add(lblMargin);
   //Label lots
   lblLots.Create(0, "nablelot", 0, WIDTH * 1, HEIGHT * 0, WIDTH * 1, HEIGHT * 2);
   lblLots.Text("-");
   dialog.Add(lblLots);
   //Label pips
   lblPips.Create(0, "pips", 0, WIDTH * 1, HEIGHT * 1, WIDTH * 2, HEIGHT * 2);
   lblPips.Text("-");
   dialog.Add(lblPips);
   //Button all Lots
   btnOrdrAll.Create(0, c_BtnOrderAll, 0, WIDTH * 0, HEIGHT * 2, WIDTH * 2, HEIGHT * 3);
   btnOrdrAll.Text("All Lot");
   btnOrdrAll.ColorBackground(clrEntry);
   dialog.Add(btnOrdrAll);
   //Button half Lots
   btnOrdrHalf.Create(0, c_BtnOrderHalf, 0, WIDTH * 0, HEIGHT * 3, WIDTH * 1, HEIGHT * 4);
   btnOrdrHalf.Text("1/2");
   btnOrdrHalf.ColorBackground(clrEntry);
   dialog.Add(btnOrdrHalf);
   //Button Quarter Lots
   btnOrdrQuarter.Create(0, c_BtnOrderQuarter, 0, WIDTH * 1, HEIGHT * 3, WIDTH * 2, HEIGHT * 4);
   btnOrdrQuarter.Text("1/4");
   btnOrdrQuarter.ColorBackground(clrEntry);
   dialog.Add(btnOrdrQuarter);
   //Button All Close
   btnAllClose.Create(0, c_BtnAllClose, 0, WIDTH * 0, HEIGHT * 4, WIDTH * 2, HEIGHT * 5);
   btnAllClose.Text("All Close");
   dialog.Add(btnAllClose);
   //Button StopLine
   btnStopLine.Create(0, c_BtnStopLine, 0, WIDTH * 0, HEIGHT * 5, WIDTH * 2, HEIGHT * 6);
   btnStopLine.Text("Stop Line");
   btnStopLine.ColorBackground(clrStopLine);
   dialog.Add(btnStopLine);
   //Button Reset Equity
   btnReset.Create(0, c_BtnReset, 0, WIDTH * 0, HEIGHT * 6, WIDTH * 2, HEIGHT * 7);
   btnReset.Text("Reset");
   btnReset.ColorBackground(clrReset);
   dialog.Add(btnReset);
   Comment("");
   return(INIT_SUCCEEDED);
}
  
void deinit()
{
   if(ObjectFind(c_objSLName) != -1)ObjectDelete(c_objSLName);
   dialog.Destroy();
}  

void OnTick(){
   f_clcPrm();
}

void OnChartEvent(
                 const int     id,      // イベントID
                 const long&   lparam,  // long型イベント
                 const double& dparam,  // double型イベント
                 const string& sparam)  // string型イベント
{
   int resOrderTckt = 1;
   int division = -1;
   int i;
   bool flgTmp;
   
   dialog.ChartEvent(id,lparam,dparam,sparam);
   if(id == CHARTEVENT_OBJECT_DELETE){
      if(sparam == c_objSLName){
         g_orderType = OP_DUMMY;
         g_entryRate = DBL_DUMMY_NUM;
         g_nableLots = 0.0;
         lblEquity.Text("-");
         lblMargin.Text("-");
         lblLots.Text("-");
         lblPips.Text("-");
      }
   }
   else if(id == CHARTEVENT_OBJECT_DRAG){
      if(sparam == c_objSLName){//オブジェクトの移動
         g_stopValue = ObjectGet(c_objSLName, OBJPROP_PRICE1);//ストップロス価格の変更
         f_clcPrm();
      }
   }
   else if(id == CHARTEVENT_OBJECT_CLICK){
      division = -1;
      if(sparam == c_BtnStopLine){//SLラインボタン押下
         if(ObjectFind(c_objSLName) == -1){//消えてたら再描画
            f_drawStpLine();
            f_clcPrm();
         }
         else{
            ObjectDelete(c_objSLName);
         }
      }
      else if(sparam == c_BtnReset){//Resetボタン押下
         g_equity = (AccountEquity() / c_splitEquity);
      }
      //エントリーボタン押下
      else if(sparam == c_BtnOrderAll){
         division = 1;
      }
      else if(sparam == c_BtnOrderHalf){
         division = 2;
      }
      else if(sparam == c_BtnOrderQuarter){
         division = 4;
      }
      else if(sparam == c_BtnAllClose){//Closeボタン.全保有尾ポジション決済
         for(i = OrdersTotal() - 1; i >= 0; i--){
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
               flgTmp = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 50, clrNONE);
            }
         }
      }
      if(division >= 1){
         resOrderTckt = OrderSend(Symbol(), g_orderType, g_nableLots / division, g_entryRate, c_slipage, 0, 0, "Cmnt", 2525333);
         if(resOrderTckt > 0){//エントリーできたとき
            g_equity = g_equity - g_equity / division;//計算用証拠金更新
            if(division == 1) g_equity = 0;
         }
         f_clcPrm();
      }
   }
}

void f_drawStpLine(){
   //SLライン
   ObjectCreate(0, c_objSLName, OBJ_HLINE, 0, 0, g_stopValue);//ストップロスライン生成
   ObjectSetInteger(0,c_objSLName,OBJPROP_COLOR,clrMagenta);
   ObjectSetInteger(0,c_objSLName,OBJPROP_STYLE,STYLE_SOLID); // ラインのスタイル設定
   ObjectSetInteger(0,c_objSLName,OBJPROP_BACK,false);        // オブジェクトの背景表示設定
   ObjectSetInteger(0,c_objSLName,OBJPROP_SELECTABLE,true);   // オブジェクトの選択可否設定
   ObjectSetInteger(0,c_objSLName,OBJPROP_SELECTED,false);     // オブジェクトのアクティブ設定
}
void f_clcPrm(){
   
   double nableLots = 0.0;
   double pips = 0.0;
   double margin = 0.0;//証拠金
   double lossPrice;
   double convVal;
   double clcVal = 0.0;
   string cnvRateSymbol;
   int    mode = 0;
   int    numArry = 0;
   bool   flgDisp = true;
   
   //lot計算
   if(g_equity > 0){//証拠金がある時
      if(g_stopValue > Ask){//売エントリー時
         mode = MODE_BID;
         clcVal = Ask;
         g_orderType = OP_SELL;
         g_entryRate = Bid;
      }
      else if(g_stopValue < Bid){//買エントリー字時
         mode = MODE_ASK;
         clcVal = Bid;
         g_orderType = OP_BUY;
         g_entryRate = Ask;
      }
   }   
   else{
      flgDisp = false;
      g_orderType = OP_DUMMY;
      g_entryRate = DBL_DUMMY_NUM;
      g_nableLots = 0.0;
   }
   //ロット計算、ラベル修正
   if(flgDisp && (ObjectFind(c_objSLName) >= 0)){
      cnvRateSymbol = StringConcatenate(StringSubstr(Symbol(), 3, 3), "JPY");//円換算レート取得
      convVal = MarketInfo(cnvRateSymbol,mode);
      if(StringSubstr(Symbol(), 3, 3) == "JPY")convVal = 1;
      //各種計算
      margin = (((Ask + Bid) / 2) * convVal * c_lotSize) / (double)c_leverage;//1Lotあたりの証拠金
      lossPrice = MathAbs(g_stopValue - clcVal) * convVal * c_lotSize;//1Lotあたりの損失
      g_nableLots = g_equity / ( lossPrice + margin );//建玉可能数
      g_nableLots = NormalizeDouble(g_nableLots - 0.005,2);
      pips = MathAbs(g_stopValue - clcVal) * MathPow(10, Digits - 1);//pips計算
      lblEquity.Text(StringConcatenate(DoubleToString(g_equity,0), "YEN"));//余剰証拠金
      lblPips.Text(StringConcatenate(DoubleToString(pips - 0.05, 1), "pips"));//ピップス
      lblLots.Text(StringConcatenate(DoubleToString(g_nableLots, 2), "Lot"));//ロット
      lblMargin.Text(StringConcatenate(DoubleToString( margin * g_nableLots - 0.5 ,0), "YEN"));//証拠金
   }
   else{
      lblEquity.Text("-");
      lblMargin.Text("-");
      lblLots.Text("-");
      lblPips.Text("-");
   }
}
