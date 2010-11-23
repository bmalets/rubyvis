$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'


def get_files(path)
  h={}
  Dir.glob("#{path}/*").each {|e|
    next if File.expand_path(e)=~/pkg|web|vendor|doc|~/
    pa=File.expand_path(e) 
    if File.stat(pa).directory?
      h[File.basename(pa)]=get_files(pa)
    else
      h[File.basename(pa)]=File.stat(pa).size
    end
  }
  h
end

files=get_files(File.dirname(__FILE__)+"/../lib")

classes = Rubyvis.nodes(Rubyvis.flatten(files).leaf(lambda {|v| v.is_a? Numeric}).array)


classes[1,classes.size-1].each {|d|
  #p d.node_value.keys
  d.node_name = "/" + d.node_value[:keys].join("/")
  i = d.node_name.rindex("/")
  class << d
    attr_accessor :class_name, :package_name
  end
  d.class_name = d.node_name[i+1,d.node_name.size-(i+1)].gsub(".rb","")
  d.package_name = d.node_name[0,i]
  d.node_value = d.node_value[:value]
}
# For pretty number formatting.
format = Rubyvis.Format.number

vis = Rubyvis::Panel.new.
  width(600)
    .height(600)
c20=Rubyvis::Colors.category20()
vis.add(pv.Layout.Pack)
    .top(-50)
    .bottom(-50)
    .nodes(classes)
    .size(lambda {|d| d.node_value})
    .spacing(0)
    .order(nil)
  .node.add(Rubyvis::Dot)
    .fill_style(lambda {|d| c20.scale(d.package_name)})
    .stroke_style(lambda {|d| c20.scale(d.package_name).darker})
    .visible(lambda {|d| d.parent_node})
    .title(lambda {|d| d.node_name + ": " + format.format(d.node_value)})
  .anchor("center").add(pv.Label)
  .text(lambda {|d| d.class_name[0, Math.sqrt(d.node_value).to_i / 8]})

vis.render();
puts vis.to_svg

