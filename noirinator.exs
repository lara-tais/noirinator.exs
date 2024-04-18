defmodule Noirinator do

# Dependencies to process XML and images
  Mix.install([:mogrify, :svg_tracing, :sax_map]) #xml_builder

# get config from file

def sources_dir, do: "sources"
def svg_dir, do: "svgs"
def target_size, do: 10
def extension, do: ".jpg"

#@override

# APT GET INSTALL CARGO

def source_files do
  File.ls!(sources_dir()) |> Enum.map(fn file ->
     sources_dir() <> "/" <> file
   end)
end

def normalize_image_file(file) do
    IO.puts(".Normalizing " <> file)
      Mogrify.open(file) |> Mogrify.resize_to_limit(target_size())  |> Mogrify.format(extension()) |> Mogrify.save()
    # turn gray!
    # make them jpg
end

def trace_bitmap(file) do
  IO.puts("..Tracing " <> file)
  output_file = file |> String.replace("jpg", "svg") |> String.replace(sources_dir(), svg_dir())
  svg = SvgTracing.trace(file, output_file)
  output_file
end

def add_to_master_svg(file) do
  IO.puts("...Adding " <> file <> " to master SVG file")
  xml = File.read!(file)
  map_xml = SAXMap.from_string(xml, ignore_attribute: false)
  IO.inspect(map_xml)
end

def prep_master_svg() do
  IO.puts("######## Prepping master SVG file ########")

  base_file = "<?xml version='1.0' encoding='UTF-8'?><svg></svg>"
  files = source_files()
  files |> Enum.each(fn file ->
    Noirinator.normalize_image_file(file)
    svg = Noirinator.trace_bitmap(file)
    Noirinator.add_to_master_svg(svg)
   end)
  IO.puts("######## Master SVG file ready ########")
end

end

Noirinator.prep_master_svg()
