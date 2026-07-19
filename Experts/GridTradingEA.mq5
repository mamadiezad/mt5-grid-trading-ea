//+------------------------------------------------------------------+
//| GridTradingEA.mq5 - Grid Trading Expert Advisor for MetaTrader 5  |
//| https://github.com/mamadiezad/mt5-grid-trading-ea                 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, mamadiezad"
#property link      "https://github.com/mamadiezad"
#property version   "1.00"
#property description "Grid Trading Expert Advisor for MT5"
#property description "Places buy stop & sell stop orders in a grid pattern"

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/AccountInfo.mqh>

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+
input group "Grid Settings"
input int      GridOrdersPerSide   = 5;       // Orders per side
input double   GridStepPoints      = 50;      // Grid step (points)
input double   GridVolume          = 0.01;    // Volume per order (lots)
input double   GridMultiplier      = 1.0;     // Volume multiplier per level
input double   GridSpread         = 20;      // First order offset (points)

input group "Trailing Stop"
input bool     UseTrailing         = true;    // Enable trailing
input double   TrailStart          = 100;     // Activation (points)
input double   TrailStep           = 30;      // Step (points)

input group "Risk Management"
input int      MagicNumber         = 202401;  // EA ID
input double   MaxSpread           = 50;      // Max spread allowed
input bool     CloseOnProfit       = true;    // Close at total profit
input double   TotalProfitTarget   = 50.0;    // Profit target
input double   TotalLossLimit      = -100.0;  // Loss limit
input int      MaxPositions        = 20;      // Max total positions

input group "Grid Behavior"
input bool     HedgeMode           = false;   // Both sides active
input bool     AutoRebuild         = true;    // Auto rebuild grid

//+------------------------------------------------------------------+
//| GLOBALS                                                          |
//+------------------------------------------------------------------+
CTrade         trade;
CPositionInfo  position;
COrderInfo     order;
CSymbolInfo    symbol;
CAccountInfo   account;
datetime       lastAction;

//+------------------------------------------------------------------+
//| INIT                                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   symbol.Name(_Symbol);
   symbol.Refresh();

   if(GridOrdersPerSide <= 0 || GridStepPoints <= 0 || GridVolume <= 0)
      return INIT_PARAMETERS_INCORRECT;

   lastAction = TimeCurrent();
   Print("Grid EA initialized. Symbol: ", _Symbol, " Magic: ", MagicNumber);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| TICK                                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return;
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) return;
   
   symbol.Refresh();
   double bid = symbol.Bid();
   double ask = symbol.Ask();

   if((int)symbol.Spread() > MaxSpread) return;

   ManageExitScenarios();
   if(UseTrailing) TrailingStops();

   int totalPos = CountPositions() + CountOrders();
   if(AutoRebuild && totalPos == 0)
   {
      PlaceGrid(bid, ask);
      return;
   }

   CheckLimits();
   lastAction = TimeCurrent();
}

//+------------------------------------------------------------------+
//| PLACE GRID                                                       |
//+------------------------------------------------------------------+
void PlaceGrid(double bid, double ask)
{
   CancelAll();
   Print("Placing grid at ", bid);

   for(int i = 0; i < GridOrdersPerSide; i++)
   {
      double vol = GridVolume * MathPow(GridMultiplier, i);
      double bp = ask + (i + 1) * GridStepPoints * _Point + GridSpread * _Point;
      double sp = bid - (i + 1) * GridStepPoints * _Point - GridSpread * _Point;
      
      trade.BuyStop(vol, bp, _Symbol, 0, 0, 0, 0, "Grid");
      trade.SellStop(vol, sp, _Symbol, 0, 0, 0, 0, "Grid");
   }
}

//+------------------------------------------------------------------+
//| TRAILING STOPS                                                   |
//+------------------------------------------------------------------+
void TrailingStops()
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(!position.SelectByIndex(i)) continue;
      if(position.Symbol() != _Symbol || position.Magic() != MagicNumber) continue;

      double open = position.PriceOpen();
      double sl = position.StopLoss();
      double bid = symbol.Bid();
      double ask = symbol.Ask();
      ulong ticket = position.Ticket();

      if(position.PositionType() == POSITION_TYPE_BUY)
      {
         if(bid - open >= TrailStart * _Point)
         {
            double newSL = bid - TrailStep * _Point;
            if(newSL > sl + TrailStep * _Point)
               trade.PositionModify(ticket, newSL, position.TakeProfit());
         }
      }
      else
      {
         if(open - ask >= TrailStart * _Point)
         {
            double newSL = ask + TrailStep * _Point;
            if(sl == 0 || newSL < sl - TrailStep * _Point)
               trade.PositionModify(ticket, newSL, position.TakeProfit());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| EXIT SCENARIOS                                                   |
//+------------------------------------------------------------------+
void ManageExitScenarios()
{
   double profit = TotalProfit();
   
   if(CloseOnProfit && profit >= TotalProfitTarget)
   {
      Print("Profit target hit: ", profit);
      CloseAll();
      CancelAll();
   }
}

//+------------------------------------------------------------------+
//| CHECK LIMITS                                                     |
//+------------------------------------------------------------------+
void CheckLimits()
{
   double profit = TotalProfit();
   if(profit <= TotalLossLimit)
   {
      Print("Loss limit: ", profit);
      CloseAll();
      CancelAll();
   }
}

//+------------------------------------------------------------------+
//| HELPERS                                                          |
//+------------------------------------------------------------------+
void CloseAll()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(position.SelectByIndex(i) && position.Symbol() == _Symbol && position.Magic() == MagicNumber)
         trade.PositionClose(position.Ticket());
}

void CancelAll()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(order.SelectByIndex(i) && order.Symbol() == _Symbol && order.Magic() == MagicNumber)
         trade.OrderDelete(order.Ticket());
}

int CountPositions()
{
   int c = 0;
   for(int i = 0; i < PositionsTotal(); i++)
      if(position.SelectByIndex(i) && position.Symbol() == _Symbol && position.Magic() == MagicNumber) c++;
   return c;
}

int CountOrders()
{
   int c = 0;
   for(int i = 0; i < OrdersTotal(); i++)
      if(order.SelectByIndex(i) && order.Symbol() == _Symbol && order.Magic() == MagicNumber) c++;
   return c;
}

double TotalProfit()
{
   double p = 0;
   for(int i = 0; i < PositionsTotal(); i++)
      if(position.SelectByIndex(i) && position.Symbol() == _Symbol && position.Magic() == MagicNumber)
         p += position.Profit();
   return p;
}
//+------------------------------------------------------------------+
