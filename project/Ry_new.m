function R = Ry_new(th)
%Rotazione attorno a x
R = [cos(th) 0 sin(th) ;
    0 1 0;
    -sin(th) 0 cos(th)];
end
