%function to compute p riccati matrix and k control matrix for LQR
%A,B matrixes of linear state dynamics, 
%Q, Qf cost of the state; R cost of the control;
%N number of time intervals; N+1 samples

function  [P, K]=pk_riccati(A,B,Q,Qf,R,N)

    P(:,:,N+1)=Qf;

    for i=N:-1:1
        P(:,:,i)=Q+A'*P(:,:,i+1)*A-A'*P(:,:,i+1)*B*...
                 (inv(R+B'*P(:,:,i+1)*B))*B'*P(:,:,i+1)*A;
    end

    for i=1:N
        K(:,:,i)=inv(R+B'*P(:,:,i+1)*B)*...
                   B'*P(:,:,i+1)*A;
    end
end
