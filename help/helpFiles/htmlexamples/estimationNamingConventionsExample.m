%% Name Conventions, Models and Structures
% The PROFOR toolbox utilizes the  state space form to represent individual
% models. This section describes the structure and naming conventions used.
%
%
%%
% See the
% <matlab:edit(fullfile('estimationNamingConventionsExample.m')) matlab code> 
% corresponding to this help file to run examples directly in Matlab.
%
%% The state space system
% Observation equation:
%
% $$Y_{t} = Z_{t} A_{t} + e_{t} \quad e_{t} \sim N(0,H_{t})$$
%
% Transition equation:
%
% $$ A_{t} = T_{t}A_{t-1} + u_{t} \quad u_{t} \sim N(0,Q_{t})$$
%
% with:
% 
% $$u_{t} = A0_{t}^{-1} \Sigma_{t} \epsilon_{t}$$
%
% $$\epsilon_{t} \sim N(0,1)$$
%
% $$A0_{t} Q_{t} A0_{t}' = \Sigma_{t} \Sigma_{t}'$$
%
% It is assumed that $A0$ is a lower triangular matrix, with ones on the
% diagonal, and that both $H$ and $\Sigma$ are diagonal matrices.
% 
%% Hyperparameters and time variation
% The model's hyperparameters: $Z_{t}$, $T_{t}$, $A0_{t}$, $\Sigma_{t}$,
% can be time varying. If so, they follow random walks (with independence
% across equations):
%
% $$Z_{t} = Z_{t-1} + w_{t}, \quad \quad  \quad w_{t} \sim N(0,W)$$
%
% $$T_{t} = T_{t-1} + g_{t}, \quad \quad  \quad g_{t} \sim N(0,G)$$
%
% $$A0_{t} = A0_{t-1} + s_{t}, \quad \quad  \quad s_{t} \sim N(0,S)$$
%
% $$log(\Sigma_{t}) = log(\Sigma_{t-1}) + b_{t}, \quad \quad  \quad b_{t}
% \sim N(0,B)$$
%
% The idiosyncratic errors, $e_{t}$, can either be i.i.d., or follow
% autoregressive processes:
%
% $$e_{t} = p e_{t-1} + \eta_{t} n_{t} \sim N(0,H_{t}),  \quad \quad n_{t}
% \sim N(0,1)$$
%
% $$log(\eta_{t}) = log(\eta_{t-1}) + v_{t}, \quad \quad  \quad v_{t} \sim
% N(0,V)$$
%
% Finally, the state variables, $A_{t}$, can be observed or unobserved.
% 
% In the most general form, there are  hyperparameters: $Z_{t}$, $T_{t}$,
% $A0_{t}$, $\Sigma_{t}$, $W$, $G$, $S$, $B$, $p$, and $V$.
% 
%% Priors
% With Bayesian methods, priors need to be defined. The following
% conventions are used:
%
% $$ Z: a0_z \quad p0_z \quad\quad\quad\quad\quad      W: vprior_w \quad
% Sprior_w$$
%
% $$ p: aprior_p \quad Vprior_p $$
%
% $$ \eta: a0_\eta \quad p0_\eta \quad\quad\quad\quad\quad      V: vprior_v
% \quad Sprior_v$$
%
% $$ T: a0_t \quad p0_t \quad\quad\quad\quad\quad      G: vprior_g \quad
% Sprior_g$$
% 
% $$ A0: a0_{A0} \quad p0_{A0} \quad\quad\quad     S: vprior_s \quad
% Sprior_s$$
%
% $$ \Sigma: a0_\Sigma \quad p0_\Sigma \quad\quad\quad\quad\quad      B:
% vprior_b \quad Sprior_b$$
%
% $$ A: a0_a \quad p0_a $$
%
% Here, $a0_{<>}$ and $p0_{<>}$ refer to the initial state and state
% covariance, respectively.
%
% In cases when there are no time varying parameters (and no autoregressive
% processes for the idiosyncratic errors), the prior specifications are
% determined by:
%
% $$ T: aprior_t \quad Vprior_t \quad\quad\quad\quad\quad      Q: vprior_q
% \quad Sprior_q$$
%
% $$ Z: aprior_z \quad Vprior_z \quad\quad\quad\quad\quad      H: vprior_h
% \quad Sprior_h$$
%
% 