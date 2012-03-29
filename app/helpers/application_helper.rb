module ApplicationHelper
  def cp(path)
    "active" if current_page?(path) || current_page?(action: path)
  end
end
