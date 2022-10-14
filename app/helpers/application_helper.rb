module ApplicationHelper
  def html_body_classes
    "#{controller.controller_path.gsub('/', '_')}_#{controller.action_name}"
  end
end
