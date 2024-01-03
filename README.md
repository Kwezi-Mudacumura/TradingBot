# TradingBot
<p>
  The following program uses a trading algorithm written in MQL5, a programming language used for developing trading strategies in MetaTrader 5. Let's break down the main components and strategy employed in this code:
<ul>
<li><h2>1. Initialization:</h2></li></br>
   - Moving averages (fast, medium, slow) and RSI (Relative Strength Index) values are calculated in the `OnInit` function.</br>
   - Parameters for moving averages, stop loss, and take profit are defined.

<li><h2>2. Entry Signal:</h2></li></br>
   - The `entrySignal` function checks for a specific entry signal based on candlestick patterns. It looks for the last three candles to be buy candles and the current candle to be a sell candle with a size at least 30% larger than the combined size of the previous three buy candles.

<li><h2>3. Checking Moving Averages:</h2></li></br>
   - The function `AreMovingAveragesClose` is used to check if the fast and medium moving averages are close within a specified pip range (2 pips in this case).

<li><h2>4. OnTick Function:</h2></li></br>
   - The main trading logic is implemented in the `OnTick` function, which is executed on every tick.</br>
   - RSI and moving average values are stored in arrays using `CopyBuffer`.</br>
   - Buy and sell signals are generated based on the entry conditions, moving average positions, and bid/ask prices.</br>
   - If the fast and medium moving averages are not close, and a sell signal is present while the slow moving average is above the bid and ask prices, a sell order is placed.</br>
   - If the fast and medium moving averages are not close, and a buy signal is present while the slow moving average is below the bid and ask prices, a buy order is placed.</br>
   - The `Trade` class is used for executing trades with specified volumes and price levels.

<li><h2>5. Deinitialization:</h2></li></br>
   - The `OnDeinit` function is empty in this code.

<li><h2>6. Position Tracking:</h2></li></br>
   - The variable `posTicket` is used to store the active ticket order number. It is initialized to zero and updated whenever a trade is executed.
     </ul>

Overall, the strategy  relies on a combination of moving average positions, RSI, and candlestick patterns to generate buy and sell signals. It also incorporates checks to ensure that the fast and medium moving averages are not too close to each other before making a trading decision. It's important to note that trading strategies involve risk, and thorough testing and analysis are recommended before deploying them in a live trading environment.</br></br>
Please note I am merely a novice in trading and MQL5 so this is still an ongoing project.
</p>
