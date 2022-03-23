% Defining a MATLAB Class for handeling the structure of each QP


classdef QNeuronClass
    properties
        J       % the subsystem coordinate that the QP acts on. 
        dQubit  % number of the qubits the overl all system is. 
        a       % The quantum Fourier coefficients. it is a vector.  
    end
    properties (Dependent)
        k       % Narroness parameter
        s       % the components of the vector of the Fourier coefficient a
    end
    
    methods
        function obj = QNeuronClass(J, dQubit)
            if nargin > 0
                    obj.J = J;
                    obj.dQubit = dQubit;
                    rng(54);
                    initial_a =  2*rand(1,4^length(J))-1;
                    obj.a = initial_a;
            end
        end
        
        function k = get.k(obj)
            k = length(obj.J);
        end
        
        function s= get.s(obj)
            AllPauli = all_vec_k(0:3, obj.dQubit, obj.k,0);
            T=1:obj.dQubit;
            for r=1:length(obj.J)
                T=T(T~=obj.J(r));
            end
            FeasibleIndx = sum(AllPauli(:,T),2)==0;
            s = AllPauli(FeasibleIndx,:);
        end
        
       
        function S = saveobj(obj)
            L=length(obj);
            for l=1:L
                S(l).J= obj(l).J;
                S(l).k=  obj(l).k;
                S(l).dQubit= obj(l).dQubit;
                S(l).a= obj(l).a;
                S(l).s = obj(l).s;
                S(l).CompatibilitySet=  obj(l).CompatibilitySet;
             end
        end
        
        function obj = reload(obj,S)
            obj.J= S.J;
            obj.a=  S.a;
            obj.dQubit= S.dQubit;
        end
    end
    methods (Static)
        function obj = loadobj(S)
            if isstruct(S)
                L=length(S);
                obj(L) = QNeuronClass;
                for l=1:L
                    obj(l) = reload(obj(l),S(l));
                end
            end
        end
    end  
end


