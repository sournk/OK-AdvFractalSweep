// Fractal Indicator for MetaTrader 5 (MT5)
// This indicator is based on the logic of identifying 3-bar or 5-bar fractals.
// Coded in MQL5 for MT5 terminal.

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

// Plot settings
#property indicator_label1 "Up Fractal"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrMediumSeaGreen
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID

#property indicator_label2 "Down Fractal"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrTomato
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID

// Input variables
input int Periods = 2;  // Number of periods
input int FractalBars = 5;  // Choose between 3 or 5 bar fractals

// Buffers for storing fractal values
double UpFractalBuffer[];
double DownFractalBuffer[];

// Initialization function
int OnInit()
{
    // Set the buffers
    SetIndexBuffer(0, UpFractalBuffer);
    SetIndexBuffer(1, DownFractalBuffer);

    // Set plotting properties
    PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 5); // Set a slight upward offset for upper fractal
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -5); // Set a slight downward offset for lower fractal

    return(INIT_SUCCEEDED);
}

// Function for calculating indicator values
int OnCalculate(const int rates_total,    // number of bars
                const int prev_calculated, // bars handled in previous call
                const datetime &time[],    // time array
                const double &open[],      // open price array
                const double &high[],      // high price array
                const double &low[],       // low price array
                const double &close[],     // close price array
                const long &tick_volume[], // tick volume array
                const long &volume[],      // real volume array
                const int &spread[])       // spread array
{
    // Ensure we have enough data
    if (rates_total < FractalBars + 2)
        return(0);

    int start = prev_calculated > 0 ? prev_calculated - 1 : FractalBars;

    // Loop through each bar starting from the last unprocessed one
    for (int i = start; i < rates_total - FractalBars; i++)
    {
        bool isUpFractal = false;
        bool isDownFractal = false;

        // Logic for 5-bar fractal
        if (FractalBars == 5)
        {
            isUpFractal = (low[i - 2] > low[i] && low[i - 1] > low[i] && low[i + 1] > low[i] && low[i + 2] > low[i]);
            isDownFractal = (high[i - 2] < high[i] && high[i - 1] < high[i] && high[i + 1] < high[i] && high[i + 2] < high[i]);
        }
        // Logic for 3-bar fractal
        else if (FractalBars == 3)
        {
            isUpFractal = (low[i - 1] > low[i] && low[i + 1] > low[i]);
            isDownFractal = (high[i - 1] < high[i] && high[i + 1] < high[i]);
        }

        // Set buffer values with a slight offset for better visibility
        UpFractalBuffer[i] = isUpFractal ? low[i] - (high[i] - low[i]) * 0.05 : EMPTY_VALUE;
        DownFractalBuffer[i] = isDownFractal ? high[i] + (high[i] - low[i]) * 0.05 : EMPTY_VALUE;
    }

    return(rates_total);
}

// END.
