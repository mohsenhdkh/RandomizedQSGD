%% Quantum Synthetic dataset
% This function generates n supervized samples
% Choices for datasets are determined with additional input variable
% "options" with the following components:
%     - options.Dataset:  Determines the dataset from the following choices:
%           + 'mohseni': the dataset proposed by
%              M. Mohseni, A. M. Steinberg, and J. A. Bergou, "Optical
%              Realization of Optimal Unambiguous Discrimination for Pure
%                and Mixed Quantum States,” Physical Review Letters 2004.
%
%           + 'entanglement': a synthetic dataset containing two classes of
%             randomly generated qubits: separable with label -1 and
%             maximally entangled with label 1.
%
%
function [ SupervisedSamples, Properties ] = AAAIDataset(n, varargin)
SupervisedSamples = cell(n,2); % first column is rho_x, second column is its label.

if ~isempty(varargin)
    options = varargin{1};
else
    options =[];
end

% setting the default options
Dataset = 'mohseni';
if isfield(options, 'Dataset')
    Dataset =  options.Dataset;
end

switch Dataset
    case 'mohseni'
        
        fprintf('%s\n',"Mohseni et al")
        
        p = [1/3, 2/3];
        if isfield(options, 'p')
            p =  options.p;
        end
        XInd = randPMF(p, [-1, 1] ,n);
        
        rng(54);
        r = rand(1,n);
        
        for i = 1: n
            
            if XInd(i) == -1
                u = 0.8*r(i)+0.1;
                phi_u = [sqrt(1-u^2), 0, u, 0]';
                
                SupervisedSamples{i,1} = phi_u*phi_u';
                SupervisedSamples{i,2} = -1;
            else
                v = 0.8*r(i)+0.1;
                phi_v_plus = [0, sqrt(1-v^2), v, 0]';
                phi_v_minus = [0, -sqrt(1-v^2), v, 0]';
                
                SupervisedSamples{i,1} = 0.5*(phi_v_plus*phi_v_plus' + phi_v_minus*phi_v_minus');
                SupervisedSamples{i,2} = 1;
            end
        end
        nQubit =2;
        mTypes =-1;
        
        
    case 'entanglement'
        % This dataset has two calasses of qubits:
        %  - separable with label -1: each separable qubit is one the
        %    several randomly generated seperable qubits. The number of
        %    different separable qubits are determined by options.mTypes.
        %
        %  - maximally entangled with label 1
        %
        %
        fprintf('%s\n',"Separable Entanglement with Limitted Separables")
        
        
        mTypes = 10;
        if isfield(options, 'mTypes')
            mTypes =  options.mTypes;
        end
        
        %  number of qubits for each sample. This determines the dimension.
        nQubit = 4;
        if isfield(options, 'nQubit')
            nQubit =  options.nQubit;
        end
        if mod(nQubit,2) == 1
            error('nQubit is not an even number!');
        end
        
        dim = 2^nQubit;
        
        % there are mTypes number of separable qubits to choose from.
        SeparableState = cell(1,mTypes-1);
        rng(54)
        for m = 1:(mTypes-1)
            rhoA = RandomDensityMatrix(sqrt(dim),0,1);
            rhoB = RandomDensityMatrix(sqrt(dim),0,1);
            rhoAB = Tensor(rhoA,rhoB);
            SeparableState{m} = rhoAB;
        end
        
        
        State=MaxEntangled(sqrt(dim),1);
        rhoE = State * State';
        
        % p determines the underlying distribution on separable vs
        % entangled qubits.
        p=[0.5, 0.5];
        if isfield(options, 'p')
            p =  options.p;
        end
        XInd = randPMF(p, [-1, 1] ,n);
        SepInd = randi(mTypes-1,1,n);
        
        % Each sample is selected randomly to be maximally entangled or
        % one of the randomly generated separable states.
        for i = 1:n
            if XInd(i) == -1
                
                SupervisedSamples{i,1} = SeparableState{SepInd(i)};
                SupervisedSamples{i,2} = -1;
            else
                SupervisedSamples{i,1} = rhoE;
                SupervisedSamples{i,2} = 1;
            end
        end
        
end


Properties.Dataset = Dataset;
Properties.p = p;
Properties.nQubit = nQubit;
Properties.mTypes = mTypes;
end


