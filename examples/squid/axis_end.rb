# By default, <code>chart</code> ends its axis at the highest value in the dataset.
#
# You can use the <code>:axis_end</code> option to specify another number.
#
filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::ManualBuilder::Example.generate(filename) do
  data = {views: {2013 => 182, 2014 => 46, 2015 => 134}}
  chart data, axis_end: 300
end
