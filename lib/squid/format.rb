require 'active_support'
require 'active_support/number_helper' # for number_to_rounded

module Squid
  module Format
    include ActiveSupport::NumberHelper

    def format_for(value, format)
      case format
        when :percentage then number_to_percentage value, precision: 1
        when :currency then number_to_currency value
        when :seconds then number_to_minutes_and_seconds value
        when :float then number_to_float value
        when :integer_without_zero then number_to_integer_without_zero value
        when :float_without_zero then number_to_float_without_zero value
        else number_to_delimited value.to_i
      end.to_s
    end

    def number_to_minutes_and_seconds(value)
      return unless value
      signum = '-' if value < 0
      "#{signum}#{value.abs.round/60}:#{(value.abs.round%60).to_s.rjust 2, '0'}"
    end

    def number_to_float(value)
      float = number_to_rounded value, significant: false, precision: 1
      number_to_delimited float
    end

    def number_to_float_without_zero(value)
      value.zero? ? "" : number_to_float(value)
    end

    def number_to_integer_without_zero(value)
      value.zero? ? "" : number_to_delimited(value.to_i)
    end
  end
end
