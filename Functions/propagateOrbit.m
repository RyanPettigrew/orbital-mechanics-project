function [rPrime, vPrime] = propagateOrbit(r, v, epoch, endTime)
    % Harvey Perkins
    % Propagates orbit from r,v vectors at epoch to endTime
    global mu

    t0 = 0;
    tf = endTime - epoch;

    [t,y] = ode45(@EOM, [t0 tf], [r;v]);

    rPrime = y(end, 1:3);
    vPrime = y(end, 4:6);

end

function dy = EOM(t, y)
    global mu
    % Do stuff
    % y = [x; y; z; vx; vy; vz]

    r = norm([y(1), y(2), y(3)]);
    v = norm([y(4), y(5), y(6)]);
    dy(1,1) = y(4);
    dy(2,1) = y(5);
    dy(3,1) = y(6);
    dy(4,1) = -mu*y(1)/r^3;
    dy(5,1) = -mu*y(2)/r^3;
    dy(6,1) = -mu*y(3)/r^3;
end