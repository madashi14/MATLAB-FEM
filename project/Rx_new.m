function R = Rx_new(th)
%Rotazione attorno a x
R = [1 0 0 ;
    0 cos(th) -sin(th);
    0 sin(th) cos(th)];
end