//+------------------------------------------------------------------+
//|                                                    my_Seiryu v2.0|
//|                                                   Shinichi Ashiki|
//|                                                                  |
//+------------------------------------------------------------------+
// Remaining issues
// ・stop EA from my smartphone
// ・make all payments somehow

#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link "https://www.mql4.com"
#property version "1.00"
#property strict
#property indicator_chart_window
#define MAGIC_NUMBER 123456

// input parameter
input int in_tpPip = 8;             // 1段利確幅
input int in_maxNampinCnt = 50;     // ナンピンの最大回数
input int in_nanpinPip = 18;        // ナンピン幅(pips)
input double in_nanpinMagnif = 1.6; // ナンピン倍率
input int in_nanpinInterval = 4;    // ナンピンインターバル(分)
input double in_lotSize = 0.02;     // RSI自動エントリー時ロットサイズ
input int in_rsiOverbought = 70;    // RSI上値
input int in_rsiOversold = 30;      // RSI下値
input int in_rsiPeriod = 14;        // RSI期間

// global
int g_latestTicket = -1;   // 最新のポジションチケット番号
double g_initialSL = -1.1; // 最初のSL
double g_totalLoss = 0.0;  // for strategy tester

int OnInit()
{
    return (INIT_SUCCEEDED);
}

void OnTick()
{

    f_checkBaseOrder();

    if (OrdersTotal() == 0)
    {
        f_entryByRSI(); // Entry by RSI
    }
    else if (OrdersTotal() == 1)
    {
        f_checkSlTpSetting();
        f_calcAveraging(); // Check whether to averaging(nanping)
    }
    else if (OrdersTotal() >= 2)
    {
        f_closeAllPositions(); // Check whether to close all positions
        f_calcAveraging();     // Check whether to averaging(nanping)
    }
}

// Check the base position for averaging
void f_checkBaseOrder()
{
    double openPriceBuy = 99999.9, openPriceSell = -1.1;
    double totalProfit = 0.0; // for strategy tester

    if (OrdersTotal() == 0)
    {
        g_initialSL = -1.1;
        g_latestTicket = -1;
    }
    else
    {
        if (OrderSelect(0, SELECT_BY_POS, MODE_TRADES)) // Get SL of the oldest position
        {
            g_initialSL = OrderStopLoss();
        }

        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if ((OrderType() == OP_BUY) && (OrderOpenPrice() < openPriceBuy))
                {
                    g_latestTicket = OrderTicket();
                    openPriceBuy = OrderOpenPrice();
                }
                else if ((OrderType() == OP_SELL) && (OrderOpenPrice() > openPriceSell))
                {
                    g_latestTicket = OrderTicket();
                    openPriceSell = OrderOpenPrice();
                }
            }
            // ↓for strategy tester↓
            totalProfit += OrderProfit();
            if (MathAbs(totalProfit) > MathAbs(g_totalLoss))
            {
                g_totalLoss = totalProfit;
            }
            // ↑for strategy tester↑
        }
        // ↓for strategy tester↓
        Comment("totalProfit: ", totalProfit); // Calculation floating Profit/Loss
        // ↑for strategy tester↑
    }
}

void f_entryByRSI()
{
    double rsiValue = iRSI(NULL, 0, in_rsiPeriod, PRICE_CLOSE, 0);
    double sl = 0.0, tp = 0.0;
    static bool s_flg_sellOrderReset = false, s_flg_buyOrderReset = false;

    if (rsiValue < 50)
        s_flg_sellOrderReset = true;
    if (rsiValue > 50)
        s_flg_buyOrderReset = true;
    if ((rsiValue >= in_rsiOverbought) && (s_flg_sellOrderReset)) // If the RSI is above parameter, enter a sell
    {
        sl = Bid + (in_nanpinPip * (in_maxNampinCnt + 1) * 10 * Point);
        tp = Bid - in_tpPip * 10 * Point;
        int ticket = OrderSend(Symbol(), OP_SELL, in_lotSize, Bid, 2, sl, tp, "Sell Order", MAGIC_NUMBER, 0, Red);
        if (ticket < 0)
        {
            Print("Sell Order Failed: ", GetLastError());
        }
        else
        {
            Print("Sell Order Placed at Bid: ", Bid, " ticket: ", ticket, " sl: ", sl, " tp: ", tp);
            s_flg_sellOrderReset = false;
        }
    }
    else if ((rsiValue <= in_rsiOversold) && (s_flg_buyOrderReset)) // If the RSI is under parameter, enter a buy
    {
        sl = Ask - (in_nanpinPip * (in_maxNampinCnt + 1) * 10 * Point);
        tp = Ask + in_tpPip * 10 * Point;
        int ticket = OrderSend(Symbol(), OP_BUY, in_lotSize, Ask, 2, sl, tp, "Buy Order", MAGIC_NUMBER, 0, Blue);
        if (ticket < 0)
        {
            Print("Buy Order Failed: ", GetLastError());
        }
        else
        {
            Print("Buy Order Placed at Ask: ", Ask, " ticket: ", ticket, " sl: ", sl, " tp: ", tp);
            s_flg_buyOrderReset = false;
        }
    }
}

void f_checkSlTpSetting()
{
    if (OrderSelect(0, SELECT_BY_POS, MODE_TRADES)) // oldest position
    {
        double expectedSl = 0.0, expectedTp = 0.0;

        if (OrderType() == OP_SELL)
        {
            expectedSl = OrderOpenPrice() + (in_nanpinPip * (in_maxNampinCnt + 1) * 10 * Point);
            expectedTp = OrderOpenPrice() - in_tpPip * 10 * Point;
        }
        else if (OrderType() == OP_BUY)
        {
            expectedSl = OrderOpenPrice() - (in_nanpinPip * (in_maxNampinCnt + 1) * 10 * Point);
            expectedTp = OrderOpenPrice() + in_tpPip * 10 * Point;
        }

        // Check SL/TP
        if ((OrderTakeProfit() == 0 || OrderStopLoss() == 0) &&
            (OrderTakeProfit() != expectedTp || OrderStopLoss() != expectedSl))
        {
            if (OrderModify(OrderTicket(), OrderOpenPrice(), expectedSl, expectedTp, 0, clrNONE))
            {
                Print("TP and SL updated: Ticket ", OrderTicket(), " TP: ", expectedTp, " SL: ", expectedSl);
            }
            else
            {
                Print("Failed to modify TP and SL: Ticket ", OrderTicket(), " Error: ", GetLastError());
            }
        }
    }
}

void f_calcAveraging()
{
    // Calculation averaging
    if ((OrdersTotal() > 0) &&
        OrderSelect(g_latestTicket, SELECT_BY_TICKET) &&
        (OrderType() == OP_BUY || OrderType() == OP_SELL))
    {
        double currentPrice = (OrderType() == OP_BUY) ? Ask : Bid;

        // Check if the price has reversed "in_nanpinPip"
        if (((OrderType() == OP_BUY) && (currentPrice <= OrderOpenPrice() - in_nanpinPip * 10 * Point)) ||
            ((OrderType() == OP_SELL) && (currentPrice >= OrderOpenPrice() + in_nanpinPip * 10 * Point)))
        {
            // Check condition of averaging
            if (((OrdersTotal() - 1) < in_maxNampinCnt) &&
                (TimeCurrent() >= OrderOpenTime() + (in_nanpinInterval * 60)))
            {
                double newLots = OrderLots() * in_nanpinMagnif;

                // averaging order
                if (OrderType() == OP_BUY)
                {
                    if (OrderSend(Symbol(), OP_BUY, newLots, Ask, 3, g_initialSL, 0, "", 0, 0, Blue) < 0)
                    {
                        Print("BUY order Failed: ", GetLastError());
                    }
                }
                else if (OrderType() == OP_SELL)
                {
                    if (OrderSend(Symbol(), OP_SELL, newLots, Bid, 3, g_initialSL, 0, "", 0, 0, Red) < 0)
                    {
                        Print("SELL order Failed: ", GetLastError());
                    }
                }

                // Cancellation TP
                for (int i = OrdersTotal() - 1; i >= 0; i--)
                {
                    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                    {
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), g_initialSL, 0, 0, clrNONE))
                        {
                            Print("OrderModify failed: ", GetLastError());
                        }
                    }
                }
            }
        }
    }
}

void f_closeAllPositions()
{
    double totalLots = 0;
    double totalOpenPrice = 0.0;
    double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            totalLots += OrderLots();
            totalOpenPrice += OrderOpenPrice() * OrderLots();
        }
    }

    double breakevenPrice = totalOpenPrice / totalLots;
    double targetPrice = (OrderType() == OP_BUY) ? breakevenPrice + in_tpPip * 10 * Point : breakevenPrice - in_tpPip * 10 * Point;

    if ((OrderType() == OP_BUY && currentPrice >= targetPrice) ||
        (OrderType() == OP_SELL && currentPrice <= targetPrice))
    {
        // Close all positions
        for (int j = OrdersTotal() - 1; j >= 0; j--)
        {
            if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
            {
                if (OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, clrGreen))
                    Print("Order Close Failed: ", GetLastError());
            }
        }
        Print("total Profit: ", g_totalLoss, g_latestTicket);
        g_totalLoss = 0.0;
    }
}
