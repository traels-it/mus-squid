require 'spec_helper'

describe Squid::Axis do
  let(:options) { {steps: steps, stack: stack?, format: format, axis_config: axis_config} }
  let(:steps) { 4 }
  let(:stack?) { false }
  let(:format) { :integer }
  let(:axis_labels) { nil }
  let(:axis_config) { Squid::AxisConfiguration.new(begin: 0, begin_label: '', end: 0, end_label: '', labels: axis_labels) }
  let(:block) { nil }
  let(:series) { [[-1.0, 9.9, 3.0], [nil, 2.0, -50.0]] }

  describe '#labels' do
    subject(:axis) { Squid::Axis.new series, **options }
    let(:labels) { axis.labels }

    describe 'given 0 steps' do
      let(:steps) { 0 }
      it 'returns 0 strings' do
        expect(labels.size).to be_zero
      end
    end

    describe 'given N steps' do
      let(:steps) { 1 + rand(10) }
      it 'returns N+1 strings' do
        expect(labels.size).to be steps + 1
      end
    end

    describe 'given stacked series' do
      let(:stack?) { false }
      it 'ranges the labels from the min and max of all series' do
        expect(labels.first).to eq '9'
        expect(labels.last).to eq '-50'
      end
    end

    describe 'given non-stacked series' do
      let(:stack?) { true }
      it 'ranges the labels from the cumulative min and max of all series' do
        expect(labels.first).to eq '12'
        expect(labels.last).to eq '-50'
      end
    end

    describe 'given custom axis labels' do
      let(:series) { [[0, 1, 2]] }
      let(:axis_labels) { ["Low", "Mid", "High"] }

      it 'displays the custom labels instead of inferring values' do
        expect(labels).to eq %w(High Mid Low)
      end
    end

    describe 'given :integer format' do
      let(:format) { :integer }
      it 'returns the labels as integers' do
        expect(labels).to eq %w(9 -5 -20 -35 -50)
      end
    end

    describe 'given :percentage format' do
      let(:format) { :percentage }
      it 'returns the labels as percentages with 1 significant digit' do
        expect(labels).to eq %w(9.9% -5.1% -20.0% -35.0% -50.0%)
      end
    end

    describe 'given :percentage_without_precision format' do
      let(:format) { :percentage_without_precision }
      it 'returns the labels as percentages with no significant digits' do
        expect(labels).to eq %w(10% -5% -20% -35% -50%)
      end
    end

    describe 'given :currency format' do
      let(:format) { :currency }
      it 'returns the labels as currency with 2 significant digits' do
        expect(labels).to eq %w($9.90 -$5.07 -$20.05 -$35.03 -$50.00)
      end
    end

    describe 'given :second format' do
      let(:format) { :seconds }
      it 'returns the labels as minutes:seconds' do
        expect(labels).to eq %w(0:10 -0:05 -0:20 -0:35 -0:50)
      end
    end

    describe 'given :float format' do
      let(:format) { :float }
      it 'returns the labels as floats with one decimal number and ignoring significant digits' do
        expect(labels).to eq %w(9.9 -5.1 -20.0 -35.0 -50.0)
      end

      describe 'when axis labels only contains floats with insignificant zeros' do
        let(:series) { [[-1.0, 0.0, 1.0], [-2.0, 0.0, 2.0]] }

        it 'renders them as integers' do
          expect(labels).to eq %w(2 1 0 -1 -2)
        end
      end
    end
  end

  describe '#width' do
    let(:width) { axis.width }

    describe 'given no block, returns 0' do
      subject(:axis) { Squid::Axis.new series, **options }
      it { expect(width).to be_zero }
    end

    describe 'given no block, returns the maximum value of the block' do
      subject(:axis) { Squid::Axis.new series, **options, &block }
      let(:block) { -> (value) { value.to_i } }
      it { expect(width).to eq 9 }
    end
  end
end
