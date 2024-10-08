//+------------------------------------------------------------------+
//|                                                       sftCrt.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#define BTN_SHIFT (16)
#define BTN_CTRL  (17)
#define BTN_DMMY  (9999)
const string c_objName = "objShiftLine";
const string c_thisIndName = "myShiftChart";
long   g_btnSwtch = BTN_DMMY;

int OnInit(){
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   ObjectDelete(c_objName);
}

void OnChartEvent(
                 const int     id,      // イベントID
                 const long&   lparam,  // long型イベント
                 const double& dparam,  // double型イベント
                 const string& sparam)  // string型イベント
{
   datetime movedObjTime;
   datetime get_time;
   double get_price;
   int window_no;
   
   if(id == CHARTEVENT_KEYDOWN){
      if(lparam == BTN_SHIFT)g_btnSwtch = BTN_SHIFT;
      else if(lparam == BTN_CTRL)g_btnSwtch = BTN_CTRL;
      else g_btnSwtch = BTN_DMMY;
   }
   else if(id == CHARTEVENT_CLICK){
      if(g_btnSwtch == BTN_SHIFT){
         ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, window_no, get_time, get_price);
         f_drawObj(get_time);
         g_btnSwtch = BTN_DMMY;
      }
      else if(g_btnSwtch == BTN_CTRL){
         f_deltObj();
         g_btnSwtch = BTN_DMMY;
      }
   }
   else if((id == CHARTEVENT_OBJECT_DRAG) && (sparam == c_objName)){//オブジェクトの移動イベント
      movedObjTime = (datetime)ObjectGet(c_objName, OBJPROP_TIME1);//動かされた時間取得
      f_drawObj(movedObjTime);
   }
   else{
      g_btnSwtch = BTN_DMMY;
   }
}

void f_drawObj(datetime tgtShiftTime){
   long cID;
   int shift, i;
   bool flgTgtWindow = False;
   
   for(cID = ChartFirst(); cID >= 0; cID = ChartNext(cID)){//表示されているウィンドウ分ループ
      flgTgtWindow = False;
      for(i = 0; i < ChartIndicatorsTotal(cID, 0); i++){
         if(c_thisIndName == ChartIndicatorName(cID, 0, i)){
            flgTgtWindow = True;
            break;
         }  
      }
      if(flgTgtWindow){
         if(ObjectFind(cID, c_objName) != -1){//c_objNameが描画済み
            ObjectMove(cID, c_objName, 0, tgtShiftTime, 0);
         }
         else{
            ObjectCreate(cID, c_objName, OBJ_VLINE, 0, tgtShiftTime, 0 );
            ObjectSetInteger(cID, c_objName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(cID, c_objName, OBJPROP_BACK, false);
         }
         if(cID != ChartID()){//クリックしたチャート以外のチャートに対して
         }
            shift = iBarShift(Symbol(), ChartPeriod(cID), tgtShiftTime, False);
            ChartNavigate(cID, CHART_END, shift*(-1) + 10);
      }
   }
}

void f_deltObj(){
   long cID;
   for(cID = ChartFirst(); cID >= 0; cID = ChartNext(cID)){
      ObjectDelete(cID, c_objName);
   }
}
void start(){
}