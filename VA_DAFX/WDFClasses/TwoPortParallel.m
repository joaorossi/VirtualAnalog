%----------------------Parallel Switch Class------------------------
classdef TwoPortParallel < Adaptor % the class for parallel 3-port adaptors
    properties
        WD = 0;% this is the down-going wave at the adapted port
        WU = 0;% this is the up-going wave at the adapted port
        G1
        G2
    end
    methods
        function obj = Parallel(KidLeft, KidRight) % constructor function
            obj.KidLeft = KidLeft; % connect the left 'child'
            obj.KidRight = KidRight; % connect the right 'child'
            obj.G2 = 1/KidLeft.PortRes; % G2 is the inverse port resistance from kidleft
            obj.G3 = 1/KidRight.PortRes; % G3 is the inverse port resistance from kidright
            obj.PortRes = (KidLeft.PortRes - KidRight.PortRes)/(KidLeft.PortRes + KidRight.PortRes);% obj.G2+obj.G3; % parallel adapt. port facing the root
        end
        function WU = WaveUp(obj) % the up-going wave at the adapted port
            % where to send the upgoing wave? 
        end
        function cycleWave(obj,WaveFromParent) %  sets the down-going wave
            obj.WD = WaveFromParent; % set the down-going wave for the adaptor
            % set the waves to the 'children' according to the scattering rules
      
            a1 = WaveUp(obj.KidLeft);
            a2 = WaveUp(obj.KidRight);
            b1 = a2 + obj.PortRes*(a2 - a1);
            b2 = a1 + obj.PortRes*(a2 - a1);
            setWD(obj.KidRight,b2);
            setWD(obj.KidLeft,b1);
       
        end
        function changeState(obj) % always make the state the opposite of what it was
            if obj.state == 1
                obj.state = 0;
            else
                obj.state = 1;
            end
        end
        function adapt(obj)
            if isa(obj.KidLeft, 'ser')
                adapt(obj.KidLeft)
            end
            if isa(obj.KidRight, 'ser')
                adapt(obj.KidRight)
            end
            if isa(obj.KidLeft, 'Parallel')
                adapt(obj.KidLeft)
            end
            if isa(obj.KidRight, 'Parallel')
                adapt(obj.KidRight)
            end
            
            if isa(obj, 'ser')
                obj.PortRes = obj.KidLeft.PortRes+obj.KidRight.PortRes;
            end
            if isa(obj, 'Parallel')
                obj.PortRes = (obj.KidLeft.PortRes * obj.KidRight.PortRes)/(obj.KidLeft.PortRes + obj.KidRight.PortRes); % obj.G2+obj.G3; % parallel adapt. port facing the root
            end
        end
    end
end
