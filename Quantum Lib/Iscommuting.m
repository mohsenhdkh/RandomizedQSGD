function Y = Iscommuting(A,B)
Y=false;
C = A*B-B*A;
lambda = eig(C);
if max(lambda)== 0
    Y=true;
end
end