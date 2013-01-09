module ApplicationHelper
  def cp(path)
    "active" if current_page?(path) || current_page?(controller: '/static_page', action: path)
  end

  def landing_page?
    current_page?(controller: '/static_page', action: 'index')
  end
end
