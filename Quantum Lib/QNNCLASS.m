classdef QNNCLASS
    properties
        L    % Number of layers
        dQubit % number of qubits in each sample
        EQubit % number of qubit for padding
        mNeuron % number of QPs in each layer. 
        NeuronCell % A cell containing the QPs 
        Measurement % The output measuremet
        QSGD        % Properties of the QSGD. 
    end
    properties (Dependent)
        TotalQubit
        ERho       % The auxiliary state for padding. 
    end
    
    methods
        function obj = QNNCLASS(L,dQubit,EQubit)
            if nargin > 0
                obj.L = L;
                obj.dQubit = dQubit;
                obj.EQubit = EQubit;
                obj.QSGD.gradient = [];
                obj.QSGD.LearningRate = 1;
                obj.QSGD.StepSize = 1;
                obj.QSGD.MEASURE_FLAG = true;
            end
        end
        
        function TotalQubit = get.TotalQubit(obj)
            TotalQubit = obj.dQubit + obj.EQubit;
        end
        
        function ERho = get.ERho(obj)
            % Default values of the auxiliary state. 
            if obj.EQubit >0
                EState = [1, zeros(1,2^obj.EQubit-1)];
                ERho = EState'*EState;
            else
                ERho = 1;
            end
        end
        
        
        function S = saveobj(obj)
            S.L= obj.L;
            S.dQubit=  obj.dQubit;
            S.EQubit= obj.EQubit;
            S.ERho = obj.ERho;
            S.QSGD.gradient= obj.QSGD.gradient;
            S.QSGD.LearningRate = obj.QSGD.LearningRate;
            S.QSGD.StepSize=  obj.QSGD.StepSize;
            S.QSGD.MEASURE_FLAG = obj.QSGD.MEASURE_FLAG;
            S.TotalQubit = obj.TotalQubit;
        end
    end
    
end


