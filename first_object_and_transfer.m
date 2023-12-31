%clc
%clear all
%global mu
%mu = 398600; % km3/s2

%rvect_object1 = [-2.77e4; 2.26e4; 0.0448e4];
%vvect_object1 = [-2.11; -2.59; 0.0265];
%epoch = 8.856990254250000e+09;

% Propagate forwards 5 periods plus a bit
% period object 1 = 6.738e4 seconds
loiter_time_object1 = 5*5.738e4 + 2*60*60;
object1_depart_time = epoch + loiter_time_object1;
[rvect_object1_depart, vvect_object1_depart] = propagateOrbit(rvect_object1,vvect_object1,epoch,object1_depart_time);
plotOrbit(rvect_object1, vvect_object1, [0 loiter_time_object1]);

% Lamberts to object 2
% At epoch
%rvect_object2_new = [-0.0737e4; 3.10e4; 0.00863e4];
%vvect_object2_new = [-3.62; -0.0609; -0.330];

lamberts12_time = 18*60*60;
object2_arrive_time = object1_depart_time + lamberts12_time;

[rvect_object2_arrive, vvect_object2_arrive] = propagateOrbit(rvect_object2_new,vvect_object2_new,epoch,object2_arrive_time);

% lamberts
[vsc_object1_depart, vsc_object2_arrive] = lamberts(rvect_object1_depart, rvect_object2_arrive, lamberts12_time, 1);

plotOrbit(rvect_object1_depart, vsc_object1_depart, [0 lamberts12_time]);
simulateOrbit(rvect_object1_depart, vsc_object1_depart, [0 lamberts12_time], rvect_object2_arrive');

% Propagate object 2 for 5 orbits
% period = 5.655e4
object2_wait_time = 5*5.655e4 + 30*60*60; % prev: 30
object2_depart_time = object2_arrive_time + object2_wait_time;
[rvect_object2_depart, vvect_object2_depart] = propagateOrbit(rvect_object2_arrive,vvect_object2_arrive,object2_arrive_time,object2_depart_time);
plotOrbit(rvect_object2_arrive, vvect_object2_arrive, [0 object2_wait_time]);

simulateOrbit(rvect_object2_depart, vsc_object2_depart, [0 object2_depart_time], rvect_object2_arrive);
legend("Orbit 1", "Transfer 1-2", "Orbit 2")

hold off

disp("Object 1 departure burn: " + norm(vsc_object1_depart - vvect_object1_depart) + " km/s")
disp("Object 2 arrival burn: " + norm(vsc_object2_arrive - vvect_object2_arrive) + " km/s")

% Transfer 2
figure
plotOrbit(rvect_object2_arrive, vvect_object2_arrive, [0 object2_wait_time]);

% Lamberts to object 3


lamberts23_time = 3.12*60*60; % prev: 3.12
object3_arrive_time = object2_depart_time + lamberts23_time;

[rvect_object3_arrive, vvect_object3_arrive] = propagateOrbit(rvect_object3_new,vvect_object3_new,epoch,object3_arrive_time);

% lamberts
[vsc_object2_depart, vsc_object3_arrive] = lamberts(rvect_object2_depart, rvect_object3_arrive, lamberts23_time, 1);

plotOrbit(rvect_object2_depart, vsc_object2_depart, [0 lamberts23_time]);

% Propagate object 3 for 5 periods
% period object 3 = 2.725e2
object3_wait_time = 5*2.725e2;
object3_depart_time = object3_arrive_time + object3_wait_time;
[rvect_object3_depart, vvect_object3_depart] = propagateOrbit(rvect_object3_arrive,vvect_object3_arrive,object3_arrive_time,object3_depart_time);
plotOrbit(rvect_object3_arrive, vvect_object3_arrive, [0 object3_wait_time]);

disp("Object 2 departure burn: " + norm(vsc_object2_depart - vvect_object2_depart) + " km/s")
disp("Object 3 arrival burn: " + norm(vsc_object3_arrive - vvect_object3_arrive) + " km/s")


legend("Orbit 2", "Transfer 2-3", "Orbit 3")

hold off






function [rPrime, vPrime] = propagateOrbit(r, v, epoch, endTime)
    % Harvey Perkins
    % Propagates orbit from r,v vectors at epoch to endTime
    global mu

    t0 = 0;
    tf = endTime - epoch;

    options = odeset('RelTol',1e-8,'AbsTol',1e-8); % Relative tolerance is the step in the function 

    [t,y] = ode45(@EOM, [t0 tf], [r;v], options);

    rPrime = y(end, 1:3)';
    vPrime = y(end, 4:6)';

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

function plotOrbit(r, v, tspan)
    % Harvey Perkins
    % plots orbit starting at given r,v vectors over given timespan [t0 tf]
    % r v column vectors

    options = odeset('RelTol',1e-8,'AbsTol',1e-8); % Relative tolerance is the step in the function 

    [t,y] = ode45(@EOM, tspan, [r;v], options);

    %figure
    plot3(y(:,1),y(:,2),y(:,3))
    xlabel("x, km")
    xlabel("y, km")
    xlabel("y, km")
    axis equal
    hold on
    grid on;

end

function [v1, v2] = lamberts(r1, r2, dt, sign)

    % Implement lambert's method to calc velocities on transfer
    global mu
    tol = 1e-8;

    % find deltatheta

    crossprod = cross(r1,r2);
    z = crossprod(3);

    if sign > 0
        if z < 0
            deltatheta = 2*pi - acos(dot(r1,r2)/norm(r1)/norm(r2));
        else
            deltatheta = acos(dot(r1,r2)/norm(r1)/norm(r2));
        end
    else
        if z < 0
            deltatheta = acos(dot(r1,r2)/norm(r1)/norm(r2));
        else
            deltatheta = 2*pi - acos(dot(r1,r2)/norm(r1)/norm(r2));
        end
    end
    
    %deltatheta = acos(dot(r1,r2)/(norm(r1)*norm(r2)));
    %deltatheta = asin(1*sqrt(1-cos(deltatheta)^2));

    % get A
    A = sqrt(norm(r1)*norm(r2))*sin(deltatheta)/sqrt(1 - cos(deltatheta));
    if A == 0
        disp("Lambert's solution failed")
    end

    % Initial guess for z, bounds
    z = 0;
    zupper = 4*pi^2;
    zlower = -zupper;
    dt_calc = 0;

    while abs(dt - dt_calc) > tol
        S = stumpfS_trig(z);
        C = stumpfC_trig(z);
        Y = norm(r1) + norm(r2) + A*(z*S - 1)/sqrt(C);
        chi = sqrt(Y/C);
        dt_calc = chi^3*S/sqrt(mu) + A*sqrt(Y)/sqrt(mu);
        if dt_calc < dt
            zlower = z;
        else
            zupper = z;
        end
        z = (zupper + zlower)/2;
    end

    % Calc final values
    S = stumpfS_trig(z);
    C = stumpfC_trig(z);
    Y = norm(r1) + norm(r2) + A*(z*S - 1)/sqrt(C);
    chi = sqrt(Y/C);
    dt_calc = chi^3*S/sqrt(mu) + A*sqrt(Y)/sqrt(mu);

    f = 1 - chi^2*C/norm(r1);
    g = dt - chi^3*S/sqrt(mu);

    fdot = sqrt(mu)*chi*(z*S - 1)/(norm(r1)*norm(r2));
    gdot = 1 - chi^2*C/norm(r2);

    v1 = (r2 - f*r1)/g;

    r2_test = f*r1 + g*v1; % Heart check, works

    v2 = fdot*r1 + gdot*v1;

end

% Stumpf function trig formulations
function C = stumpfC_trig(z)
    if z > 0
        C = (1 - cos(sqrt(z)))/z;
    elseif z < 0
        C = (cosh(sqrt(-z)) - 1)/(-z);
    else
        C = 1/2;
    end
end
function S = stumpfS_trig(z)
    if z > 0
        S = (sqrt(z) - sin(sqrt(z)))/(sqrt(z))^3;
    elseif z < 0
        S = (sinh(sqrt(-z)) - sqrt(-z))/(sqrt(-z))^3;
    else
        S = 1/6;
    end
end

function simulateOrbit(r, v, tspan, debris_positions)
    % r, v are column vectors for initial position & velocity
    % tspan is the timespan [t0 tf] for the orbit
    % debris_positions is a matrix where each row is a position vector of debris
    % Get EOM
    options = odeset('RelTol',1e-8,'AbsTol',1e-8);
    [t,y] = ode45(@EOM, tspan, [r;v], options);

    % Set up spacecraft STL
    stlData = stlread('SpaceX Crew Dragon - 3486142\files\SpaceXCrewDragon.stl');
    vertices = stlData.Points;
    faces = stlData.ConnectivityList;
    scale = 75; 
    vertices = vertices * scale;
    
    % Set up video sim
    video = VideoWriter('orbit_simulation.mp4', 'MPEG-4');
    open(video);
    
    % Earth texture
    earthTexture = 'earth.png';
    [X, Y, Z] = sphere(50);
    earth_radius = 6371;
    globe = surf(earth_radius*X, earth_radius*Y, earth_radius*Z, 'EdgeColor', 'none');
    set(globe, 'FaceColor', 'texturemap', 'CData', imread(earthTexture));
    hold on;
  
    % Plot initial orbit & debris
    orbitLine = plot3(y(:,1),y(:,2),y(:,3), 'b');
    debrisDots = plot3(debris_positions(:,1), debris_positions(:,2), debris_positions(:,3), 'ro');
    spacecraftDot = plot3(y(1,1), y(1,2), y(1,3), 'gs', 'MarkerSize', 10);
    xlabel('x, km');
    ylabel('y, km');
    zlabel('z, km');
    axis equal;
    grid on;

    % spacecraft
    spacecraftModel = patch('Vertices', vertices, 'Faces', faces, 'FaceColor', [0.8, 0.8, 0.8], 'EdgeColor', 'none');
    for spacecraft_idx = 1:length(t)
        currentPosition = y(spacecraft_idx, 1:3);
        transformedVertices = bsxfun(@plus, vertices, currentPosition - vertices(1,:));
        set(spacecraftModel, 'Vertices', transformedVertices);
        
        drawnow;frame = getframe(gcf); % video simulation
        writeVideo(video, frame);
        pause(0.05); 
    end
    close(video);
    hold off;
end

