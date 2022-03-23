%----------------- Source Code for AAAI paper ---------------------------
% This is the main file as an interference for running the experimental
% results in the paper. 

clear variables
addpath("Quantum Lib", "Quantum Lib\Generic Helpers", "Quantum Lib\QETLAB-0.9", "Quantum Lib\QETLAB-0.9\helpers");

% Used Library: 
%QETLAB by Nathaniel Johnston.
% A MATLAB toolbox for quantum entanglement, version 0.9. 
% http://www.qetlab.com, January 12, 2016. doi:10.5281/zenodo.44637
% 
%% Generating the dataset

n_epoch = 200;
BatchSize = 100;
n = n_epoch * BatchSize;
DatasetChoices = {'entanglement', 'mohseni'};
options.Dataset = DatasetChoices{1}

[SupervisedSamples, Properties] = AAAIDataset(n, options);


%% Constructing the QNN architecture
% This section of the codes generates the QNN demonstrated in Figure 3 of
% the main paper. 
% -------------  Padding input state  --------------------
L =2;%number of the layers.
dQubit = Properties.nQubit; % #of input qubits
EQubit = 2; % # of auxiliary input qubits

TotalQubit = EQubit + dQubit;
Dim = 2^TotalQubit; % dimention of the input

QNNArcitecture = QNNCLASS(L,dQubit,EQubit);


% -------------  Generating QPs --------------------------
QNNArcitecture.L=L;      
QNNArcitecture.mNeuron= [2,1];  % number of QPs in each layer. 

Neuron_Aa = QNeuronClass([2,4],TotalQubit); % The first QP of the first layer. 
                                            % QNeuronClass is a MATLAB Class handeling the QPs. 
Neuron_Ab = QNeuronClass([1,3],TotalQubit);% The second QP of the first layer. 

Neuron_Ba = QNeuronClass([1, 2],TotalQubit); % The QP of the second layer

QNNArcitecture.NeuronCell = {Neuron_Aa, Neuron_Ab; Neuron_Ba, [] };

% -----------  Creating the output measurement.
M = QMeasurement(Neuron_Ba.J, TotalQubit, 0);


QNNArcitecture.Measurement = M;


%--------- QSGD initialization ---------------
QNNArcitecture.QSGD.MEASURE_FLAG = false;  % if True the first part of the experiment is done. That is Algorithm 1
                                          % if False the second experiment is done, that is QSGD with direct computation of the gradient.  
if QNNArcitecture.QSGD.MEASURE_FLAG
    QNNArcitecture.QSGD.StepSize = 0.76;    
else
    QNNArcitecture.QSGD.StepSize = 0.5;
end

%%    Training phase

[QNNArcitecture, EpochLoss, EpochPSuccess, Max_Psuccess, figure_handle]  = QNNtrain(QNNArcitecture, SupervisedSamples, n_epoch, BatchSize,true);


%%  Validation
n_test = 100;
% rng shuffle
TestSamples = AAAIDataset(n_test, options);

[Test_acc, OPT_acc, Percentile_Psuccess] = QNNtest(QNNArcitecture, TestSamples);


