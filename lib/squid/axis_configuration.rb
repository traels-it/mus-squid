module Squid
  class AxisConfiguration
    attr_accessor :begin, :begin_label, :end, :end_label

    def initialize options = {}
      @begin       = options[:begin]
      @begin_label = options[:begin_label]
      @end         = options[:end]
      @end_label   = options[:end_label]
    end

    def add_labels_to(values)
      return [] if values.empty? || values.one?
      values.dup.tap do |labels|
        labels[-1] = "#{@begin_label} - #{labels[-1]}" unless @begin_label.empty?
        labels[0]  = "#{@end_label} - #{labels[0]}"    unless @end_label.empty?
      end
    end
  end
end
