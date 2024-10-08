//+------------------------------------------------------------------+
//|                                                   RBDrawAlarm.mq4|
//|                         Copyright 2024, MetaQuotes Software Corp.|
//|                                              https://www.mql5.com|
//+------------------------------------------------------------------+
#property indicator_chart_window
#property strict

enum alarmSwitch{
  off,
  rsi,
  band,
  RorB,
  RandB,
};

// input parameter
input alarmSwitch in_alarmSwitch = RandB; // Alarm Switch
//// --Band Params--
input int in_bandsPeriod = 20;         // Bands Period
input double in_bandsDeviations = 2.0; // Bands Deviations
//// --RSI Params--
input int in_rsiPeriod = 14;     // RSI period
input double in_rsiUpper = 70.0; // RSI upper
input double in_rsiLower = 30.0; // RSI lower

// global
double g_rsiValue = 0.0;
double g_upperBand = 0.0;
double g_lowerBand = 0.0;
double g_middleBand = 0.0;
double g_priceClose = 0.0;
string g_now = "";
bool g_flg_rsiSellOrderReset = true, g_flg_rsiBuyOrderReset = true;
bool g_flg_bandSellOrderReset = true, g_flg_bandBuyOrderReset = true;

int OnInit(){
  return(INIT_SUCCEEDED);
}

void DeInit(){
}

void start()
{
  f_adjustCondition(); // Calculate RSI, Bollinger Bands and update global variables
 
  if(in_alarmSwitch == rsi){
    f_rsiAlarm();
  }
  else if(in_alarmSwitch == band){
    f_bandAlarm();
  }
  else if(in_alarmSwitch == RorB){
    f_rsiAlarm();
    f_bandAlarm();
  }
  else if(in_alarmSwitch == RandB){
    f_RandBAlarm();
  }else{
    ; // Alarm off
  }
}

void f_adjustCondition(){

  g_rsiValue = iRSI(NULL, 0, in_rsiPeriod, PRICE_CLOSE, 0);
  g_upperBand = iBands(Symbol(), 0, in_bandsPeriod, in_bandsDeviations, 0, PRICE_CLOSE, MODE_UPPER, 0);
  g_lowerBand = iBands(Symbol(), 0, in_bandsPeriod, in_bandsDeviations, 0, PRICE_CLOSE, MODE_LOWER, 0);
  g_middleBand = iBands(Symbol(), 0, in_bandsPeriod, in_bandsDeviations, 0, PRICE_CLOSE, MODE_MAIN, 0);
  g_priceClose = iClose(Symbol(), 0, 0);
  g_now = TimeToString(TimeCurrent() + (6 * 60 * 60), TIME_SECONDS);

  // Reset RSI flg
  if (g_rsiValue < 50)
    g_flg_rsiSellOrderReset = true;
  if (g_rsiValue > 50)
    g_flg_rsiBuyOrderReset = true;

  // Reset Band flg
  if (g_priceClose < g_middleBand)
    g_flg_bandSellOrderReset = true;
  if (g_priceClose > g_middleBand)
    g_flg_bandBuyOrderReset = true;
}

void f_rsiAlarm()
{
  if ((g_rsiValue >= in_rsiUpper) && (g_flg_rsiSellOrderReset)){
    g_flg_rsiSellOrderReset = false;
    SendNotification(g_now + ": RSI Over " + string(in_rsiUpper));
  }
  else if ((g_rsiValue <= in_rsiLower) && (g_flg_rsiBuyOrderReset)){
    g_flg_rsiBuyOrderReset = false;
    SendNotification(g_now + ": RSI Under " + string(in_rsiLower));
  }
}

void f_bandAlarm()
{
  if ((g_priceClose >= g_upperBand) && (g_flg_bandSellOrderReset)){
    SendNotification(g_now + ": Bands Over +" + string(in_bandsDeviations) + "σ");
    g_flg_bandSellOrderReset=false;
  }
  else if ((g_priceClose <= g_lowerBand) && (g_flg_bandBuyOrderReset)){
    SendNotification(g_now + ": Bands Under -" + string(in_bandsDeviations) + "σ");
    g_flg_bandBuyOrderReset=false;
  }
}

void f_RandBAlarm()
{
  if ((g_rsiValue >= in_rsiUpper) && (g_priceClose >= g_upperBand)
  && (g_flg_rsiSellOrderReset && g_flg_bandSellOrderReset)){
    g_flg_rsiSellOrderReset = false;
    g_flg_bandSellOrderReset = false;
    SendNotification(g_now + ": RandB Over " + string(in_rsiUpper) + " " + string(in_bandsDeviations) + "σ");
  }
  else if ((g_rsiValue <= in_rsiLower) && (g_priceClose <= g_lowerBand)
  && (g_flg_rsiBuyOrderReset && g_flg_bandBuyOrderReset)){
    g_flg_rsiBuyOrderReset = false; 
    g_flg_bandBuyOrderReset = false;
    SendNotification(g_now + ": RandB Under " + string(in_rsiLower)+ " " + string(in_bandsDeviations) + "σ");
  }
}