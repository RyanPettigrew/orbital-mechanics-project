function plotOrbit(r, v, tspan)
    % Harvey Perkins
    % plots orbit starting at given r,v vectors over given timespan [t0 tf]
    % r v column vectors

    options = odeset('RelTol',1e-8,'AbsTol',1e-8); % Relative tolerance is the step in the function 

    [t,y] = ode45(@EOM, tspan, [r;v], options);

    figure
    plot3(y(:,1),y(:,2),y(:,3))
    xlabel("x, km")
    xlabel("y, km")
    xlabel("y, km")

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