//+------------------------------------------------------------------+
//|                                      SpearmanRankCorrelation.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
// http://www.improvedoutcomes.com/docs/WebSiteDocs/Clustering/
// Clustering_Parameters/Spearman_Rank_Correlation_Distance_Metric.htm
// http://www.infamed.com/stat/s05.html
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_minimum  -1
#property indicator_maximum  1
extern int  range0 = 26;
extern int  range1 = 52;
//global
double IBrci0[];
double IBrci1[];
int  CalculatedBars = 0;
int init()
  {
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, IBrci0);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, IBrci1);
   if(CalculatedBars < 0) CalculatedBars = 0;
   f_drawLevels();
   return(0);
  }
int deinit(){
   return(0);
}
int start(){
   
   f_drawRCI(range0, IBrci0);
   f_drawRCI(range1, IBrci1);
   
   return(0);
}
void f_drawRCI(int range, double &IB[]){

   int    counted_bars = IndicatorCounted();
   int    i, k, limit;
   int    priceInt[];
   double multiply = MathPow(10, Digits);
   double Ranks[];
   
   if(counted_bars == 0){
      if(CalculatedBars == 0) limit = Bars - range;
      else limit = CalculatedBars;
   }
   if(counted_bars > 0) limit = Bars - counted_bars;
   
   ArrayResize(priceInt, range);
   ArrayResize(Ranks, range);
   for(i = limit; i >= 0; i--){
       for(k = 0; k < range; k++) 
           priceInt[k] = Close[i+k]*multiply;
       f_RankPrices(priceInt, range, Ranks);
       IB[i] = f_SpearmanRankCorrelation(Ranks,range);
   }
}
double f_SpearmanRankCorrelation(double Ranks[], int N){
   double res,z2;
   int i;
   for(i = 0; i < N; i++)
     {
       z2 += MathPow(Ranks[i] - i - 1, 2);
     }
   res = 1 - 6*z2 / (MathPow(N,3) - N);

   return(res);
}
void f_RankPrices(int InitialArray[], int range, double &Ranks[]){
   double dcounter, averageRank;
   double TrueRanks[];
   int    i, k, m, dublicat, counter, etalon;
   int    SortInt[];
   ArrayResize(TrueRanks, range);
   ArrayCopy(SortInt, InitialArray);
   ArraySort(SortInt, 0, 0, MODE_DESCEND);
   for(i = 0; i < range; i++) 
       TrueRanks[i] = i + 1;
   for(i = 0; i < range-1; i++)
     {
       if(SortInt[i] != SortInt[i+1]) 
           continue;
       dublicat = SortInt[i];
       k = i + 1;
       counter = 1;
       averageRank = i + 1;
       while(k < range)
         {
           if(SortInt[k] == dublicat)
             {
               counter++;
               averageRank += k + 1;
               k++;
             }
           else
               break;
         }
       dcounter = counter;
       averageRank = averageRank / dcounter;
       for(m = i; m < k; m++)
           TrueRanks[m] = averageRank;
       i = k;
     }
   for(i = 0; i < range; i++)
     {
       etalon = InitialArray[i];
       k = 0;
       while(k < range)
         {
           if(etalon == SortInt[k])
             {
               Ranks[i] = TrueRanks[k];
               break;
             }
           k++;
         }
     }
   return;
}

void f_drawLevels(){
    IndicatorSetInteger(INDICATOR_LEVELS,1);
    SetLevelValue(0,0.8);
    IndicatorSetInteger(INDICATOR_LEVELS,1);
    SetLevelValue(1,0.0);
    IndicatorSetInteger(INDICATOR_LEVELS,1);
    SetLevelValue(2,-0.8);
    SetLevelStyle(STYLE_DOT,1,clrBlue);
}