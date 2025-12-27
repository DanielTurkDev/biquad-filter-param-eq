classdef biquad_filter < handle
    %% MUT 304 - Final Project (1 point)
    % Name - [Daniel Turk] (1 point)
    % Date - [12/8/2025] (1 point)

    % Brief Description (5 points)
    % Contains methods to create and utilize a biquad filter
    % Calculates filter coefficents using formulas from Digital Audio
    % Theory by Christopher L. Bennett
    % Requires external controller or console commands to run
    % Alternatively, code may be ran by calling the functions in the
    % command line
    %% Includes biquad filter function which returns a low-pass, high-pass or
    % peaking filter (utilizes gain)
    %% Includes filter audio which returns the filtered input buffer using
    % the provided filter
    % Project Code:

    properties
        q;
        a0;
        b0;
        a_coeff;
        a_delays
        b_coeff;
        b_delays;
        gain;
    end

    methods

        function obj = biquad_filter(type, fc, fs, q_value, gain)
            % Constructs a filter given the desired parameters if params
            % are valid
            % type is lpf, hpf, bpf, or bsf STRING (standard filter types)
            % fc is cutoff frequency
            % fs is sampling rate
            % q is q factor, bandwidth intensity
            % gain in d
            order = 2;
            obj.a0 = 0.0;
            obj.b0 = 0;
            obj.q = q_value;
            obj.gain = gain;
            obj.a_coeff = zeros([1, order]);
            obj.a_delays = zeros([1, order]);
            obj.b_coeff = zeros([1, order]);
            obj.b_delays = zeros([1, order]);
            obj = computeCoeff(obj, type, fc, fs);
        end

        function obj = computeCoeff(obj, type, fc, fs)
            %computeCoeff
            %   Detailed explanation goes here
            % y[n] = a0x[n] + sum(a_coeff(o)*a_delays(o) from o = 1:order

            % error checking
            if (fs <= 0)
                error("Sampling rate cannot be 0 or negative");
            end

            if (fc < 0)
                error("Cutoff frequency cannot negative");
            end

            % calculate shared terms
            w_0 = 2*pi*(fc/fs);
            alpha = sin(w_0) / (2 * obj.q); % term used in biquad equations
            A = 10^ (obj.gain / 40); % gain factor in linear form for center frequency


            if type == "lpf"
                obj.a0 = (1 - cos(w_0)) / 2;
                obj.a_coeff(1) = (1 - cos(w_0));
                obj.a_coeff(2) = (1 - cos(w_0)) / 2;
                obj.b0 = 1 + alpha;
                obj.b_coeff(1) = -2 * cos(w_0);
                obj.b_coeff(2) = 1 - alpha;

            elseif type == "hpf"
                obj.a0 = (1 + cos(w_0)) / 2;
                obj.a_coeff(1) = -(1 + cos(w_0));
                obj.a_coeff(2) = (1 + cos(w_0)) / 2;
                obj.b0 = 1 + alpha;
                obj.b_coeff(1) = -2 * cos(w_0);
                obj.b_coeff(2) = 1 - alpha;

            % every other filter can be treated as a peaking filter
            elseif type == "pkf" 
                obj.a0 = 1 + A * alpha;
                obj.a_coeff(1) = -2 * cos(w_0);
                obj.a_coeff(2) =  1 - A * alpha;
                obj.b0 = 1 +  alpha / A;
                obj.b_coeff(1) = -2 * cos(w_0);
                obj.b_coeff(2) = 1 - alpha / A;
            else 
                error("Invalid filter type");
            end

            % normalize coefficents using b0
            obj.a0 = obj.a0 / obj.b0;
            obj.a_coeff = obj.a_coeff / obj.b0;
            obj.b_coeff = obj.b_coeff / obj.b0;
            obj.b0 = 1; 
        end


        function output_buffer = filterAudio(obj,input_buffer)
            %METHOD1 running the difference equation
            % y[n] = a0x[n]+a1*x[n-1]+a2*x[n-2]-b1*y[n-1]-b2*y[n-2]
            output_buffer = zeros(size(input_buffer));
            for i = 1:length(input_buffer)
                output_buffer(i) = obj.a0*input_buffer(i)+obj.a_coeff(1)*obj.a_delays(1) + ...
                    obj.a_coeff(2)*obj.a_delays(2) - obj.b_coeff(1)*obj.b_delays(1) - obj.b_coeff(2)*obj.b_delays(2);
                obj.a_delays(2) = obj.a_delays(1);
                obj.a_delays(1) = input_buffer(i);
                obj.b_delays(2) = obj.b_delays(1);
                obj.b_delays(1) = output_buffer(i);
            end

        end
    end
end