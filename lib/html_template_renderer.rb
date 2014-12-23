class HtmlTemplateRenderer
  class << self
    def generate_html(request:,template:,locals:)
      create_action_view(request).render( template: template, locals: locals )
    end

    private

    def create_action_view(request)
      action_view = ActionView::Base.new(ActionController::Base.view_paths, {})
      action_view.request = request
      action_view.extend ApplicationHelper
      action_view.class_eval do
        include Rails.application.routes.url_helpers
      end
      action_view
    end
  end
end
