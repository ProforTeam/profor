classdef SplitNormal
    % SplitNormal - Reads in 3 common split-normal specifications and provides
    %               methods for its pdf, cdf and random number generation.
    %   The object can be initialised in the three ways that are commonly used in
    %   the forecasting literature and highlighted in Wallis (2004). These are
    %   'John1982-two-variances', 'BoE-uncorrected-skew' &
    %   'BFW1998-corrected-skew'.
    %
    % Split-Normal, or a two-peice normal, is the composite of two normal
    % distributions. The two distributions have a common mode with differing
    % variances above and below this mode.    
    %
    % References:
    %   John, S. (1982), 'The three-parameter two-piece normal family of
    %   distributions and its fitting', Communications in Statistics - Theory
    %   and Methods, 11, pp. 879-85.
    %
    %   Britton, E., Fisher, P.G. and Whitley, J.D. (1998), 'The Inflation
    %   Report projections: understanding the fan chart', Bank of England 
    %   Quarterly Bulletin, 38, pp. 30-37.
    %
    %   Wallis, Kenneth F. (2004), 'An assessment of Bank of England and 
    %   National Institute inflation forecast uncertainties', NATIONAL INSTITUTE 
    %   ECONOMIC REVIEW, 189, pp. 64-71.
    %
    %   Banerjee, N.; A. Das (2011). "Fan Chart: Methodology and its Application 
    %   to Inflation Forecasting in India". Reserve Bank of India Working Paper 
    %   Series.
    %
    % Usage:
    %   obj = SplitNormal( muMode, sigma1Sq, sigma2Sq,  'John1982-two-variances')
    %   obj = SplitNormal( muMode, sigmaSq,  gamma,     'BFW1998-corrected-skew')
    %   obj = SplitNormal( muMode, sigmaSq,  ksi,       'BoE-uncorrected-skew')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %     Copyright (C) 2014  PROFOR Team
    % 
    %     This program is free software: you can redistribute it and/or modify
    %     it under the terms of the GNU General Public License as published by
    %     the Free Software Foundation, either version 3 of the License, or
    %     (at your option) any later version.
    % 
    %     This program is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    % 
    %     You should have received a copy of the GNU General Public License
    %     along with this program.  If not, see <http://www.gnu.org/licenses/>.
    %    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    
    properties
        % John 1982 parameters for the mode, variance of the left and right hand
        % side distributions, sigma1Sq and sigma2Sq respectively.
        muMode
        sigma1Sq
        sigma2Sq
        
        % Britton, Fisher & Whitley (1998) - Corrected Skew parameters for the
        % overall variance and a measure of skewness that has been corrected
        % such that positive values of skewness represent positive skewness.
        sigmaSq
        gamma
        
    end
    
    methods
        function obj = SplitNormal( varargin )
            % SplitNormal   Reads in parameters according to the 3
            %               parameterisations.            
            %   Wallis (2004) explains the inter-relations between the 3 cases.
            
            errType     = [mfilename, ': '];
            
            
            if nargin == 4
                
                obj.muMode          = varargin{1};
                parametrization     = lower(varargin{4});
                
                % For the three common parameterisation extract and convert them
                % into the two variance case of John (1982).
                switch parametrization
                    case lower('John1982-two-variances')
                        % Allocate the final two free input args: the two
                        % variances above and below the mode.
                        
                        % Ensure the variances are well defined.
                        isVariancePositive = varargin{2} > 0 & varargin{3} > 0;
                        
                        if isVariancePositive
                            % Assign variance.
                            obj.sigma1Sq = varargin{2};
                            obj.sigma2Sq = varargin{3};
                            
                        else
                            error(errType, 'One of the variances is negative')
                        end
                        
                        % Rearranging the equivalance in Wallis (2004) box A-eq
                        % A5, the skew - gamma can be expressed as:
                        obj.gamma    = (obj.sigma2Sq - obj.sigma1Sq ) ...
                            / (obj.sigma1Sq + obj.sigma2Sq);
                        
                        % And using eq A5 the common variance as:
                        obj.sigmaSq  = obj.sigma1Sq * (1 + obj.gamma);
                        
                    case lower('BFW1998-corrected-skew')
                        % Allocate the final two free input args: the overall
                        % variance and the corrected positive skew.
                        
                        % Validate the input args for variance and skewness.
                        assert(varargin{2} > 0, 'The variance must be positive');
                        
                        msg = 'BFW skew parameter (gamma) must lie in the range [-1,1]';
                        assert( abs( varargin{3} ) < 1, msg);
                        
                        % Assign input variables
                        obj.sigmaSq  = varargin{2};
                        obj.gamma    = varargin{3};
                        
                        % Using the equivalance eqns in Wallis (2004) box A-eq
                        % A5, the individual varainces are calculated as:
                        obj.sigma1Sq = obj.sigmaSq / (1 + obj.gamma);
                        obj.sigma2Sq = obj.sigmaSq / (1 - obj.gamma);
                        
                    case lower('BoE-uncorrected-skew')
                        % Allocate the final two free input args: the overall
                        % variance and use the Bank's measure of skew, \ksi = 
                        % mean - mode, to calculate the corrected skew parameter 
                        % gamma.
                        
                        % Validate the input args for variance.
                        assert(varargin{2} > 0, 'The variance must be positive');
                        
                        % Assign variables
                        obj.sigmaSq     = varargin{2};
                        
                        % As detailed in Banerjee Das (2011), another measure of
                        % skewness is the difference between the mean and the
                        % mode, denoted ksi.
                        ksi             = varargin{3};
                        
                        % Calculate the corrected skew value according to the
                        % manipulations in Banerjee Das (2011).
                        if ksi ~= 0
                            beta        = ( pi * ksi^2 ) / ( 2 * obj.sigmaSq );
                            obj.gamma   = sign( ksi ) * ...
                                sqrt(1 - ((sqrt(1 + 2 * beta) - 1) / beta) ^2 );
                            
                        else
                            obj.gamma = 0;
                        end
                        
                        % Using the equivalance eqns in Wallis (2004) box A-eq
                        % A5, the individual varainces are calculated as:
                        obj.sigma1Sq = obj.sigmaSq / ( 1 + obj.gamma);
                        obj.sigma2Sq = obj.sigmaSq / ( 1 - obj.gamma);
                        
                    otherwise
                        error(errType, 'The parameterisation given is not recognised');
                end
            else
                error(errType, 'Insufficient input args, require 4')
            end
        end
        
        % Methods in external files.
        pdfvalue    = splitNormalPdf(obj, x)
        cdfvalue    = splitNormalCdf(obj, x)
        R           = randSplitNormal(obj, outDim)
    end
    
end


