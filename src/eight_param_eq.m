classdef eight_param_eq < handle
    %% EIGHT_PARAM_EQ A class for parametric EQ filtering.
    % Author: Daniel Turk (or names below)
    % Copyright (c) 2025 Daniel Turk.
    % Licensed under the MIT License.

    % Description:
    % functions for creating and utilizing 8 band parametric consisting of
    % biquad filter objects and to process audio buffers using it
    % eight_param_eq returns a param eq made using the 8 provided cutoffs, 
    % gains, q factors and shared sampling rate

    properties
        % constants
        sampling_rate;

        % array of filters
        filters;
    end

    methods
        % creates a eight_param_eq using the provided coefficents
        % expects each array to be size 8
        % first filter will be a hpf and last will be a lpf with rest being
        % bpf or bsf depending on the gain
        function obj = eight_param_eq(filter_cutoffs, filter_gains, filter_q_factors, fs)
            % error checking
            if (length(filter_cutoffs) ~= 8) || length(filter_gains) ~= 8 ...
                    || length(filter_q_factors) ~= 8
                error("Invalid input parameter array sizes");
            end

            if (fs < 1000)
                error("Invalid sampling rate");
            end

            obj.sampling_rate = fs;

            filter_types = strings(1, 8);
            obj.filters = biquad_filter.empty(0, 8);

            % initialize filter types
            for i = 1:8
                % handle first and last filter
                if i == 1
                    filter_types(i) = "hpf";
                elseif i == 8
                    filter_types(i) = "lpf";
                else
                    filter_types(i) = "pkf";
                end


                % handle rest of filters (band pass/stop filters)


                % create and store filters
                obj.filters(i) = biquad_filter(filter_types(i), filter_cutoffs(i), fs, filter_q_factors(i), filter_gains(i));

            end

        end

        function output_buffer = processAudio(obj, inputBuffer)
            % process signal by passing filtered output into next filter
            temp_buffer = inputBuffer;
            for i = 1:length(obj.filters)
                temp_buffer = filterAudio(obj.filters(i), temp_buffer);
            end

            output_buffer = temp_buffer;
        end
    end


end
