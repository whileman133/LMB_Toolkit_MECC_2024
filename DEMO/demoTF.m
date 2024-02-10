% demoTF.m
%
% Demonstrate the usage of the toolkit for computing transfer functions 
% of electrochemical variables for lithium-metal battery cells.
%
% NOTE: All of the TF implementation appears in UTILITY/CELL_MODEL/tfLMB.m
% The tfXX.m functions call the tfLMB.m function internally.
%
% NOTE: This can also be used to compute the impedance of half cells. 
% For half cells, use the "effective" layer as the separator (eff => sep).
%
% -- Changelog --
% 2024.01.18 | Created | Wesley Hileman <whileman@uccs.edu>

clear; close all; clc;
if(~isdeployed),cd(fileparts(which(mfilename))); end
addpath('..');
TB.addpaths;

% Constants.
cellsheet = 'cellLMO-P2DM.xlsx';  % spreadsheet with param values
freq = logspace(-3.5,5,100);      % vector of frequency points [Hz]
socPct = 10;  % soc at which to evalulate impedance [%]
TdegC  = 25;  % temperature at which to evalulate impedance [degC]

% Load spreadsheet of cell parameter values.
cellmodelstd = loadCellModel(cellsheet);
cellmodellumped = convertCellModel(cellmodelstd,'LLPM'); % convert to lumped-param model

% Compute impedance of the cell using tfXX functions:
s = 1j*2*pi*freq;
cellparams = evalSetpoint(cellmodellumped,s,socPct/100,TdegC+273.15);
Phise  = tfPhiseInt(s,[0 3],cellparams);
Phise0 = Phise(1,:);  % Phise/Iapp impedance at x=0
Phise3 = Phise(2,:);  % Phise/Iapp impedance at x=3 (pos current collector)
Phie3  = tfPhie(s,3,cellparams);  % Phie/Iapp impedance at x=3 (pos current collector)
Vcell  = -Phise0 + Phie3 + Phise3; % Vcell/Iapp
Zcell  = -Vcell; % -Vcell/Iapp is the cell impedance

% Plot (Nyquist).
figure;
plot(real(Zcell),-imag(Zcell));
xlabel("Z_{cell}' [\Omega]");
ylabel("-Z_{cell}'' [\Omega]");
title(cellmodellumped.name);
if exist('quadprog','file')
    % Need quadprog to format the axes limits so that the Nyquist
    % plot is true 1:1 scale
    setAxesNyquist;
end
thesisFormat;