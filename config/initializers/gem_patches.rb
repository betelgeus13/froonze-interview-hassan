Dir.glob(Rails.root.join('lib/gem_patches/**/*.rb')).sort.each do |filename|
  require filename
end
