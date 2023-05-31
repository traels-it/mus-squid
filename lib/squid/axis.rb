require 'squid/format'
require 'active_support/core_ext/enumerable' # for Array#sum

module Squid
  # @private
  class Axis
    include Format
    attr_reader :data

    def initialize(data, steps:, stack:, format:, axis_config:, &block)
      @data, @steps, @stack, @format, @axis_config = data, steps, stack, format, axis_config
      @width_proc = block if block_given?
    end

    def minmax
      @minmax ||= [min, max].compact.map do |number|
        approximate number
      end
    end

    def labels
      min, max = minmax
      values = if min.nil? || max.nil? || @steps.zero?
        []
      else
        max.step(by: (min - max)/@steps.to_f, to: min)
      end
      @labels ||= @axis_config.add_labels_to formatted_axis_labels(values)
    end

    def width
      @width ||= if val = labels.map{|label| label_width label}.max
        [val, 70].min
      else
        0
      end
    end

  private

    def label_width(label)
      @width_proc.call label if @width_proc
    end

    def min
      if @data.any? && values.first && values.first.any?
        [values.first.min, @axis_config.begin, 0].min
      end
    end

    def max
      if @data.any? && values.last && values.last.any?
        [values.last.max, @axis_config.end].max
      end
    end

    def values
      @values ||= if @stack
        @data.transpose.map{|a| a.compact.partition{|n| n < 0}.map(&:sum)}.transpose
      else
        [@data.flatten.compact]
      end
    end

    def approximate(number)
      number_to_rounded(number, significant: true, precision: 2).to_f
    end

    def formatted_axis_labels(values)
      # When no axis labels have significant zeros we draw them as integers
      if @format == :float && values.all? { |value| (value % 1).zero? }
        values.map { |value| format_for value, :integer }
      else
        values.map { |value| format_for value, @format }
      end
    end
  end
end
