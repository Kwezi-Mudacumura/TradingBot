//+------------------------------------------------------------------+
//|                                                     standard.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <Trade/Trade.mqh>

//Trading package
CTrade trade;


//Initiate parameters of the moving averages
input int fastMA = 21;
input int mediumMA = 50;
input int slowMA = 200;
double stopLossPips = 10;
double takeProfitPips = 1;

int rsiHandle;
int maFast;
int maMedium;
int maSlow;

double bidPrice;
double askPrice;
bool GetSellSignal;
bool GetBuySignal;


//Stores the active ticket order number
ulong posTicket; 


int OnInit()
  {
    //Moving averages and RSI are calculated and initialized.

    maFast = iMA(_Symbol, PERIOD_CURRENT, fastMA, 0, MODE_SMA, PRICE_CLOSE);
    maMedium = iMA(_Symbol, PERIOD_CURRENT, mediumMA, 0, MODE_SMA, PRICE_CLOSE);
    maSlow = iMA(_Symbol, PERIOD_CURRENT, slowMA, 0, MODE_SMA, PRICE_CLOSE);

  /*
  int  iMA( 
   string               symbol,            // symbol name 
   ENUM_TIMEFRAMES      period,            // period 
   int                  ma_period,         // averaging period 
   int                  ma_shift,          // horizontal shift 
   ENUM_MA_METHOD       ma_method,         // smoothing type 
   ENUM_APPLIED_PRICE   applied_price      // type of price or handle 
   );
  */

    rsiHandle = iRSI(_Symbol, PERIOD_CURRENT,14,PRICE_CLOSE); //Work on this for closing trades;

   /*
   int  iRSI( 
   string              symbol,            // symbol name 
   ENUM_TIMEFRAMES     period,            // period 
   int                 ma_period,         // averaging period 
   ENUM_APPLIED_PRICE  applied_price      // type of price or handle 
   );
  */

    return(INIT_SUCCEEDED);
  }

//Helper function to check if the fast and medium moving averages are close within a specified pip range.
bool AreMovingAveragesClose(double ma1, double ma2, double pipRange)
{
    // Calculate the absolute difference in pips
    double diffPips = MathAbs((ma1 - ma2));

    // Check if the difference is within the specified pip range
    if (diffPips <= pipRange)
        return true;
    else
        return false;
}

/*  * Helper function to check for a specific entry signal
    * Checks if the previous 3 candlesticks are buy candles and if the current candlestick is a sell candles which is 30% the sum of the buy candles
*/
bool entrySignal(){

    double open=iOpen(_Symbol,PERIOD_CURRENT,1);
    double high=iHigh(_Symbol,PERIOD_CURRENT,1);
    double low=iLow(_Symbol,PERIOD_CURRENT,1);
    double close=iClose(_Symbol,PERIOD_CURRENT,1);
    double open2=iOpen(_Symbol,PERIOD_CURRENT,2);
    double high2=iHigh(_Symbol,PERIOD_CURRENT,2);
    double low2=iLow(_Symbol,PERIOD_CURRENT,2);
    double close2=iClose(_Symbol,PERIOD_CURRENT,2);
    double open3=iOpen(_Symbol,PERIOD_CURRENT,3);
    double high3=iHigh(_Symbol,PERIOD_CURRENT,3);
    double low3=iLow(_Symbol,PERIOD_CURRENT,3);
    double close3=iClose(_Symbol,PERIOD_CURRENT,3);
    double open4=iOpen(_Symbol,PERIOD_CURRENT,4);
    double high4=iHigh(_Symbol,PERIOD_CURRENT,4);
    double low4=iLow(_Symbol,PERIOD_CURRENT,4);
    double close4=iClose(_Symbol,PERIOD_CURRENT,4);


    double candleSize=open-close;
    double candleSize2=close2-open2;
    double candleSize3=close-open3;
    double candleSize4=close4-open4;

   // Calculate the combined size of the last three buy candles
    double combinedSize = candleSize2 + candleSize3 + candleSize4;

    // Check if the last three candles are buy candles
    bool areBuyCandles = (close2 > open2) && (close3 > open3) && (close4 > open4);

    // Check if the current candle is a sell candle
    bool isSellCandle = open > close;

    // Check if the current sell candle is 30% or larger than the combined size of the previous three buy candles
    bool isSignal = areBuyCandles && isSellCandle && ((open - close ) >= (0.3 * combinedSize));

    return isSignal;
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+



void OnDeinit(const int reason)
  {
//---
   
  }




void OnTick()
  {
    //Declare arrays to store rsi and moving average values on each tick
    double rsi[];
    double fMa[];
    double mMa[];
    double sMa[];

    //Store inidcator values in the array
    CopyBuffer(rsiHandle,0,1,1,rsi);
    CopyBuffer(maFast,0,1,1,fMa);
    CopyBuffer(maMedium,0,1,1,mMa);
    CopyBuffer(maSlow,0,1,1,sMa);


    bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    //If signal is detected  while the slow moving average is below the bid and askprice
    GetSellSignal = (entrySignal()) && (bidPrice > sMa[0]) && (askPrice > sMa[0]);
    //If signal is detected  while the slow moving average is above the bid and askprice
    GetBuySignal = (entrySignal()) && (bidPrice < sMa[0]) && (askPrice < sMa[0]);


    //Check if moving averages are close
    if (AreMovingAveragesClose(fMa[0], mMa[0], 2)) //Decide on a proper pip range
    {
        Print("Moving averages are close to each other!");
        //Essentially we do nothing here
    }
    else{
        Print("Moving averages are NOT close...");

        if(GetSellSignal){
          //Open one ticket at each given signal
           if (posTicket <= 0){
              trade.Sell(0.01,_Symbol,bidPrice,bidPrice + 3, bidPrice - 3);
              //Keep track of opened order
              posTicket = trade.ResultOrder();
            
          }
      }
      else if(GetBuySignal){
          //Open one ticket at each given signal
          if(posTicket <= 0){
            trade.Buy(0.01, _Symbol,askPrice,askPrice - 3, askPrice + 3);
            //Keep track of opened order
            posTicket  = trade.ResultOrder();
          }
        }
      //If there is no trade currently open, the tickect number is initialized to zero    
      else{
          posTicket = 0;
      }
    }
  }

