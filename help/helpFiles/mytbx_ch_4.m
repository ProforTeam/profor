%% Estimate Models and Forecast
% All individual models in the PROFOR Toolbox are defined through the Model
% class. Instances of this class (objects) contain all relevant information
% about how to estimate the particular model, the data, and estimation and
% forecasting output. Two important inputs to an instance of a Model class: 
% (1) a Tsdata object and (2) a Batch object. The Batch object is specific to 
% the Model type.
%
% In this section, the researcher can work through examples which show
% how the Batch class works, and how to estimate and forecast using a VAR and a
% BVAR. In addition we show an example on how you can import externally
% generated forecasts.