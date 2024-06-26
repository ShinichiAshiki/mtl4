//+------------------------------------------------------------------+
//|                                                          iMA.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 8

input int   MAterm0 = 25;
input int   MAterm1 = 75;
input int   MAterm2 = 200;
input int   MAterm3 = 0;
input int   MAterm4 = 0;
input color MAclr0 = Red;
input color MAclr1 = Blue;
input color MAclr2 = Green;
input color MAclr3 = DarkGreen;
input color MAclr4 = MediumBlue;
const int c_myiMA[3] = {25, 75, 200};
const int c_defPeriods[10] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1, 0};
const string c_objBtn[10] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1", "DEL"};
double IBma0[];//IndicatorBuffer
double IBma1[];
double IBma2[];
double IBma3[];
double IBma4[];
double IBma5[];
double IBma6[];
double IBma7[];
int g_viweiMA[3] = {0, 0, 0};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   
   f_creatBtns();
   //set buffer
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,MAclr0);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,MAclr1);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,MAclr2);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,3,MAclr3);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,3,MAclr4);
   SetIndexStyle(5,DRAW_LINE,STYLE_DASH,1,MAclr0);
   SetIndexStyle(6,DRAW_LINE,STYLE_DASH,1,MAclr1);
   SetIndexStyle(7,DRAW_LINE,STYLE_DASH,1,MAclr2);
   SetIndexBuffer(0,IBma0);
   SetIndexBuffer(1,IBma1);
   SetIndexBuffer(2,IBma2);
   SetIndexBuffer(3,IBma3);
   SetIndexBuffer(4,IBma4);
   SetIndexBuffer(5,IBma5);
   SetIndexBuffer(6,IBma6);
   SetIndexBuffer(7,IBma7);
   return(INIT_SUCCEEDED);
}
void deinit(){
   int i;
   //ボタン削除
   for(i = 0; i < ArraySize(c_objBtn); i++){
      ObjectDelete(c_objBtn[i]);
   }
}
void start (){
   int limit = Bars - IndicatorCounted();
   int i;
   int applied_price = PRICE_CLOSE;
   for(i = limit - 1; i > 0; i--){
      //移動平均線描画
      IBma0[i] = iMA(NULL,PERIOD_CURRENT,MAterm0,0,MODE_SMA,applied_price,i);
      IBma1[i] = iMA(NULL,PERIOD_CURRENT,MAterm1,0,MODE_SMA,applied_price,i);
      IBma2[i] = iMA(NULL,PERIOD_CURRENT,MAterm2,0,MODE_SMA,applied_price,i);
      IBma3[i] = iMA(NULL,PERIOD_CURRENT,MAterm3,0,MODE_SMA,applied_price,i);
      IBma4[i] = iMA(NULL,PERIOD_CURRENT,MAterm4,0,MODE_SMA,applied_price,i);
      IBma5[i] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[0],0,MODE_SMA,applied_price,i);
      IBma6[i] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[1],0,MODE_SMA,applied_price,i);
      IBma7[i] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[2],0,MODE_SMA,applied_price,i);
   }
   //移動平均線描画
   IBma0[0] = iMA(NULL,PERIOD_CURRENT,MAterm0,0,MODE_SMA,applied_price,0);
   IBma1[0] = iMA(NULL,PERIOD_CURRENT,MAterm1,0,MODE_SMA,applied_price,0);
   IBma2[0] = iMA(NULL,PERIOD_CURRENT,MAterm2,0,MODE_SMA,applied_price,0);
   IBma3[0] = iMA(NULL,PERIOD_CURRENT,MAterm3,0,MODE_SMA,applied_price,0);
   IBma4[0] = iMA(NULL,PERIOD_CURRENT,MAterm4,0,MODE_SMA,applied_price,0);
   IBma5[0] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[0],0,MODE_SMA,applied_price,0);
   IBma6[0] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[1],0,MODE_SMA,applied_price,0);
   IBma7[0] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[2],0,MODE_SMA,applied_price,0);
}
void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam){
   int i, j;
   
   if(id == CHARTEVENT_OBJECT_CLICK){
      for(i = 0; i < ArraySize(c_objBtn); i++){
         if(sparam == c_objBtn[i]){
            ObjectSetInteger(ChartID(), c_objBtn[i], OBJPROP_STATE, 0);
            for(j = 0; j < ArraySize(c_myiMA); j++){
               g_viweiMA[j] = c_defPeriods[i] * c_myiMA[j] / Period();
            }
            f_drawiMA();
            break;
         }
      }
   }   
}

void f_drawiMA(){
   int i;
   //移動平均線描画
   for(i = IndicatorCounted(); i > 0; i--){ 
      IBma5[i] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[0],0,MODE_SMA,PRICE_MEDIAN,i);
      IBma6[i] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[1],0,MODE_SMA,PRICE_MEDIAN,i);
      IBma7[i] = iMA(NULL,PERIOD_CURRENT,g_viweiMA[2],0,MODE_SMA,PRICE_MEDIAN,i);
   }
}

void f_creatBtns(){
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
      ObjectSetString(0,c_objBtn[i],OBJPROP_TEXT,c_objBtn[i]);        //ボタンテキスト
   }
}