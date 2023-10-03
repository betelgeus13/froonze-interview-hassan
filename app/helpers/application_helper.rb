module ApplicationHelper
  def reference_link_to(name, url, options = {}, &block)
    options = options.merge(target: :_blank)
    if block_given?
      link_to(url, options, &block)
    else
      link_to(name, url, options, &block)
    end
  end
end
