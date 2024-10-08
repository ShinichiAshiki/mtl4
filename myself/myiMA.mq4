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
#property  indicator_buffers 5

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

double IBma0[];//IndicatorBuffer
double IBma1[];
double IBma2[];
double IBma3[];
double IBma4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,MAclr0);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,MAclr1);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,MAclr2);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,3,MAclr3);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,3,MAclr4);
   SetIndexBuffer(0,IBma0);
   SetIndexBuffer(1,IBma1);
   SetIndexBuffer(2,IBma2);
   SetIndexBuffer(3,IBma3);
   SetIndexBuffer(4,IBma4);
   return(INIT_SUCCEEDED);
}
  
int start (){
   int limit = Bars - IndicatorCounted();
   int i;
   for(i = limit - 1; i > 0; i--){
      //移動平均線描画
      IBma0[i] = iMA(NULL,PERIOD_CURRENT,MAterm0,0,MODE_SMA,PRICE_MEDIAN,i);
      IBma1[i] = iMA(NULL,PERIOD_CURRENT,MAterm1,0,MODE_SMA,PRICE_MEDIAN,i);
      IBma2[i] = iMA(NULL,PERIOD_CURRENT,MAterm2,0,MODE_SMA,PRICE_MEDIAN,i);
      IBma3[i] = iMA(NULL,PERIOD_CURRENT,MAterm3,0,MODE_SMA,PRICE_MEDIAN,i);
      IBma4[i] = iMA(NULL,PERIOD_CURRENT,MAterm4,0,MODE_SMA,PRICE_MEDIAN,i);
   }
   
   return(0);
}
