require 'squid/format'

module Squid
  class Point
    extend Format

    def self.for(series, minmax:, height:, labels:, stack:, formats:)
      @min = Hash.new 0
      @max = Hash.new 0
      min, max = minmax
      offset = -> (value) { value * height.to_f / (max-min) }
      series.map.with_index do |values, series_i|
        values.map.with_index do |value, i|
          h = y_for value, index: i, stack: false, &offset if value
          y = y_for value, index: i, stack: stack, &offset if value
          y = y - offset.call([min, 0].min) if value
          label = format_for value, formats[series_i] if labels[series_i]
          new y: y, height: h, index: i, label: label, stack: stack, negative: value.to_f < 0
        end
      end
    end

    attr_reader :index, :label, :negative, :stack

    def initialize(y:, height:, index:, label:, negative:, stack:)
      @y, @height, @index, @label, @negative, @stack = y, height, index, label, negative, stack
    end

    def height
      return unless @height
      @height + height_offset
    end

    def y
      return unless @y
      @y + height_offset
    end

  private

    # Ensures values of zero are visible by setting a minimum height
    #
    # @note
    #   We also adjust the height of zero-values on charts with negative values.
    #   If this is deemed undesirable in the future, change the code below to:
    #     @y == 0 && @height == 0 && !stack ? 2 : 0
    #
    def height_offset
      @height == 0 && !stack ? 2 : 0
    end

    def self.y_for(value, index:, stack:, &block)
      if stack
        hash = (value > 0) ? @max : @min
        yield(hash[index] += value)
      else
        yield(value)
      end
    end
  end
end
