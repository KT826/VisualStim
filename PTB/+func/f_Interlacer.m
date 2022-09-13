function TrialOrder = f_Interlacer(Num_A, Num_B, rep)
%SHOULD BE: numel(Num_A) == numel(Num_B)

%Num_A = TrialOrder_pre(1:(end/2));
%Num_B = TrialOrder_pre((end/2)+1:end);

A = [];
B = [];
n = numel(Num_A);
X1 = [];
X2 = [];
X = [];
X_rep =[];
num_rep = [];


    for R = 1 : 2
        %%%A%%%
        shf = randperm(n); %shufftle
        for a = 1 : n
            A(a,1) = Num_A(shf(a));
        end
        
        %%%B%%%
        shf = randperm(n); %shufftle
        for b = 1 : n
            B(b,1) = Num_B(shf(b));
        end
        
        %%%%%%%
        for i = 1 : n
            switch R
                case 1
                    X1(i*2-1,1) = A(i);
                    X1(i*2,1) = B(i);
                case 2
                    X2(i*2-1,1) = B(i);
                    X2(i*2,1) = A(i);
            end
        end
    end
X =  [X1; X2];
X_rep = [ ones(numel([X1, X2]),1)*rep];

TrialOrder = [X, X_rep];    
end
    


