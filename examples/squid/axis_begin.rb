# By default, <code>chart</code> starts its axis at zero or at the lowest value in the dataset.
#
# You can use the <code>:axis_begin</code> option to specify another number.
#
filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::ManualBuilder::Example.generate(filename) do
  data = {views: {2013 => 182, 2014 => 46, 2015 => 134}}
  chart data, axis_begin: -100
end
