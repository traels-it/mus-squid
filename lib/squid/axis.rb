require 'squid/format'
require 'active_support/core_ext/enumerable' # for Array#sum

module Squid
  # @private
  class Axis
    include Format
    attr_reader :data

    def initialize(data, steps:, stack:, format:, axis_begin:, axis_end:, axis_begin_label:, axis_end_label:, &block)
      @data, @steps, @stack, @format, @axis_begin, @axis_end = data, steps, stack, format, axis_begin, axis_end
      @axis_begin_label, @axis_end_label = axis_begin_label, axis_end_label
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
      @labels ||= add_axis_labels_to values.map{|value| format_for value, @format}
    end

    def width
      @width ||= labels.map{|label| label_width label}.max || 0
    end

  private

    def label_width(label)
      @width_proc.call label if @width_proc
    end

    def min
      if @data.any? && values.first && values.first.any?
        [values.first.min, @axis_begin, 0].min
      end
    end

    def max
      if @data.any? && values.last && values.last.any?
        [values.last.max, @axis_end].max
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

    def add_axis_labels_to(labels)
      return [] if labels.empty? || labels.one?
      labels.dup.tap do |values|
        values[0]  = "(#{@axis_end_label}) #{values[0]}"    unless @axis_end_label.empty?
        values[-1] = "(#{@axis_begin_label}) #{values[-1]}" unless @axis_begin_label.empty?
      end
    end
  end
end
